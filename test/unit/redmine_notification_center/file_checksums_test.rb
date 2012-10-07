require File.dirname(__FILE__) + '/../../test_helper'
require 'digest/md5'

class FileChecksumsTest < ActiveSupport::TestCase
  def assert_checksum(expected_checksum, filename)
    filepath = Rails.root.join(filename)
    checksum = Digest::MD5.hexdigest(File.read(filepath))
    assert_equal expected_checksum, checksum, "Bad checksum for file: #{filepath}"
  end

  test 'Mailer file checksum' do
    # the main thing ! if it changes, we're absolutely sure we need an update
    # on our code
    assert_checksum 'be31d197e1388230ff52d8c9df1500ac', 'app/models/mailer.rb'
  end

  test 'object model files checksums' do
    # all these models can have an impact on notifications / permissions / visibilities / etc.
    assert_checksum 'be31d197e1388230ff52d8c9df1500ac', 'app/models/mailer.rb'
    assert_checksum '3384be003b7ed5a3ccfcd3342c7d3179', 'app/models/board.rb'
    assert_checksum 'fe6da8f542f9f18218d4a73e36747390', 'app/models/document.rb'
    assert_checksum '94b0114e530bee1cff656125c222ff4e', 'app/models/issue.rb'
    assert_checksum 'f5badcc65d1ff0d547edd95cf24f9fdf', 'app/models/journal.rb'
    assert_checksum '925f26e6f93e3d269acedfb107f3a2ba', 'app/models/message.rb'
    assert_checksum '1c4fc664e4d04ebeefa9fef5aa4abd5d', 'app/models/news.rb'
    assert_checksum 'c47ff0e1aee1d03e68d919ca8a685381', 'app/models/project.rb'
    assert_checksum '188899242a7509fc0d5b436911d1b4e1', 'app/models/user.rb'
    assert_checksum 'bdbb6a401474f75711f89f2d1e9b3c3b', 'app/models/user_preference.rb'
    assert_checksum '1089f1a7801364274a4e6a98ddcaef3c', 'app/models/watcher.rb'
    assert_checksum '8ed7bfd40c2fcbdb8b4435dfb0644f50', 'app/models/wiki.rb'
    assert_checksum 'e129ca603c33d920800aeeee82ed6ef3', 'app/models/wiki_content.rb'
    assert_checksum '87f21707409dc68b1c169b6547f966d4', 'app/models/wiki_page.rb'
  end
end
