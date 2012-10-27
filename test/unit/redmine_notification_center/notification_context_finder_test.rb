require File.dirname(__FILE__) + '/../../test_helper'

# These tests are just here to know if something changes in the
# core in future versions.
class NotificationContextFinderTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :issues, :journals,
           :groups_users, :trackers, :projects_trackers, :enabled_modules,
           :wikis, :wiki_pages, :wiki_contents, :documents, :attachments, :boards,
           :messages, :news, :comments

  NCF = RedmineNotificationCenter::NotificationContextFinder

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