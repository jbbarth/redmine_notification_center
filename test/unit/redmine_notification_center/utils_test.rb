require File.dirname(__FILE__) + '/../../test_helper'

# pure laziness... :/
U = RedmineNotificationCenter::Utils

class RedmineNotificationCenterUtilsTest < ActiveSupport::TestCase
  teardown do
    Setting.clear_cache
  end

  context '#module_sends_notifications??' do
    should 'break if notifiable events change in a future redmine version, so that we can adapt the module' do
      expected = %w(issue_added issue_updated issue_note_added issue_status_updated issue_priority_updated news_added news_comment_added document_added file_added message_posted wiki_content_added wiki_content_updated)
      actual = Redmine::Notifiable.all.map(&:name)
      assert_equal expected.sort, actual.sort
    end

    # OK I *know* the following tests are stupid,
    # but they were made before refactoring, hence...
    context 'when module = :issue_tracking' do
      should 'be truthy if any of issue_* notifiables is true' do
        Setting.notified_events = %w(issue_added)
        assert U.module_sends_notifications?(:issue_tracking)
      end

      should 'be falsy if no issue_* notifiable' do
        Setting.notified_events = %w(file_added)
        assert !U.module_sends_notifications?(:issue_tracking)
      end
    end

    context 'when module = :time_tracking' do
      # no notification for this module for now...
    end

    context 'when module = :news' do
      should 'be truthy if any of news_* notifiables is true' do
        Setting.notified_events = %w(news_added)
        assert U.module_sends_notifications?(:news)
      end

      should 'be falsy if no news_* notifiable' do
        Setting.notified_events = %w(file_added)
        assert !U.module_sends_notifications?(:news)
      end
    end

    context 'when module = :documents' do
      should 'be truthy if any of document_* notifiables is true' do
        Setting.notified_events = %w(document_added)
        assert U.module_sends_notifications?(:documents)
      end

      should 'be falsy if no document_* notifiable' do
        Setting.notified_events = %w(file_added)
        assert !U.module_sends_notifications?(:documents)
      end
    end

    context 'when module = :files' do
      should 'be truthy if any of file_* notifiables is true' do
        Setting.notified_events = %w(file_added)
        assert U.module_sends_notifications?(:files)
      end

      should 'be falsy if no file_* notifiable' do
        Setting.notified_events = %w(news_added)
        assert !U.module_sends_notifications?(:files)
      end
    end

    context 'when module = :wiki' do
      should 'be truthy if any of wiki_* notifiables is true' do
        Setting.notified_events = %w(wiki_content_added)
        assert U.module_sends_notifications?(:wiki)
      end

      should 'be falsy if no wiki_* notifiable' do
        Setting.notified_events = %w(file_added)
        assert !U.module_sends_notifications?(:wiki)
      end
    end

    context 'when module = :repository' do
      # no notification for this module for now...
    end

    context 'when module = :boards' do
      should 'be truthy if any of message_* notifiables is true' do
        Setting.notified_events = %w(message_added)
        assert U.module_sends_notifications?(:boards)
      end

      should 'be falsy if no message_* notifiable' do
        Setting.notified_events = %w(file_added)
        assert !U.module_sends_notifications?(:boards)
      end
    end

    context 'when module = :calendar' do
      # no notification for this module for now...
    end

    context 'when module = :gantt' do
      # no notification for this module for now...
    end
  end
end
