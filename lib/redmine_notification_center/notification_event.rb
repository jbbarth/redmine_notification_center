# Turns an A::R object into an event before notification
module RedmineNotificationCenter
  class NotificationEvent < Struct.new(:type, :object)
    def initialize(type, object)
      raise ArgumentError, "Unknown event type '#{type}'" unless Utils::known_event?(type)
      super
    end

    def candidates
      raise "TODO"
    end

    def notified_users
      policy = NotificationPolicy.new(self)
      candidates.select do |candidate|
        policy.should_notify?(candidate)
      end
    end
  end
end
