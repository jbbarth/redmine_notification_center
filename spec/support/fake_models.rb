require 'active_support/all'
require 'redmine_notification_center/user_patch'
require 'redmine_notification_center/notification_event'

class FakeUser
  include RedmineNotificationCenter::UserPatch
  attr_accessor :mail_notification
  def initialize(mail_notification); @mail_notification = mail_notification; end
  def pref; {}; end
end

class FakeIssue
  def author; nil; end
  alias :author_was :author
  def assignee; nil; end
  alias :assignee_was :assignee
end