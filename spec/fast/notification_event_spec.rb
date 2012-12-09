require File.expand_path('../../fast_spec_helper', __FILE__)

describe RedmineNotificationCenter::NotificationEvent do

  #ease of use
  Event = RedmineNotificationCenter::NotificationEvent

  describe '#new' do
    it 'accepts some parameters' do
      expect { @evt = Event.new(:issue_added, Hash.new) }.to_not raise_error
      @evt.type.should == :issue_added
      @evt.object.should == Hash.new
    end

    it 'raises if event_type is unknown' do
      expect { Event.new(:nonexistent, Hash.new) }.to raise_error(ArgumentError)
    end
  end

  describe '#notified_users' do
    let!(:user_all) { FakeUser.new('all') }
    let!(:user_none) { FakeUser.new('none') }

    it 'includes candidate users who have notifications enabled for this event' do
      event = Event.new(:issue_added, FakeIssue.new)
      event.stub(:candidates).and_return([user_all, user_none])
      event.notified_users.should == [user_all]
    end
  end
end