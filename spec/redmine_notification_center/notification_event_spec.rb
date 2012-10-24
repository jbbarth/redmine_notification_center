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

  describe '#recipients' do
    before { Event.any_instance.stub(:candidates) { [*subject] } }
    let(:model) { double('model') }
    let(:issue_where_author)   { i = FakeIssue.new; i.stub('author') { subject }; i }
    let(:issue_where_assignee) { i = FakeIssue.new; i.stub('assignee') { subject }; i }
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
      it { should receive_notifications_for(:issue_added, issue_where_assignee) }
      it { should receive_notifications_for(:issue_edited, issue_where_assignee) }
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
      it { should receive_notifications_for(:issue_added, issue_where_assignee) }
      it { should receive_notifications_for(:issue_edited, issue_where_assignee) }
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
      it { should_not receive_notifications_for(:issue_added, issue_where_assignee) }
      it { should_not receive_notifications_for(:issue_edited, issue_where_assignee) }
      it { should_not receive_notifications_for(:issue_added, issue_any) }
      it { should_not receive_notifications_for(:issue_edited, issue_any) }
      it { should receive_notifications_for(:message_posted, model) }
      it { should receive_notifications_for(:news_added, model) }
      it { should receive_notifications_for(:news_comment_added, model) }
      it { should receive_notifications_for(:wiki_content_added, model) }
      it { should receive_notifications_for(:wiki_content_updated, model) }
    end
  end
end
