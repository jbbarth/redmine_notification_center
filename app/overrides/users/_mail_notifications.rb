Deface::Override.new :virtual_path  => 'users/_mail_notifications',
                     :name          => 'remove-self-notified-option',
                     :remove        => 'p:contains("self_notified")'
