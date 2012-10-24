module RedmineNotificationCenter
  module Utils
    extend self #so that method can be used directly on this namespace

    KNOWN_EVENTS = %w(attachments_added document_added issue_added issue_edited
                      message_posted news_added news_comment_added wiki_content_added wiki_content_updated)

    def module_sends_notifications?(mod)
      pattern = mod.to_s.singularize
      pattern.gsub!('issue_tracking', 'issue')
      pattern.gsub!('board', 'message')
      pattern = pattern+'_'
      Setting.notified_events.detect{|n| n.starts_with?(pattern)}
    end
  end
end
