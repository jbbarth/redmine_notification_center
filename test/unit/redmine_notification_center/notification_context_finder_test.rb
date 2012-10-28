require File.dirname(__FILE__) + '/../../test_helper'

# These tests are just here to know if something changes in the
# core in future versions.
class NotificationContextFinderTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :issues, :journals,
           :groups_users, :trackers, :projects_trackers, :enabled_modules,
           :wikis, :wiki_pages, :wiki_contents, :documents, :attachments, :boards,
           :messages, :news, :comments

  NCF = RedmineNotificationCenter::NotificationContextFinder

  context '#author' do
    should 'find author for an issue' do
      assert NCF.new(Issue.first).author.is_a?(User)
    end

    should 'find author for an issue journal (note)' do
      assert NCF.new(Journal.first).author.is_a?(User)
    end

    should 'find author for a file (attachment)' do
      assert NCF.new(Attachment.first).author.is_a?(User)
    end

    should 'find author for a document' do
      assert NCF.new(Document.first).author.is_a?(User)
    end

    should 'find author for an wiki page' do
      assert NCF.new(WikiContent.first).author.is_a?(User)
    end

    should 'find author for an forum message' do
      assert NCF.new(Message.first).author.is_a?(User)
    end

    should 'find author for an news' do
      assert NCF.new(News.first).author.is_a?(User)
    end

    should 'find author for an news comment' do
      assert NCF.new(Comment.first).author.is_a?(User)
    end
  end

  context '#project_id' do
    should 'find project_id for an issue' do
      assert NCF.new(Issue.first).project_id.is_a?(Integer)
    end

    should 'find project_id for an issue journal (note)' do
      assert NCF.new(Journal.first).project_id.is_a?(Integer)
    end

    should 'find project_id for a file (attachment)' do
      assert NCF.new(Attachment.first).project_id.is_a?(Integer)
    end

    should 'find project_id for a document' do
      assert NCF.new(Document.first).project_id.is_a?(Integer)
    end

    should 'find project_id for an wiki page' do
      assert NCF.new(WikiContent.first).project_id.is_a?(Integer)
    end

    should 'find project_id for an forum message' do
      assert NCF.new(Message.first).project_id.is_a?(Integer)
    end

    should 'find project_id for an news' do
      assert NCF.new(News.first).project_id.is_a?(Integer)
    end

    should 'find project_id for an news comment' do
      assert NCF.new(Comment.first).project_id.is_a?(Integer)
    end
  end

  context '#tracker_id' do
    should 'find tracker_id for an issue' do
      assert NCF.new(Issue.first).tracker_id.is_a?(Integer)
    end

    should 'find tracker_id for an issue journal (note)' do
      assert NCF.new(Journal.first).tracker_id.is_a?(Integer)
    end

    should 'raise error for other types' do
      assert_raise(ArgumentError) do
        NCF.new(Message.first).tracker_id
      end
    end
  end
end
