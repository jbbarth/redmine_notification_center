require File.dirname(__FILE__) + '/../test_helper'

class NotificationPreferencesControllerTest < ActionController::TestCase
  fixtures :users, :user_preferences

  def setup
    @request.session[:user_id] = 1 #permissions don't matter
    User.current = User.find(1)
  end

  def assert_preference(expected, keys)
    value = keys.inject(User.current.notification_preferences) do |hsh, key|
      hsh = hsh[key.to_sym]
    end
    assert_equal expected, value, "Bad value for #{keys.join('.')}, expected #{expected.inspect}, got #{value.inspect}"
  end

  # {"pref"=>{"all_events"=>"1", "by_module"=>{"issue_tracking_custom"=>{"if_author"=>"1", "if_assignee"=>"1", "others"=>"1"}},
  #           "other_notification_address"=>""}}
  context 'PUT /my/notification_preferences' do
    should 'redirect to /my/account?tab=notifications' do
      put :update
      assert_redirected_to :controller => 'my', :action => 'account', :tab => 'notifications'
    end

    context ':all_events option' do
      should 'be set if box is checked' do
        put :update, 'pref' => { 'all_events' => '1' }
        assert_response :redirect
        assert_preference '1', %w(all_events)
      end

      should 'be unset if box is not checked' do
        put :update, 'pref' => {}
        assert_response :redirect
        assert_preference '0', %w(all_events)
      end
    end

    context ':none_at_all option' do
      should 'be set if box is checked' do
        put :update, 'pref' => { 'none_at_all' => '1' }
        assert_response :redirect
        assert_preference '1', %w(none_at_all)
      end

      should 'be unset if box is not checked' do
        put :update, 'pref' => {}
        assert_response :redirect
        assert_preference '0', %w(none_at_all)
      end
    end

    context ':by_module :issue_tracking option' do
    end

    context ':exceptions :for_projects' do
      should 'set empty value if no match' do
        put :update, 'pref' => {}
        assert_response :redirect
        assert_preference [], %w(exceptions for_projects)
      end

      should 'transform keys to integers' do
        put :update, 'pref' => { 'exceptions' => { 'for_projects' => %w(1 2 4) } }
        assert_response :redirect
        assert_preference [1,2,4], %w(exceptions for_projects)
      end

      should 'back to empty array if no match' do
        pref = User.current.pref
        pref[:notification_preferences] = { :exceptions => { :for_projects => [1,2] } }
        pref.save!
        assert_preference [1,2], %w(exceptions for_projects)
        put :update, 'pref' => {}
        assert_response :redirect
        assert_preference [], %w(exceptions for_projects)
      end
    end

    context ':other_notification_address' do
      should 'set other_notification_address if checkbox is checked and address is present' do
        put :update, 'pref' => { 'other_notification_address' => 'blah@example.net', 'other_notification_address_check' => '1' }
        assert_response :redirect
        assert_preference 'blah@example.net', %w(other_notification_address)
      end

      should 'empty other_notification_address if checkbox is not checked' do
        put :update, 'pref' => { 'other_notification_address' => 'blah@example.net' }
        assert_response :redirect
        assert_preference '', %w(other_notification_address)
      end

      should 'strip other_notification_address if set' do
        put :update, 'pref' => { 'other_notification_address' => ' blah@example.net   ', 'other_notification_address_check' => '1' }
        assert_response :redirect
        assert_preference 'blah@example.net', %w(other_notification_address)
      end
    end
  end

  context '#params_pref' do
    setup do
      @controller = NotificationPreferencesController.new
    end

    should 'be a zero hash if nil'
  end

  context '#deep_symbolize(hash)' do
    setup do
      @controller = NotificationPreferencesController.new
    end

    should 'symbolize keys for standard hashes' do
      assert_equal ({:a=>1, :b=>2}), @controller.send(:deep_symbolize, {"a"=>1, :b=>2})
    end

    should 'symbolize keys for sub hashes too' do
      assert_equal ({:a=>1, :b=>{:c=>3}}), @controller.send(:deep_symbolize, {"a"=>1, :b=>{"c"=>3}})
    end
  end
end
