# Little hack for deface in redmine:
# - redmine plugins are not railties nor engines, so deface overrides are not detected automatically
# - deface doesn't support direct loading anymore ; it unloads everything at boot so that reload in dev works
# - hack consists in adding "app/overrides" path of the plugin in Redmine's main #paths
Rails.application.paths["app/overrides"] ||= []
Rails.application.paths["app/overrides"] << File.expand_path("../app/overrides", __FILE__)

Redmine::Plugin.register :redmine_notification_center do
  name 'Redmine Notification Center Plugin'
  description 'This plugin adds fine-grained notifications to redmine'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  version '0.1.0'
  url 'https://github.com/jbbarth/redmine_notification_center'
  requires_redmine :version => %w(2.1.6)
end

# Patches to existing classes/modules
ActionDispatch::Callbacks.to_prepare do
  # we don't want to break core's tests
  # we'll require it manually in our own tests
  unless Rails.env.test?
    require_dependency 'redmine_notification_center/mailer_patch'
  end
  # patch to User
  # see: http://www.redmine.org/issues/11035
  require_dependency 'project'
  require_dependency 'principal'
  require_dependency 'user'
  require_dependency 'redmine_notification_center/user_patch'
  User.send(:include, RedmineNotificationCenter::UserPatch)
end
