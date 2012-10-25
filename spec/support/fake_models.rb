require 'active_support/all'
require 'redmine_notification_center/user_patch'
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
end
