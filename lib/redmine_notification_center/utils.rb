module RedmineNotificationCenter
  module Utils
    extend self #so that method can be used directly on this namespace

    # { event => module }
    KNOWN_EVENTS = { :attachments_added     => :files,
                     :document_added        => :documents,
                     :issue_added           => :issue_tracking,
                     :issue_edited          => :issue_tracking,
                     :message_posted        => :boards,
                     :news_added            => :news,
                     :news_comment_added    => :news,
                     :wiki_content_added    => :wiki,
                     :wiki_content_updated  => :wiki }

    def known_event?(event)
      KNOWN_EVENTS.keys.include?(event)
    end

    def module_sends_notifications?(mod)
      pattern = mod.to_s.singularize
      pattern.gsub!('issue_tracking', 'issue')
      pattern.gsub!('board', 'message')
      pattern = pattern+'_'
      Setting.notified_events.detect{|n| n.starts_with?(pattern)}
    end
  end
end
