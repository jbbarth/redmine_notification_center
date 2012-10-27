require File.dirname(__FILE__) + '/../../test_helper'

# These tests are just here to know if something changes in the
# core in future versions.
class NotificationAuthorFinderTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :issues, :journals,
           :groups_users, :trackers, :projects_trackers, :enabled_modules,
           :wikis, :wiki_pages, :wiki_contents, :documents, :attachments, :boards,
           :messages, :news, :comments

  NAF = RedmineNotificationCenter::NotificationAuthorFinder

  should 'find author for an issue' do
    assert NAF.new(Issue.first).author.is_a?(User)
  end

  should 'find author for an issue journal (note)' do
    assert NAF.new(Journal.first).author.is_a?(User)
  end

  should 'find author for a file (attachment)' do
    assert NAF.new(Attachment.first).author.is_a?(User)
  end

  should 'find author for a document' do
    assert NAF.new(Document.first).author.is_a?(User)
  end

  should 'find author for an wiki page' do
    assert NAF.new(WikiContent.first).author.is_a?(User)
  end

  should 'find author for an forum message' do
    assert NAF.new(Message.first).author.is_a?(User)
  end

  should 'find author for an news' do
    assert NAF.new(News.first).author.is_a?(User)
  end

  should 'find author for an news comment' do
    assert NAF.new(Comment.first).author.is_a?(User)
  end
end
