require File.expand_path('../../fast_spec_helper', __FILE__)

describe RedmineNotificationCenter::NotificationPolicy do

  #ease of use
  Policy = RedmineNotificationCenter::NotificationPolicy
  Event = RedmineNotificationCenter::NotificationEvent
  NCF = RedmineNotificationCenter::NotificationContextFinder

  describe '#should_be_notified_for?' do
    before { Event.any_instance.stub(:candidates) { [*subject] } }
    let(:model)                   { double('model') }
    let(:issue_where_author)      { i = FakeIssue.new; i.stub('author') { subject }; i }
    let(:issue_where_assigned)    { i = FakeIssue.new; i.stub('assigned_to') { subject }; i }
    let(:issue_watched)           { i = FakeIssue.new; i.stub('watchers') { [subject] }; i }
    let(:issue_any)               { FakeIssue.new }
    let(:journal_where_author)    { FakeJournal.new(issue_where_author) }
    let(:journal_where_assigned)  { FakeJournal.new(issue_where_assigned) }
    let(:journal_watched)         { FakeJournal.new(issue_watched) }
    let(:journal_any)             { FakeJournal.new }

    context "user with NO notification at all" do
      subject { FakeUser.new('none') }
      its(:mail_notification) { should == 'none' }
      it { should_not receive_notifications_for(:attachments_added, model) }
      it { should_not receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should_not receive_notifications_for(:message_posted, model) }
      it { should_not receive_notifications_for(:news_added, model) }
      it { should_not receive_notifications_for(:news_comment_added, model) }
      it { should_not receive_notifications_for(:wiki_content_added, model) }
      it { should_not receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user with ALL notifications" do
      subject { FakeUser.new('all') }
      its(:mail_notification) { should == 'all' }
      it { should receive_notifications_for(:attachments_added, model) }
      it { should receive_notifications_for(:document_added, model) }
      it { should receive_notifications_for(:issue_added, issue_any) }
      it { should receive_notifications_for(:issue_edited, journal_any) }
      it { should receive_notifications_for(:message_posted, model) }
      it { should receive_notifications_for(:news_added, model) }
      it { should receive_notifications_for(:news_comment_added, model) }
      it { should receive_notifications_for(:wiki_content_added, model) }
      it { should receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user with mail_notification for 'only_my_events'" do
      subject { FakeUser.new('only_my_events') }
      its(:mail_notification) { should == 'only_my_events' }
      it { should receive_notifications_for(:attachments_added, model) }
      it { should receive_notifications_for(:document_added, model) }
      it { should receive_notifications_for(:issue_added, issue_where_author) }
      it { should receive_notifications_for(:issue_edited, journal_where_author) }
      it { should receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should receive_notifications_for(:issue_edited, journal_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should receive_notifications_for(:message_posted, model) }
      it { should receive_notifications_for(:news_added, model) }
      it { should receive_notifications_for(:news_comment_added, model) }
      it { should receive_notifications_for(:wiki_content_added, model) }
      it { should receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user with mail_notification for 'only_assigned'" do
      subject { FakeUser.new('only_assigned') }
      its(:mail_notification) { should == 'only_assigned' }
      it { should receive_notifications_for(:attachments_added, model) }
      it { should receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, issue_where_author) }
      it { should_not receive_notifications_for(:issue_edited, journal_where_author) }
      it { should receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should receive_notifications_for(:issue_edited, journal_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should receive_notifications_for(:message_posted, model) }
      it { should receive_notifications_for(:news_added, model) }
      it { should receive_notifications_for(:news_comment_added, model) }
      it { should receive_notifications_for(:wiki_content_added, model) }
      it { should receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user with mail_notification for 'only_owner'" do
      subject { FakeUser.new('only_owner') }
      its(:mail_notification) { should == 'only_owner' }
      it { should receive_notifications_for(:attachments_added, model) }
      it { should receive_notifications_for(:document_added, model) }
      it { should receive_notifications_for(:issue_added, issue_where_author) }
      it { should receive_notifications_for(:issue_edited, journal_where_author) }
      it { should_not receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_edited, journal_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should receive_notifications_for(:message_posted, model) }
      it { should receive_notifications_for(:news_added, model) }
      it { should receive_notifications_for(:news_comment_added, model) }
      it { should receive_notifications_for(:wiki_content_added, model) }
      it { should receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user with all notifications, but didn't check 'all events'" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:all_events => '0'})
        end
      end
      it { should receive_notifications_for(:attachments_added, model) }
      it { should receive_notifications_for(:document_added, model) }
      it { should receive_notifications_for(:issue_added, issue_where_author) }
      it { should receive_notifications_for(:issue_edited, journal_where_author) }
      it { should receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should receive_notifications_for(:issue_edited, journal_where_assigned) }
      it { should receive_notifications_for(:issue_added, issue_any) }
      it { should receive_notifications_for(:issue_edited, journal_any) }
      it { should receive_notifications_for(:message_posted, model) }
      it { should receive_notifications_for(:news_added, model) }
      it { should receive_notifications_for(:news_comment_added, model) }
      it { should receive_notifications_for(:wiki_content_added, model) }
      it { should receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user with no notification, but didn't check 'none at all'" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({
            :all_events => '0',
            :by_module => { :issue_tracking => 'none', :files => 'none', :documents => 'none',
                            :news=>'none', :wiki => 'none', :boards => 'none' }
          })
        end
      end
      it { should_not receive_notifications_for(:attachments_added, model) }
      it { should_not receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, issue_where_author) }
      it { should_not receive_notifications_for(:issue_edited, journal_where_author) }
      it { should_not receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_edited, journal_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should_not receive_notifications_for(:message_posted, model) }
      it { should_not receive_notifications_for(:news_added, model) }
      it { should_not receive_notifications_for(:news_comment_added, model) }
      it { should_not receive_notifications_for(:wiki_content_added, model) }
      it { should_not receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user don't want notifications for things he changes" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:no_self_notified => '1'} })
        end
      end

      before { NCF.any_instance.stub(:author) { subject } }
      it { should_not receive_notifications_for(:attachments_added, model) }
      it { should_not receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should_not receive_notifications_for(:message_posted, model) }
      it { should_not receive_notifications_for(:news_added, model) }
      it { should_not receive_notifications_for(:news_comment_added, model) }
      it { should_not receive_notifications_for(:wiki_content_added, model) }
      it { should_not receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user don't want notifications for some projects" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_projects => [1]} })
        end
      end

      before { NCF.any_instance.stub(:project_id) { 1 } }
      it { should_not receive_notifications_for(:attachments_added, model) }
      it { should_not receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should_not receive_notifications_for(:message_posted, model) }
      it { should_not receive_notifications_for(:news_added, model) }
      it { should_not receive_notifications_for(:news_comment_added, model) }
      it { should_not receive_notifications_for(:wiki_content_added, model) }
      it { should_not receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user don't want notifications for some roles" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_roles => [1]} })
        end
      end

      before { Policy.any_instance.stub(:matches_a_role_exception) { true } }
      it { should_not receive_notifications_for(:attachments_added, model) }
      it { should_not receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
      it { should_not receive_notifications_for(:message_posted, model) }
      it { should_not receive_notifications_for(:news_added, model) }
      it { should_not receive_notifications_for(:news_comment_added, model) }
      it { should_not receive_notifications_for(:wiki_content_added, model) }
      it { should_not receive_notifications_for(:wiki_content_updated, model) }
    end

    context "user don't want notifications for issue updates" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:no_issue_updates => '1'} })
        end
      end

      it { should receive_notifications_for(:attachments_added, model) }
      it { should receive_notifications_for(:document_added, model) }
      it { should receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
    end

    context "user don't want notifications for some trackers" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_issue_trackers => [1]} })
        end
      end
      before { NCF.any_instance.stub(:issue) { FakeIssue.new } }

      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
    end

    context "user don't want notifications for some issue priorities" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_issue_priorities => [1]} })
        end
      end
      before { NCF.any_instance.stub(:issue) { FakeIssue.new } }

      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, journal_any) }
    end

    context "user don't want notifications for some issue priorities and trackers" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_issue_trackers => [2], :for_issue_priorities => [1]} })
        end
      end

      it "doesn't block the other exception if first doesn't validate" do
        NCF.any_instance.stub(:issue) { FakeIssue.new }
        subject.should_not receive_notifications_for(:issue_added, issue_any)
        subject.should_not receive_notifications_for(:issue_edited, journal_any)
      end
    end

    context "when user is watcher of an issue" do
      subject { FakeUser.new('all') }

      it "blocks notification if user don't want any notification at all" do
        subject.mail_notification = 'none'
        subject.should_not receive_notifications_for(:issue_added, issue_watched)
        subject.should_not receive_notifications_for(:issue_edited, journal_watched)
      end

      it "blocks notification if user don't want any issue notification" do
        subject.notification_preferences = { :all_events => '0', :by_module => { :issue_tracking => 'none' } }
        subject.should_not receive_notifications_for(:issue_added, issue_watched)
        subject.should_not receive_notifications_for(:issue_edited, journal_watched)
      end

      it "blocks notification if user blocks his own notification and he's author of this event" do
        NCF.any_instance.stub(:author) { subject }
        subject.notification_preferences = { :all_events => '0', :by_module => { :issue_tracking => 'custom' },
                                             :exceptions => { :no_self_notified => '1' } }
        subject.should_not receive_notifications_for(:issue_added, issue_watched)
        subject.should_not receive_notifications_for(:issue_edited, journal_watched)
      end

      it "sends notification if user allows some notifications" do
        subject.notification_preferences = { :all_events => '0', :by_module => { :issue_tracking => 'custom',
                                             :issue_tracking_custom => { :if_author => "0", :if_assignee => "0", :others => "0" } } }
        subject.should receive_notifications_for(:issue_added, issue_watched)
        subject.should receive_notifications_for(:issue_edited, journal_watched)
      end

      it "sends notification even if user has an exception on that case" do
        #for the sake of simplicity, we put all possible exceptions and see if notification is sent
        NCF.any_instance.stub(:project_id) { 1 }
        Policy.any_instance.stub(:matches_a_role_exception) { true }
        subject.notification_preferences = { :exceptions => { :for_projects => [1],
                                                              :no_issue_updates => "1",
                                                              :for_issue_trackers => [1],
                                                              :for_issue_priorities => [1] } }
        subject.should receive_notifications_for(:issue_added, issue_watched)
        subject.should receive_notifications_for(:issue_edited, journal_watched)
      end
    end

    context "when user is the author or assigned on an issue" do
      subject { FakeUser.new('all') }

      it "doesn't take exceptions into account if user allows some notifications" do
        NCF.any_instance.stub(:project_id) { 1 }
        Policy.any_instance.stub(:matches_a_role_exception) { true }
        subject.notification_preferences = { :exceptions => { :for_projects => [1],
                                                              :no_issue_updates => "1",
                                                              :for_issue_trackers => [1],
                                                              :for_issue_priorities => [1] } }
        subject.should receive_notifications_for(:issue_added, issue_where_author)
        subject.should receive_notifications_for(:issue_added, issue_where_assigned)
        subject.should receive_notifications_for(:issue_edited, journal_where_author)
        subject.should receive_notifications_for(:issue_edited, journal_where_assigned)
      end
    end
  end
end
