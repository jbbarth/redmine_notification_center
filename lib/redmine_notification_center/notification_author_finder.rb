module RedmineNotificationCenter
  class NotificationAuthorFinder
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
        raise ArgumentError, "Object type not supported: #{@object.inspect}"
      end
    end
  end
end
