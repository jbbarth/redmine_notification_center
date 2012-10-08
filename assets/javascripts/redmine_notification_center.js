displayNotificationDependsOptions = function(id) {
  var $select = $("#"+id)
  var selected = $select.find("option:selected").val()
  var showOrHide = (selected == "custom")
  $select.closest(".depends-container").find(".depends").toggle(showOrHide)
}
handleNoNotificationOption = function() {
  $nonotif = $("#no_notification_at_all")
  $("#tab-content-notifications .section").toggle(!$nonotif.is(":checked"))
  $("#other-mail-address").toggle(!$nonotif.is(":checked"))
  $("#alert-no-notification").toggle($nonotif.is(":checked"))
}
handleOtherAddressOption = function() {
  $otheraddress = $("#notification-to-other-address")
  $("#other-address").toggle($otheraddress.is(":checked"))
}
handleSelectsDependingOnAllNotificationsOption = function() {
  var $selects = $("#notifications_for_all_events").closest('fieldset.box').find('select')
  if ($("#notifications_for_all_events").is(":checked")) {
    $selects.val("always").change()
    $selects.attr('disabled', 'disabled')
  } else {
    $selects.attr('disabled', false)
  }
}
$(function() {
  //display fine grained options
  $(".has-depends").each(function() { displayNotificationDependsOptions($(this).attr('id')) })
  $(".has-depends").on("change", function() { displayNotificationDependsOptions($(this).attr('id')) })
  //handle the case when a user wants no notification at all
  handleNoNotificationOption()
  $("#no_notification_at_all").on("change", function() { handleNoNotificationOption() })
  //handle other address option
  handleOtherAddressOption()
  $("#notification-to-other-address").on("change", function() { handleOtherAddressOption() })
  //handle 'notifications for all events' checkbox
  handleSelectsDependingOnAllNotificationsOption()
  $("#notifications_for_all_events").on("change", function() { handleSelectsDependingOnAllNotificationsOption() })
})
