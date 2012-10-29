require File.dirname(__FILE__) + '/../../test_helper'

class NotificationPolicyTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :issues, :journals,
           :groups_users, :trackers, :projects_trackers, :enabled_modules,
           :wikis, :wiki_pages, :wiki_contents, :documents, :attachments, :boards,
           :messages, :news, :comments

  context '#matches_a_role_exception' do
    setup do
      # issue(10) belongs to project(5), where user(8) has role(1)+role(2)
      @user = User.find(8)
      @user.update_attribute(:mail_notification, 'all')
      @event = RedmineNotificationCenter::NotificationEvent.new(:issue_added, Issue.find(10))
      @policy = RedmineNotificationCenter::NotificationPolicy.new(@event)
    end

    should 'be falsy if no role exception' do
      @user.pref[:notification_preferences] = {:exceptions => {:for_roles => []} }
      @user.pref.save
      assert !@policy.send(:matches_a_role_exception, @user)
      assert @policy.should_notify?(@user)
    end

    should 'be truthy if all roles for this projects are in exception' do
      @user.pref[:notification_preferences] = {:exceptions => {:for_roles => [1,2]} }
      @user.pref.save
      assert @policy.send(:matches_a_role_exception, @user)
      assert !@policy.should_notify?(@user)
    end

    should 'be falsy if at least one role is not in exception' do
      @user.pref[:notification_preferences] = {:exceptions => {:for_roles => [2,3]} }
      @user.pref.save
      assert !@policy.send(:matches_a_role_exception, @user)
      assert @policy.should_notify?(@user)
    end
  end
end
