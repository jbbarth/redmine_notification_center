# Turns an A::R object into an event before notification
module RedmineNotificationCenter
  NotificationEvent = Struct.new(:type, :object) do
    def initialize(type, object)
      raise ArgumentError, "Unknown event type '#{type}'" unless Utils::known_event?(type)
      raise ArgumentError, "Bad object type 'Comment'" if object.respond_to?(:commented)
      super
    end

    def candidates
      NotificationCasting.new(self).candidates
    end

    def notified_users
      policy = NotificationPolicy.new(self)
      candidates.select do |candidate|
        policy.should_notify?(candidate)
      end
    end
  end
end
