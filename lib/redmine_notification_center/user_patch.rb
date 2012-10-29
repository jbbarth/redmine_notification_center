module RedmineNotificationCenter
  module UserPatch
    extend ActiveSupport::Concern

    DEFAULT_NOTIFICATION_OPTIONS = {
      :none_at_all => '0', :all_events  => '1', :other_notification_address => nil,
      :by_module   => {
        :issue_tracking    => 'all', :issue_tracking_custom => { :if_author => '1', :if_assignee => '1', :others => '1' },
        :news      => 'all',
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

    private
    def translate_from_old_mail_notification
      #we use Hash#deep_dup here so that internal hashes are not changed
      options = DEFAULT_NOTIFICATION_OPTIONS.deep_dup
      case mail_notification
      when 'all'
        #nothing to do
      when 'only_my_events'
        options[:all_events] = '0'
        options[:by_module][:issue_tracking] = 'custom'
        options[:by_module][:issue_tracking_custom][:others] = '0'
      when 'only_assigned'
        options[:all_events] = '0'
        options[:by_module][:issue_tracking] = 'custom'
        options[:by_module][:issue_tracking_custom][:others] = '0'
        options[:by_module][:issue_tracking_custom][:if_author] = '0'
      when 'only_owner'
        options[:all_events] = '0'
        options[:by_module][:issue_tracking] = 'custom'
        options[:by_module][:issue_tracking_custom][:others] = '0'
        options[:by_module][:issue_tracking_custom][:if_assignee] = '0'
      when 'none'
        options[:none_at_all] = '1'
      end
      options
    end
  end
end
