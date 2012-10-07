require_dependency 'mailer'

class Mailer
  # Builds a Mail::Message object used to email recipients of the added issue.
  #
  # Example:
  #   issue_add(issue) => Mail::Message object
  #   Mailer.issue_add(issue).deliver => sends an email to issue recipients
  def issue_add(issue)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id issue
    @author = issue.author
    @issue = issue
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)
    recipients = issue.recipients
    cc = issue.watcher_recipients - recipients
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
  end

  # Builds a Mail::Message object used to email recipients of the edited issue.
  #
  # Example:
  #   issue_edit(journal) => Mail::Message object
  #   Mailer.issue_edit(journal).deliver => sends an email to issue recipients
  def issue_edit(journal)
    issue = journal.journalized.reload
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id journal
    references issue
    @author = journal.user
    recipients = issue.recipients
    # Watchers in cc
    cc = issue.watcher_recipients - recipients
    s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
    s << issue.subject
    @issue = issue
    @journal = journal
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
    mail :to => recipients,
      :cc => cc,
      :subject => s
  end

  # Builds a Mail::Message object used to email users belonging to the added document's project.
  #
  # Example:
  #   document_added(document) => Mail::Message object
  #   Mailer.document_added(document).deliver => sends an email to the document's project recipients
  def document_added(document)
    redmine_headers 'Project' => document.project.identifier
    @author = User.current
    @document = document
    @document_url = url_for(:controller => 'documents', :action => 'show', :id => document)
    mail :to => document.recipients,
      :subject => "[#{document.project.name}] #{l(:label_document_new)}: #{document.title}"
  end

  # Builds a Mail::Message object used to email recipients of a project when an attachements are added.
  #
  # Example:
  #   attachments_added(attachments) => Mail::Message object
  #   Mailer.attachments_added(attachments).deliver => sends an email to the project's recipients
  def attachments_added(attachments)
    container = attachments.first.container
    added_to = ''
    added_to_url = ''
    @author = attachments.first.author
    case container.class.name
    when 'Project'
      added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container)
      added_to = "#{l(:label_project)}: #{container}"
      recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
    when 'Version'
      added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container.project)
      added_to = "#{l(:label_version)}: #{container.name}"
      recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
    when 'Document'
      added_to_url = url_for(:controller => 'documents', :action => 'show', :id => container.id)
      added_to = "#{l(:label_document)}: #{container.title}"
      recipients = container.recipients
    end
    redmine_headers 'Project' => container.project.identifier
    @attachments = attachments
    @added_to = added_to
    @added_to_url = added_to_url
    mail :to => recipients,
      :subject => "[#{container.project.name}] #{l(:label_attachment_new)}"
  end

  # Builds a Mail::Message object used to email recipients of a news' project when a news item is added.
  #
  # Example:
  #   news_added(news) => Mail::Message object
  #   Mailer.news_added(news).deliver => sends an email to the news' project recipients
  def news_added(news)
    redmine_headers 'Project' => news.project.identifier
    @author = news.author
    message_id news
    @news = news
    @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
    mail :to => news.recipients,
      :subject => "[#{news.project.name}] #{l(:label_news)}: #{news.title}"
  end

  # Builds a Mail::Message object used to email recipients of a news' project when a news comment is added.
  #
  # Example:
  #   news_comment_added(comment) => Mail::Message object
  #   Mailer.news_comment_added(comment) => sends an email to the news' project recipients
  def news_comment_added(comment)
    news = comment.commented
    redmine_headers 'Project' => news.project.identifier
    @author = comment.author
    message_id comment
    @news = news
    @comment = comment
    @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
    mail :to => news.recipients,
     :cc => news.watcher_recipients,
     :subject => "Re: [#{news.project.name}] #{l(:label_news)}: #{news.title}"
  end

  # Builds a Mail::Message object used to email the recipients of the specified message that was posted.
  #
  # Example:
  #   message_posted(message) => Mail::Message object
  #   Mailer.message_posted(message).deliver => sends an email to the recipients
  def message_posted(message)
    redmine_headers 'Project' => message.project.identifier,
                    'Topic-Id' => (message.parent_id || message.id)
    @author = message.author
    message_id message
    references message.parent unless message.parent.nil?
    recipients = message.recipients
    cc = ((message.root.watcher_recipients + message.board.watcher_recipients).uniq - recipients)
    @message = message
    @message_url = url_for(message.event_url)
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{message.board.project.name} - #{message.board.name} - msg#{message.root.id}] #{message.subject}"
  end

  # Builds a Mail::Message object used to email the recipients of a project of the specified wiki content was added.
  #
  # Example:
  #   wiki_content_added(wiki_content) => Mail::Message object
  #   Mailer.wiki_content_added(wiki_content).deliver => sends an email to the project's recipients
  def wiki_content_added(wiki_content)
    redmine_headers 'Project' => wiki_content.project.identifier,
                    'Wiki-Page-Id' => wiki_content.page.id
    @author = wiki_content.author
    message_id wiki_content
    recipients = wiki_content.recipients
    cc = wiki_content.page.wiki.watcher_recipients - recipients
    @wiki_content = wiki_content
    @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                      :project_id => wiki_content.project,
                                      :id => wiki_content.page.title)
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{wiki_content.project.name}] #{l(:mail_subject_wiki_content_added, :id => wiki_content.page.pretty_title)}"
  end

  # Builds a Mail::Message object used to email the recipients of a project of the specified wiki content was updated.
  #
  # Example:
  #   wiki_content_updated(wiki_content) => Mail::Message object
  #   Mailer.wiki_content_updated(wiki_content).deliver => sends an email to the project's recipients
  def wiki_content_updated(wiki_content)
    redmine_headers 'Project' => wiki_content.project.identifier,
                    'Wiki-Page-Id' => wiki_content.page.id
    @author = wiki_content.author
    message_id wiki_content
    recipients = wiki_content.recipients
    cc = wiki_content.page.wiki.watcher_recipients + wiki_content.page.watcher_recipients - recipients
    @wiki_content = wiki_content
    @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                      :project_id => wiki_content.project,
                                      :id => wiki_content.page.title)
    @wiki_diff_url = url_for(:controller => 'wiki', :action => 'diff',
                                   :project_id => wiki_content.project, :id => wiki_content.page.title,
                                   :version => wiki_content.version)
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{wiki_content.project.name}] #{l(:mail_subject_wiki_content_updated, :id => wiki_content.page.pretty_title)}"
  end
end
