# Turns an A::R object into an event before notification
module RedmineNotificationCenter
  class NotificationEvent < Struct.new(:type, :object)
    def initialize(type, object)
      raise ArgumentError, "Unknown event type '#{type}'" unless Utils::KNOWN_EVENTS.include?(type.to_s)
      super
    end

    def candidates
      raise "TODO"
    end

    def recipients
      candidates.select do |candidate|
        candidate.wants_notifications_for(self)
      end
    end
  end
end
