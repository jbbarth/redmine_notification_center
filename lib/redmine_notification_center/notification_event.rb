# Turns an A::R object into an event before notification
module RedmineNotificationCenter
  class NotificationEvent < Struct.new(:type, :object)
    def initialize(type, object)
      raise ArgumentError, "Unknown event type '#{type}'" unless Utils::known_event?(type)
      raise ArgumentError, "Bad object type 'Comment'" if object.respond_to?(:commented)
      super
    end

    def candidates
      recipients = []
      case type
      when :issue_added, :issue_edited
        # adapted from app/models/issue.rb
        issue = object
        recipients << issue.author if issue.author
        if issue.assigned_to
          recipients += (issue.assigned_to.is_a?(Group) ? issue.assigned_to.users : [issue.assigned_to])
        end
        if issue.assigned_to_was
          recipients += (issue.assigned_to_was.is_a?(Group) ? issue.assigned_to_was.users : [issue.assigned_to_was])
        end
        recipients.reject!{|u| !u.active? }
        #WAS: !u.active? && u.notify_about?(self)} => removed, decision moved down to NotificationPolicy#should_notify?
        recipients += issue.project.users
        #WAS: issue.project.notified_users => same, decision moved to NotificationPolicy#should_notify?
        recipients.uniq!
        #remove users that can not view the issue
        #TODO: rewrite it, it's very slow
        recipients.reject! {|user| !issue.visible?(user)}
      when :document_added, :news_added, :news_comment_added, :message_posted,
           :wiki_content_added, :wiki_content_updated
        #for those items, "object.recipients" was implemented in the acts_as_event plugin
        recipients = object.project.users
        #WAS: object.project.notified_users (through acts_as_event plugin)
        #but decision is moved down to NotificationPolicy#should_notify?
        recipients.reject! {|user| !object.visible?(user)}
      when :attachments_added
        container = object.first.container
        class_name = container.class.name
        recipients = container.project.users
        #WAS: object.project.notified_users (through acts_as_event plugin)
        #but decision is moved down to NotificationPolicy#should_notify?
        if class_name == 'Document'
          recipients.reject! {|user| !container.visible?(user)}
        elsif class_name.in? %w(Project Version)
          recipients.reject! {|user| !user.allowed_to?(:view_files, container.project)}
        end
      end
      recipients
    end

    def notified_users
      policy = NotificationPolicy.new(self)
      candidates.select do |candidate|
        policy.should_notify?(candidate)
      end
    end
  end
end
