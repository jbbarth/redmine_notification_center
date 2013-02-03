require File.expand_path('../../fast_spec_helper', __FILE__)

describe RedmineNotificationCenter::NotificationEvent do

  #ease of use
  Event = RedmineNotificationCenter::NotificationEvent

  let(:user_all) { FakeUser.new('all') }
  let(:user_all2) { FakeUser.new('all') }
  let(:user_none) { FakeUser.new('none') }

  describe '#new' do
    it 'accepts some parameters' do
      expect { @evt = Event.new(:issue_added, Hash.new) }.to_not raise_error
      @evt.type.should == :issue_added
      @evt.object.should == Hash.new
    end

    it 'raises if event_type is unknown' do
      expect { Event.new(:nonexistent, Hash.new) }.to raise_error(ArgumentError)
    end

    it 'raises if object respond to #commented' do
      #we should use the commented model in those cases, not the comment itself
      comment = stub(:commented => stub)
      expect { Event.new(:news_comment_added, comment) }.to raise_error(ArgumentError)
    end
  end

  describe '#candidates' do
    it 'delegates to a NotificationCasting object' do
      event = Event.new(:issue_added, stub)
      RedmineNotificationCenter::NotificationCasting.any_instance.should_receive(:candidates)
                                                                 .and_return(['joe'])
      event.candidates.should == ['joe']
    end
  end

  describe '#watcher_candidates' do
    it 'delegates to a NotificationPolicy object' do
      event = Event.new(:issue_added, stub)
      RedmineNotificationCenter::NotificationCasting.any_instance.should_receive(:watcher_candidates)
                                                                 .and_return(['bob'])
      event.watcher_candidates.should == ['bob']
    end
  end

  describe '#to_notified_users' do
    it 'includes candidate users who have notifications enabled for this event' do
      event = Event.new(:issue_added, FakeIssue.new)
      event.stub(:candidates).and_return([user_all, user_none])
      event.to_notified_users.should == [user_all]
    end
  end

  describe '#cc_notified_users' do
    it 'includes watcher_candidates who are not candidates and have notification enabled for this event' do
      event = Event.new(:issue_added, FakeIssue.new)
      event.stub(:candidates).and_return([user_all, user_none])
      event.stub(:watcher_candidates).and_return([user_all2, user_all, user_none])
      event.cc_notified_users.should == [user_all2]
    end
  end

  describe '#all_notified_users' do
    it 'returns an array structure to differentiate :cc and :to users' do
      event = Event.new(:issue_added, FakeIssue.new)
      event.stub(:candidates).and_return([user_all, user_none])
      event.stub(:watcher_candidates).and_return([user_all2, user_none])
      event.all_notified_users.should == [[user_all], [user_all2]]
    end

    it 'removes :to users from :cc' do
      event = Event.new(:issue_added, FakeIssue.new)
      event.stub(:candidates).and_return([user_all, user_none])
      event.stub(:watcher_candidates).and_return([user_all, user_all2, user_none])
      event.all_notified_users.should == [[user_all], [user_all2]]
    end
  end
end
