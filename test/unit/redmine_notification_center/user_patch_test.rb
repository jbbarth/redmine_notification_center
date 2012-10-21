require File.dirname(__FILE__) + '/../../test_helper'
require 'redmine_notification_center/user_patch'

class UserPatchTest < ActiveSupport::TestCase
  fixtures :users, :user_preferences, :roles, :projects, :trackers

  context '#notification_preferences' do
    should 'fallback to default options if empty' do
      assert_equal '1', User.find(1).notification_preferences[:all_events]
    end

    should 'deep merge default options so that adding new items works' do
      pref = User.find(1).pref
      pref[:notification_preferences] = {} #a lot of keys missing!
      pref.save
      assert_equal '1', User.find(1).notification_preferences[:all_events]
    end

    context 'smooth transition' do
      should ':all' do
        User.find(1).update_attribute(:mail_notification, 'none')
        assert_equal '1', User.find(1).notification_preferences[:all_events]
      end

      should ':selected'

      should ':only_my_events' do
        User.find(1).update_attribute(:mail_notification, 'only_my_events')
        pref = User.find(1).notification_preferences
        assert_equal '0', pref[:all_events], 'all_events'
        assert_equal '0', pref[:none_at_all], 'none_at_all'
        assert_equal 'custom', pref[:by_module][:issues], 'by_module issues'
        assert_equal '1', pref[:by_module][:issues_custom][:if_author], 'issues_custom if_author'
        assert_equal '1', pref[:by_module][:issues_custom][:if_assignee], 'issues_custom if_assignee'
        assert_equal '0', pref[:by_module][:issues_custom][:others], 'issues_custom others'
      end

      should ':only_assigned' do
        User.find(1).update_attribute(:mail_notification, 'only_assigned')
        pref = User.find(1).notification_preferences
        assert_equal '0', pref[:all_events], 'all_events'
        assert_equal '0', pref[:none_at_all], 'none_at_all'
        assert_equal 'custom', pref[:by_module][:issues], 'by_module issues'
        assert_equal '0', pref[:by_module][:issues_custom][:if_author], 'issues_custom if_author'
        assert_equal '1', pref[:by_module][:issues_custom][:if_assignee], 'issues_custom if_assignee'
        assert_equal '0', pref[:by_module][:issues_custom][:others], 'issues_custom others'
      end

      should ':only_owner' do
        User.find(1).update_attribute(:mail_notification, 'only_owner')
        pref = User.find(1).notification_preferences
        assert_equal '0', pref[:all_events], 'all_events'
        assert_equal '0', pref[:none_at_all], 'none_at_all'
        assert_equal 'custom', pref[:by_module][:issues], 'by_module issues'
        assert_equal '1', pref[:by_module][:issues_custom][:if_author], 'issues_custom if_author'
        assert_equal '0', pref[:by_module][:issues_custom][:if_assignee], 'issues_custom if_assignee'
        assert_equal '0', pref[:by_module][:issues_custom][:others], 'issues_custom others'
      end

      should 'block all notifications if :none' do
        assert_equal '0', User.find(1).notification_preferences[:none_at_all], 'none_at_all'
        User.find(1).update_attribute(:mail_notification, 'none')
        assert_equal '1', User.find(1).notification_preferences[:none_at_all], 'none_at_all 2'
      end

      should 'default to default_notification_options if blank' do
        User.find(1).update_attribute(:mail_notification, '')
        assert_equal User::DEFAULT_NOTIFICATION_OPTIONS, User.find(1).notification_preferences
      end
    end
  end
end
