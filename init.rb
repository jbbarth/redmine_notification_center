Redmine::Plugin.register :redmine_notification_center do
  name 'Redmine Notification Center Plugin'
  description 'This plugin adds fine-grained notifications to redmine'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  requires_redmine :version_or_higher => '2.1.0'
  version '0.1.0'
  url 'https://github.com/jbbarth/redmine_notification_center'
end
