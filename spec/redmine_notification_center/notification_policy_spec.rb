require File.expand_path('../../fast_spec_helper', __FILE__)

describe RedmineNotificationCenter::NotificationPolicy do

  #ease of use
  Policy = RedmineNotificationCenter::NotificationPolicy
  Event = RedmineNotificationCenter::NotificationEvent
  NCF = RedmineNotificationCenter::NotificationContextFinder

  describe '#should_be_notified_for?' do
    before { Event.any_instance.stub(:candidates) { [*subject] } }
    let(:model) { double('model') }
    let(:issue_where_author)   { i = FakeIssue.new; i.stub('author') { subject }; i }
    let(:issue_where_assigned) { i = FakeIssue.new; i.stub('assigned_to') { subject }; i }
    let(:issue_any)          { FakeIssue.new }

    context "user with NO notification at all" do
      subject { FakeUser.new('none') }
      its(:mail_notification) { should == 'none' }
      it { should_not receive_notifications_for(:attachments_added, model) }
      it { should_not receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, issue_any) }
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
      it { should receive_notifications_for(:issue_edited, issue_any) }
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
      it { should receive_notifications_for(:issue_edited, issue_where_author) }
      it { should receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should receive_notifications_for(:issue_edited, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, issue_any) }
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
      it { should_not receive_notifications_for(:issue_edited, issue_where_author) }
      it { should receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should receive_notifications_for(:issue_edited, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, issue_any) }
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
      it { should receive_notifications_for(:issue_edited, issue_where_author) }
      it { should_not receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_edited, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, issue_any) }
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
      it { should receive_notifications_for(:issue_edited, issue_where_author) }
      it { should receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should receive_notifications_for(:issue_edited, issue_where_assigned) }
      it { should receive_notifications_for(:issue_added, issue_any) }
      it { should receive_notifications_for(:issue_edited, issue_any) }
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
      it { should_not receive_notifications_for(:issue_edited, issue_where_author) }
      it { should_not receive_notifications_for(:issue_added, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_edited, issue_where_assigned) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, issue_any) }
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
      it { should_not receive_notifications_for(:issue_added, model) }
      it { should_not receive_notifications_for(:issue_edited, model) }
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
      it { should_not receive_notifications_for(:issue_added, model) }
      it { should_not receive_notifications_for(:issue_edited, model) }
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

      before { RedmineNotificationCenter::NotificationPolicy.any_instance.stub(:matches_a_role_exception) { true } }
      it { should_not receive_notifications_for(:attachments_added, model) }
      it { should_not receive_notifications_for(:document_added, model) }
      it { should_not receive_notifications_for(:issue_added, model) }
      it { should_not receive_notifications_for(:issue_edited, model) }
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
      it { should receive_notifications_for(:issue_added, model) }
      it { should_not receive_notifications_for(:issue_edited, model) }
    end

    context "user don't want notifications for some trackers" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_issue_trackers => [1]} })
        end
      end
      before { NCF.any_instance.stub(:tracker_id) { 1 } }

      it { should_not receive_notifications_for(:issue_added, model) }
      it { should_not receive_notifications_for(:issue_edited, model) }
    end

    context "user don't want notifications for some issue priorities" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_issue_priorities => [1]} })
        end
      end
      before { NCF.any_instance.stub(:priority_id) { 1 } }

      it { should_not receive_notifications_for(:issue_added, model) }
      it { should_not receive_notifications_for(:issue_edited, model) }
    end

    context "user don't want notifications for some issue priorities and trackers" do
      subject do
        FakeUser.new('all').tap do |user|
          user.notification_preferences=({:exceptions => {:for_issue_priorities => [1], :for_issue_trackers => [1]} })
        end
      end

      it "doesn't block the other exception if first doesn't validate" do
        NCF.any_instance.stub(:tracker_id) { 2 }
        NCF.any_instance.stub(:priority_id) { 1 }
        subject.should_not receive_notifications_for(:issue_added, model)
      end
    end
  end
end
