require File.expand_path('../../fast_spec_helper', __FILE__)
require File.expand_path('../../../../../lib/redmine/notifiable', __FILE__)

describe RedmineNotificationCenter::Utils do

  # laziness.
  U = RedmineNotificationCenter::Utils

  describe '#module_sends_notifications??' do
    it 'breaks if notifiable events change in a future redmine version, so that we can adapt the module' do
      expected = %w(issue_added issue_updated issue_note_added issue_status_updated issue_priority_updated news_added news_comment_added document_added file_added message_posted wiki_content_added wiki_content_updated)
      actual = Redmine::Notifiable.all.map(&:name)
      actual.sort.should == expected.sort
    end

    # OK I *know* the following tests are stupid,
    # but they were made before refactoring, hence...
    context 'when module = :issue_tracking' do
      it 'is truthy if any of issue_* notifiables is true' do
        U.stub(:notified_events) { %w(issue_added) }
        U.module_sends_notifications?(:issue_tracking).should be_true
      end

      it 'is falsy if no issue_* notifiable' do
        U.stub(:notified_events) { %w(file_added) }
        U.module_sends_notifications?(:issue_tracking).should be_false
      end
    end

    context 'when module = :time_tracking' do
      # no notification for this module for now...
    end

    context 'when module = :news' do
      it 'is truthy if any of news_* notifiables is true' do
        U.stub(:notified_events) { %w(news_added) }
        U.module_sends_notifications?(:news).should be_true
      end

      it 'is falsy if no news_* notifiable' do
        U.stub(:notified_events) { %w(file_added) }
        U.module_sends_notifications?(:news).should be_false
      end
    end

    context 'when module = :documents' do
      it 'is truthy if any of document_* notifiables is true' do
        U.stub(:notified_events) { %w(document_added) }
        U.module_sends_notifications?(:documents).should be_true
      end

      it 'is falsy if no document_* notifiable' do
        U.stub(:notified_events) { %w(file_added) }
        U.module_sends_notifications?(:documents).should be_false
      end
    end

    context 'when module = :files' do
      it 'is truthy if any of file_* notifiables is true' do
        U.stub(:notified_events) { %w(file_added) }
        U.module_sends_notifications?(:files).should be_true
      end

      it 'is falsy if no file_* notifiable' do
        U.stub(:notified_events) { %w(news_added) }
        U.module_sends_notifications?(:files).should be_false
      end
    end

    context 'when module = :wiki' do
      it 'is truthy if any of wiki_* notifiables is true' do
        U.stub(:notified_events) { %w(wiki_content_added) }
        U.module_sends_notifications?(:wiki).should be_true
      end

      it 'is falsy if no wiki_* notifiable' do
        U.stub(:notified_events) { %w(file_added) }
        U.module_sends_notifications?(:wiki).should be_false
      end
    end

    context 'when module = :repository' do
      # no notification for this module for now...
    end

    context 'when module = :boards' do
      it 'is truthy if any of message_* notifiables is true' do
        U.stub(:notified_events) { %w(message_added) }
        U.module_sends_notifications?(:boards).should be_true
      end

      it 'is falsy if no message_* notifiable' do
        U.stub(:notified_events) { %w(file_added) }
        U.module_sends_notifications?(:boards).should be_false
      end
    end

    context 'when module = :calendar' do
      # no notification for this module for now...
    end

    context 'when module = :gantt' do
      # no notification for this module for now...
    end
  end

  describe '#module_from_event' do
    it 'gets the module name associated to an event' do
      U.module_from_event(:issue_added).should == :issue_tracking
    end

    it 'stays blank if event does not exist' do
      U.module_from_event(:nonexistent).should be_nil
    end
  end
end
