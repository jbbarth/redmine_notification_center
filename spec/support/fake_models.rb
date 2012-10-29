require 'active_support/all'
require 'redmine_notification_center/user_patch'
require 'redmine_notification_center/notification_context_finder'
require 'redmine_notification_center/notification_event'
require 'redmine_notification_center/notification_policy'
require 'redmine_notification_center/utils'

class FakeUser
  include RedmineNotificationCenter::UserPatch
  attr_accessor :mail_notification
  def initialize(mail_notification); @mail_notification = mail_notification; end
  def pref; @pref ||= {}; end
  def notification_preferences=(hash); pref[:notification_preferences] = hash; end
  def is_or_belongs_to?(principal); self == principal; end
end

class FakeIssue
  def author; nil; end
  def assigned_to; nil; end
  alias :assigned_to_was :assigned_to
  def priority_id; 1; end
  alias :priority_id_was :priority_id
  def tracker_id; 1; end
  alias :tracker_id_was :tracker_id
  def watchers; []; end
end

class FakeJournal
  def initialize(issue=nil); @issue = issue; end
  def issue; @issue ||= FakeIssue.new; end
end
