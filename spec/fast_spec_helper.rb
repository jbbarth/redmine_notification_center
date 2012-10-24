ENV["RAILS_ENV"] ||= 'test'

#test gems
require 'rspec'
require 'rspec/autorun'
require 'rspec/mocks'
require 'rspec/mocks/standalone'
require 'pry'

#load paths
$:.<< File.expand_path('../../app/models', __FILE__)
$:.<< File.expand_path('../../lib', __FILE__)

#rspec config
RSpec.configure do |config|
  config.mock_with :rspec
end

#custom matchers
RSpec::Matchers.define :receive_notifications_for do |*args|
  match do |user|
    RedmineNotificationCenter::Event.new(*args).recipients.include?(user)
  end
end
