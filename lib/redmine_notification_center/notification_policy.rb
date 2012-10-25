module RedmineNotificationCenter
  class NotificationPolicy
    def initialize(user)
      @user = user
    end

    def should_be_notified_for?(notification_event)
      if user_doesnt_want_any_notification
        false
      elsif user_wants_all_notifications && exceptions_dont_apply
        true
      else
        event_type, object = notification_event.type, notification_event.object
        case Utils.module_from_event(event_type)
        when :files
          files_notification_for(event_type, object)
        when :documents
          documents_notification_for(event_type, object)
        when :issue_tracking
          issue_tracking_notification_for(event_type, object)
        when :boards
          boards_notification_for(event_type, object)
        when :news
          news_notification_for(event_type, object)
        when :wiki
          wiki_notification_for(event_type, object)
        else
          #TODO: we shouldn't reach this line ; replace it with an exception when every possible event_type is handled
          raise "You should never reach this line"
        end
      end
    end

    def pref
      @pref ||= @user.notification_preferences
    end

    private
    def user_doesnt_want_any_notification
      pref[:none_at_all] == '1'
    end

    def user_wants_all_notifications
      pref[:all_events] == '1'
    end

    #TODO: exceptions! + don't use issue exceptions if issue author, issue assignee or watcher
    def exceptions_dont_apply
      true #no exception for now!
    end

    # 
    # FILES
    #
    def files_notification_for(event_type, object)
      pref[:by_module][:files] == 'all'
    end

    #
    # DOCUMENTS
    #
    def documents_notification_for(event_type, object)
      pref[:by_module][:documents] == 'all'
    end

    #
    # ISSUES
    #
    def issue_tracking_notification_for(event_type, object)
      if pref[:by_module][:issue_tracking] == 'custom'
        #TODO: handle watcher case
        if object.author == @user
          return pref[:by_module][:issue_tracking_custom][:if_author] == '1'
        end
        if object.assignee == @user || object.assignee_was == @user
          return pref[:by_module][:issue_tracking_custom][:if_assignee] == '1'
        end
        return pref[:by_module][:issue_tracking_custom][:others] == '1'
      end
      pref[:by_module][:issue_tracking] == 'all'
    end

    #
    # BOARDS
    #
    def boards_notification_for(event_type, object)
      pref[:by_module][:boards] == 'all'
    end

    #
    # NEWS
    # 
    def news_notification_for(event_type, object)
      pref[:by_module][:news] == 'all'
    end

    #
    # WIKI
    #
    def wiki_notification_for(event_type, object)
      pref[:by_module][:wiki] == 'all'
    end
  end
end
