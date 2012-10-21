Redmine Notification Center plugin
==================================

This plugin adds a "Notifications" tab to "My account" page. It allows you to control
which notifications are sent to you with fine-grained rules and exceptions.

Disclaimer
----------

This plugin totally **replaces** the default mailer in Redmine. Hence it has to be carefully validated for each Redmine version. The plugin voluntarily breaks on non-validated Redmine versions, it won't even boot in these cases. It cannot run under Redmine < 2.1.0 because it relies on the jQuery javascript framework.

For now, it has only been tested on Redmine 2.1.0.

Preferences storage (draft)
---------------------------

Typical preferences for mail notifications are stored directly in the User table and in each Member table with the `mail_notification` column.

Preferences for this plugin are now stored in current user's UserPreference, which in fact serializes structures in one database column. It gives us some flexibility and allows storing nested Hashes/Arrays/Strings/Integers.

Here's how the structure looks (ruby-ish syntax):
```
:notification_options => {
  :none_at_all => "1|0",
  :all_events  => "1|0",
  :by_module   => {
    :issues    => "all|none|custom",
    :issues_custom => {
      :if_author   => "1|0",
      :if_assignee => "1|0",
      :others      => "1|0"
    },
    :new       => "all|none",
    :documents => "all|none",
    :files     => "all|none",
    :boards    => "all|none",
    :wiki      => "all|none"
  },
  :exceptions => {
    :no_self_notified     => "1|0",
    :for_projects         => [1, 4, 7],
    :for_roles            => [2, 4],
    :no_issue_updates     => "1|0",
    :for_issue_trackers   => [1, 2],
    :for_issue_priorities => [3]
  },
  :other_notification_address => "mail@example.net"
}
```
Default options look like this:
```
:notification_options => {
  :none_at_all => "0",
  :all_events  => "1",
  :by_module   => {
    :issues    => "all",
    :issues_custom => {
      :if_author   => "1",
      :if_assignee => "1",
      :others      => "1"
    },
    :new       => "all",
    :documents => "all",
    :files     => "all",
    :boards    => "all",
    :wiki      => "all"
  },
  :exceptions => {
    :no_self_notified     => "0",
    :for_projects         => [],
    :for_roles            => [],
    :no_issue_updates     => "0",
    :for_issue_trackers   => [],
    :for_issue_priorities => []
  },
  :other_notification_address => nil
}
```

Convenience methods to access this hash, sane default values and parsing details are available
through the User model.
