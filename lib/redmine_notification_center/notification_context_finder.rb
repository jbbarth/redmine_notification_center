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

    def tracker_id
      case @object
      when Issue
        @object.tracker_id
      when Journal
        @object.issue.tracker_id
      else
        raise ArgumentError, "Object type not supported in '#tracker_id': #{@object.inspect}"
      end
    end
  end
end
