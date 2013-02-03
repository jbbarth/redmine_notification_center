# matches is a user receives notifications for a notification event
RSpec::Matchers.define :receive_notifications_for do |*args|
  match do |user|
    RedmineNotificationCenter::NotificationEvent.new(*args).to_notified_users.include?(user)
  end
end

# passes if a file checksum corresponds
require 'digest/md5'
RSpec::Matchers.define :have_checksum do |*args|
  match do |filename|
    filepath = File.expand_path('../../../../../'+filename, __FILE__)
    checksum = Digest::MD5.hexdigest(File.read(filepath))
    checksum.should == args.first
    #"Bad checksum for file: #{filepath}"
  end
end
