RedmineApp::Application.routes.draw do
  # we use our own controller because we don't want to monkey patch MyController
  # MyController groups a lot of sensitive actions, some with security concerns,
  # and we don't want to break that in any way
  put 'my/notification_preferences', :to => 'notification_preferences#update'
end
