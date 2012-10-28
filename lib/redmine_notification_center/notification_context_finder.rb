module RedmineNotificationCenter
  class NotificationContextFinder
    def initialize(object)
      @object = object
    end

    def author
      case @object
      when Issue, Message, WikiContent, News, Comment, Attachment
        @object.author
      when Journal
        @object.user
      when Document
        @object.attachments.first.try(:author)
      else
        raise ArgumentError, "Object type not supported in '#author': #{@object.inspect}"
      end
    end

    def project
      case @object
      when Issue, Message, WikiContent, News, Attachment, Journal, Document
        @object.project
      when Comment
        @object.commented.project
      else
        raise ArgumentError, "Object type not supported in '#project_id': #{@object.inspect}"
      end
    end

    def project_id
      project.id
    end

    def issue
      case @object
      when Issue
        @object
      when Journal
        @object.issue
      else
        raise ArgumentError, "Object type not supported in '#issue': #{@object.inspect}"
      end
    end
    delegate :tracker_id, :tracker_id_was, :priority_id, :priority_id_was, :to => :issue
  end
end
