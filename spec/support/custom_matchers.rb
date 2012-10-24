RSpec::Matchers.define :receive_notifications_for do |*args|
  match do |user|
    RedmineNotificationCenter::NotificationEvent.new(*args).recipients.include?(user)
  end
end
