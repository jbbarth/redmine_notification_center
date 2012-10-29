module RedmineNotificationCenter
  class NotificationPolicy
    def initialize(user)
      @user = user
    end

    def should_be_notified_for?(notification_event)
      event_type, object = notification_event.type, notification_event.object
      module_name = Utils.module_from_event(event_type)
      if user_doesnt_want_any_notification
        false
      elsif author_and_no_self_notified?(notification_event)
        false
      elsif exceptions_apply?(module_name, notification_event) && matches_a_global_exception(notification_event)
        false
      elsif exceptions_apply?(module_name, notification_event) && matches_a_role_exception(notification_event)
        false
      elsif exceptions_apply?(module_name, notification_event) && module_name == :issue_tracking && matches_an_issue_exception(notification_event)
        false
      elsif user_wants_all_notifications
        true
      else
        # delegate to module specific methods
        case module_name
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
          raise "You should never reach this line. The code might be missing an event type above ?"
        end
      end
    end

    private
    def pref
      @pref ||= @user.notification_preferences
    end

    def user_doesnt_want_any_notification
      pref[:none_at_all] == '1'
    end

    def user_wants_all_notifications
      pref[:all_events] == '1'
    end

    def exceptions_apply?(module_name, notification_event)
      if module_name == :issue_tracking
        return false if watches?(notification_event.object)
        #return false if issue_author_of?(notification_event.object)
        #return false if assigned_to?(notification_event.object)
      end
      true
    end

    def author_and_no_self_notified?(notification_event)
      pref[:exceptions][:no_self_notified] == '1' && author_of?(notification_event.object)
    end

    def matches_a_global_exception(notification_event)
      context = NotificationContextFinder.new(notification_event.object)
      if pref[:exceptions][:for_projects].present? && pref[:exceptions][:for_projects].include?(context.project_id)
        true
      else
        false
      end
    end

    def matches_a_role_exception(notification_event)
      context = NotificationContextFinder.new(notification_event.object)
      if pref[:exceptions][:for_roles].present?
        my_roles = @user.roles_for_project(context.project).map(&:id)
        excluded_roles = pref[:exceptions][:for_roles]
        not_excluded_roles = my_roles - excluded_roles
        return true if not_excluded_roles.blank?
      end
      return false
    end

    #TODO: exceptions! + don't use issue exceptions if issue author, issue assignee or watcher
    def matches_an_issue_exception(notification_event)
      if pref[:exceptions][:no_issue_updates] == '1'
        return true if notification_event.type == :issue_edited
      end
      if pref[:exceptions][:for_issue_trackers].present?
        context = NotificationContextFinder.new(notification_event.object)
        excluded = pref[:exceptions][:for_issue_trackers]
        return true if excluded.include?(context.tracker_id) && excluded.include?(context.tracker_id_was)
      end
      if pref[:exceptions][:for_issue_priorities].present?
        context = NotificationContextFinder.new(notification_event.object)
        excluded = pref[:exceptions][:for_issue_priorities]
        return true if excluded.include?(context.priority_id) && excluded.include?(context.priority_id_was)
      end
      false
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
      if pref[:by_module][:issue_tracking] == 'custom' && !watches?(object)
        if issue_author_of?(object)
          return pref[:by_module][:issue_tracking_custom][:if_author] == '1'
        end
        if assigned_to?(object)
          return pref[:by_module][:issue_tracking_custom][:if_assignee] == '1'
        end
        return pref[:by_module][:issue_tracking_custom][:others] == '1'
      end
      #case: not custom or watches issue
      #in this case, send notification for either 'all' or watches+'custom'
      pref[:by_module][:issue_tracking] != 'none'
    end

    def watches?(object)
      object.watchers.include?(@user)
    end

    def assigned_to?(object)
      @user.is_or_belongs_to?(object.assigned_to) || @user.is_or_belongs_to?(object.assigned_to_was)
    end

    def author_of?(object)
      NotificationContextFinder.new(object).author == @user
    end

    def issue_author_of?(object)
      NotificationContextFinder.new(object).issue.author == @user
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
