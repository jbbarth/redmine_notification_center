module RedmineNotificationCenter
  module Utils
    extend self #so that method can be used directly on this namespace

    def module_sends_notifications?(mod)
      pattern = mod.to_s.singularize
      pattern.gsub!('issue_tracking', 'issue')
      pattern.gsub!('board', 'message')
      pattern = pattern+'_'
      Setting.notified_events.detect{|n| n.starts_with?(pattern)}
    end
  end
end
