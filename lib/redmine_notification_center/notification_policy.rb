module RedmineNotificationCenter
  class NotificationPolicy
    attr_reader :event

    def initialize(notification_event)
      @event = notification_event
    end

    def should_notify?(user)
      if doesnt_want_any_notification(user)
        false
      elsif author_and_no_self_notified?(user)
        false
      elsif exceptions_apply?(user) && matches_a_global_exception(user)
        false
      elsif exceptions_apply?(user) && matches_a_role_exception(user)
        false
      elsif exceptions_apply?(user) && module_name == :issue_tracking && matches_an_issue_exception(user)
        false
      elsif wants_all_notifications(user)
        true
      else
        # delegate to module specific methods
        case module_name
        when :files
          files_notification_for(user)
        when :documents
          documents_notification_for(user)
        when :issue_tracking
          issue_tracking_notification_for(user)
        when :boards
          boards_notification_for(user)
        when :news
          news_notification_for(user)
        when :wiki
          wiki_notification_for(user)
        else
          raise "You should never reach this line. The code might be missing an event type above ?"
        end
      end
    end

    private
    def context
      @context ||= NotificationContextFinder.new(event.object)
    end

    def module_name
      @module_name ||= Utils.module_from_event(event.type)
    end

    def doesnt_want_any_notification(user)
      user.notification_preferences[:none_at_all] == '1'
    end

    def wants_all_notifications(user)
      user.notification_preferences[:all_events] == '1'
    end

    def exceptions_apply?(user)
      if module_name == :issue_tracking
        return false if watched_by?(user)
        return false if issue_author_is?(user)
        return false if assigned_to?(user)
      end
      true
    end

    def author_and_no_self_notified?(user)
      user.notification_preferences[:exceptions][:no_self_notified] == '1' && author_is?(user)
    end

    def matches_a_global_exception(user)
      project_exceptions = user.notification_preferences[:exceptions][:for_projects]
      if project_exceptions.present? && project_exceptions.include?(context.project_id)
        true
      else
        false
      end
    end

    def matches_a_role_exception(user)
      role_exceptions = user.notification_preferences[:exceptions][:for_roles]
      if role_exceptions.present?
        my_roles = user.roles_for_project(context.project).map(&:id)
        not_excluded_roles = my_roles - role_exceptions
        return true if not_excluded_roles.blank?
      end
      return false
    end

    #TODO: exceptions! + don't use issue exceptions if issue author, issue assignee or watcher
    def matches_an_issue_exception(user)
      if user.notification_preferences[:exceptions][:no_issue_updates] == '1'
        return true if event.type == :issue_edited
      end
      if user.notification_preferences[:exceptions][:for_issue_trackers].present?
        excluded = user.notification_preferences[:exceptions][:for_issue_trackers]
        return true if excluded.include?(context.tracker_id) && excluded.include?(context.tracker_id_was)
      end
      if user.notification_preferences[:exceptions][:for_issue_priorities].present?
        excluded = user.notification_preferences[:exceptions][:for_issue_priorities]
        return true if excluded.include?(context.priority_id) && excluded.include?(context.priority_id_was)
      end
      false
    end

    # 
    # FILES
    #
    def files_notification_for(user)
      user.notification_preferences[:by_module][:files] == 'all'
    end

    #
    # DOCUMENTS
    #
    def documents_notification_for(user)
      user.notification_preferences[:by_module][:documents] == 'all'
    end

    #
    # ISSUES
    #
    def issue_tracking_notification_for(user)
      if user.notification_preferences[:by_module][:issue_tracking] == 'custom' && !watched_by?(user)
        if issue_author_is?(user)
          return user.notification_preferences[:by_module][:issue_tracking_custom][:if_author] == '1'
        end
        if assigned_to?(user)
          return user.notification_preferences[:by_module][:issue_tracking_custom][:if_assignee] == '1'
        end
        return user.notification_preferences[:by_module][:issue_tracking_custom][:others] == '1'
      end
      #case: not custom or watches issue
      #in this case, send notification for either 'all' or watches+'custom'
      user.notification_preferences[:by_module][:issue_tracking] != 'none'
    end

    def watched_by?(user)
      issue.watchers.include?(user)
    end

    def assigned_to?(user)
      user.is_or_belongs_to?(issue.assigned_to) || user.is_or_belongs_to?(issue.assigned_to_was)
    end

    def author_is?(user)
      context.author == user
    end

    def issue_author_is?(user)
      issue.author == user
    end

    def issue
      context.issue
    end

    #
    # BOARDS
    #
    def boards_notification_for(user)
      user.notification_preferences[:by_module][:boards] == 'all'
    end

    #
    # NEWS
    # 
    def news_notification_for(user)
      user.notification_preferences[:by_module][:news] == 'all'
    end

    #
    # WIKI
    #
    def wiki_notification_for(user)
      user.notification_preferences[:by_module][:wiki] == 'all'
    end
  end
end
