require File.dirname(__FILE__) + '/../../test_helper'

class RedmineNotificationCenterProcessorTest < ActiveSupport::TestCase
  fixtures :users, :user_preferences

  setup do
    @user = User.find(1) #permissions don't matter
  end

###  context "#" do
###    should "return 120 by default " do
###      assert_equal 120, RedmineRefresh.refresh_interval_for(@user)
###    end

###    should "return second params if >= 10" do
###      assert_equal 10, RedmineRefresh.refresh_interval_for(@user, "10")
###      assert_equal 12, RedmineRefresh.refresh_interval_for(@user, 12)
###    end

###    should "not return second param if not >= 10" do
###      assert_equal 120, RedmineRefresh.refresh_interval_for(@user, 9)
###      assert_equal 120, RedmineRefresh.refresh_interval_for(@user, "abcd")
###      assert_equal 120, RedmineRefresh.refresh_interval_for(@user, -20)
###    end
###  end
end
