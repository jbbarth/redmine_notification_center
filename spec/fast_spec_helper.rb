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

#rspec base config
RSpec.configure do |config|
  config.mock_with :rspec
end

#support things
require File.expand_path('../support/fake_models', __FILE__)
require File.expand_path('../support/custom_matchers', __FILE__)
