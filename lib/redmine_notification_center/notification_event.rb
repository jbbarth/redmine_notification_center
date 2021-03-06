# Turns an A::R object into an event before notification
module RedmineNotificationCenter
  NotificationEvent = Struct.new(:type, :object) do
    def initialize(type, object)
      raise ArgumentError, "Unknown event type '#{type}'" unless Utils::known_event?(type)
      raise ArgumentError, "Bad object type 'Comment'" if object.respond_to?(:commented)
      super
    end

    def candidates
      casting.candidates
    end

    def watcher_candidates
      casting.watcher_candidates
    end

    def to_notified_users
      candidates.select do |candidate|
        notified?(candidate)
      end
    end

    def cc_notified_users
      (watcher_candidates - candidates).select do |candidate|
        notified?(candidate)
      end
    end

    def all_notified_users
      [to_notified_users, cc_notified_users]
    end

    def all_recipients
      [to_notified_users.map(&:mail), cc_notified_users.map(&:mail)]
    end

    private
    def policy
      @policy ||= NotificationPolicy.new(self)
    end

    def casting
      @casting ||= NotificationCasting.new(self)
    end

    def notified?(candidate)
      policy.should_notify?(candidate)
    end
  end
end
