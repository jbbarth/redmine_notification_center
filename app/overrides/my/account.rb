Deface::Override.new :virtual_path  => 'my/account',
                     :name          => 'remove-mail-notifications-box',
                     :remove        => '.splitcontentright fieldset.box:first-child'

Deface::Override.new :virtual_path  => 'my/account',
                     :name          => 'add-tabs-selector',
                     :insert_after  => 'code[erb-loud]:contains("error_messages_for")' do
  %|
<% selected_tab = params[:tab] ? params[:tab].to_s : 'general' %>
<div class="tabs">
  <ul>
    <li><%= link_to l(:label_general), {:tab => 'general'},
                                       :class => (selected_tab == 'general' ? 'selected' : ''),
                                       :id => 'tab-general',
                                       :onclick => "showTab('general'); this.blur(); return false;" %></li>
    <li><%= link_to l(:field_mail_notification), {:tab => 'notifications'},
                                       :class => (selected_tab == 'notifications' ? 'selected' : ''),
                                       :id => 'tab-notifications',
                                       :onclick => "showTab('notifications'); this.blur(); return false;" %></li>
  </ul>
</div>|
end

Deface::Override.new :virtual_path  => 'my/account',
                     :name          => 'surround-old-account-content-with-general-tab-1',
                     :insert_before => 'code[erb-loud]:contains("labelled_form_for")',
                     :text          => '<%= %(<div class="tab-content" id="tab-content-general" #{%(style="display:none") if params[:tab] == "notifications"}>).html_safe %>'
                     #we don't use standard html above, or deface will try to close the <div> immediately

Deface::Override.new :virtual_path  => 'my/account',
                     :name          => 'surround-old-account-content-with-general-tab-2',
                     :insert_before => 'code[erb-silent]:contains("content_for")',
                     :text          => '<%= %(</div>).html_safe %>'
                     #same as above for the use of erb..

Deface::Override.new :virtual_path  => 'my/account',
                     :name          => 'add-notification-tab-to-my-account',
                     :insert_before => 'code[erb-silent]:contains("content_for")',
                     :partial       => 'users/notification_center'
