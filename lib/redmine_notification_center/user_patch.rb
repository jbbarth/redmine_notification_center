module RedmineNotificationCenter
  module UserPatch
    extend ActiveSupport::Concern

    DEFAULT_NOTIFICATION_OPTIONS = {
      :none_at_all => '0', :all_events  => '1', :other_notification_address => nil,
      :by_module   => {
        :issues    => 'all', :issues_custom => { :if_author => '1', :if_assignee => '1', :others => '1' },
        :new       => 'all',
        :documents => 'all',
        :files     => 'all',
        :boards    => 'all',
        :wiki      => 'all'
      },
      :exceptions => {
        :for_projects => [], :for_roles => [], :for_issue_trackers => [], :for_issue_priorities => [],
        :no_self_notified => '0', :no_issue_updates => '0'
      }
    }

    def notification_preferences
      DEFAULT_NOTIFICATION_OPTIONS.deep_merge(pref[:notification_preferences] || translate_from_old_mail_notification)
    end

    #TODO: needs refactoring
    def wants_notifications_for(notification_event)
      event, object = notification_event.type, notification_event.object
      notif = notification_preferences
      return false if notif[:none_at_all] == '1'
      #TODO: exceptions! + don't use issue exceptions if issue author, issue assignee or watcher
      return true if notif[:all_events] == '1'
      #TODO: return true or false immediately if module identified && by_module.<module> == 'all' or 'none'
      #custom modules
      if [:issue_added, :issue_edited].include?(event) && notif[:by_module][:issues] == 'custom'
        #TODO: handle watcher case
        if object.author == self || object.author_was == self
          return notif[:by_module][:issues_custom][:if_author] == '1'
        end
        if object.assignee == self || object.assignee_was == self
          return notif[:by_module][:issues_custom][:if_assignee] == '1'
        end
        return notif[:by_module][:issues_custom][:others] == '1'
      end
      #TODO: we shouldn't reach this line ; replace it with an exception when every possible event is handled
      true
    end

    private
    def translate_from_old_mail_notification
      #we use Hash#deep_dup here so that internal hashes are not changed
      options = DEFAULT_NOTIFICATION_OPTIONS.deep_dup
      case mail_notification
      when 'all'
        #nothing to do
      when 'only_my_events'
        options[:all_events] = '0'
        options[:by_module][:issues] = 'custom'
        options[:by_module][:issues_custom][:others] = '0'
      when 'only_assigned'
        options[:all_events] = '0'
        options[:by_module][:issues] = 'custom'
        options[:by_module][:issues_custom][:others] = '0'
        options[:by_module][:issues_custom][:if_author] = '0'
      when 'only_owner'
        options[:all_events] = '0'
        options[:by_module][:issues] = 'custom'
        options[:by_module][:issues_custom][:others] = '0'
        options[:by_module][:issues_custom][:if_assignee] = '0'
      when 'none'
        options[:none_at_all] = '1'
      end
      options
    end
  end
end
