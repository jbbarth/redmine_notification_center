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

    def project_id
      case @object
      when Issue, Message, WikiContent, News, Attachment, Journal, Document
        @object.project.id
      when Comment
        @object.commented.project.id
      else
        raise ArgumentError, "Object type not supported in '#project_id': #{@object.inspect}"
      end
    end
  end
end
