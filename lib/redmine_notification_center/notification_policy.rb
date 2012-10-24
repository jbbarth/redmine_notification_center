module RedmineNotificationCenter
  class NotificationPolicy
    def initialize(user)
      @user = user
    end

    def should_be_notified_for?(notification_event)
      event_type, object = notification_event.type, notification_event.object
      notif = @user.notification_preferences
      return false if notif[:none_at_all] == '1'
      #TODO: exceptions! + don't use issue exceptions if issue author, issue assignee or watcher
      return true if notif[:all_events] == '1'
      #TODO: return true or false immediately if module identified && by_module.<module> == 'all' or 'none'
      #custom modules
      if [:issue_added, :issue_edited].include?(event_type) && notif[:by_module][:issue_tracking] == 'custom'
        #TODO: handle watcher case
        if object.author == @user || object.author_was == @user
          return notif[:by_module][:issue_tracking_custom][:if_author] == '1'
        end
        if object.assignee == @user || object.assignee_was == @user
          return notif[:by_module][:issue_tracking_custom][:if_assignee] == '1'
        end
        return notif[:by_module][:issue_tracking_custom][:others] == '1'
      end
      #TODO: we shouldn't reach this line ; replace it with an exception when every possible event_type is handled
      true
    end
  end
end
