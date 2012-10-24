# Turns an A::R object into an event before notification
module RedmineNotificationCenter
  class Event < Struct.new(:type, :object)
    KNOWN_EVENTS = %w(attachments_added document_added issue_added issue_edited
                      message_posted news_added news_comment_added wiki_content_added wiki_content_updated)

    def initialize(type, object)
      raise ArgumentError, "Unknown event type '#{type}'" unless KNOWN_EVENTS.include?(type.to_s)
      super
    end

    def candidates
      raise "TODO"
    end

    def recipients
      candidates.select do |candidate|
        candidate.wants_notifications_for(type, object)
      end
    end
  end
end
