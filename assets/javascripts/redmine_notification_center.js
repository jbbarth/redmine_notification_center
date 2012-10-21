displayNotificationDependsOptions = function(id) {
  var $select = $("#"+id)
  var selected = $select.find("option:selected").val()
  var showOrHide = (selected == "custom")
  $select.closest(".depends-container").find(".depends").toggle(showOrHide)
}
handleNoNotificationOption = function() {
  $nonotif = $("#pref_none_at_all")
  $("#tab-content-notifications .section").toggle(!$nonotif.is(":checked"))
  $("#other-mail-address").toggle(!$nonotif.is(":checked"))
  $("#alert-no-notification").toggle($nonotif.is(":checked"))
}
handleOtherAddressOption = function() {
  $otheraddress = $("#pref_other_notification_address_check")
  $("#pref_other_notification_address").toggle($otheraddress.is(":checked"))
}
handleSelectsDependingOnAllNotificationsOption = function() {
  var $selects = $("#pref_all_events").closest('fieldset.box').find('select')
  if ($("#pref_all_events").is(":checked")) {
    $selects.val("always").change()
    $selects.attr('disabled', 'disabled')
  } else {
    $selects.attr('disabled', false)
  }
}
handleExceptionsDetails = function(element) {
  var $form = $(element)
  selected_names = $form.find('input[type=checkbox]:checked')
                        .next('.name')
                        .map(function(){return $(this).html()})
                        .toArray()
                        .join(', ')
  $form.siblings('.exception_details_view').html(selected_names)
}
///            <%= link_to l(:button_change).downcase, '#', :class => 'toggle_exception_details' %>
///            <p class=exception_details_view>
///            <p class=exception_details_form style="display:none">
$(function() {
  //display fine grained options
  $(".has-depends").each(function() { displayNotificationDependsOptions($(this).attr('id')) })
  $(".has-depends").on("change", function() { displayNotificationDependsOptions($(this).attr('id')) })
  //handle the case when a user wants no notification at all
  handleNoNotificationOption()
  $("#pref_none_at_all").on("change", function() { handleNoNotificationOption() })
  //handle other address option
  handleOtherAddressOption()
  $("#pref_other_notification_address_check").on("change", function() { handleOtherAddressOption() })
  //handle 'notifications for all events' checkbox
  handleSelectsDependingOnAllNotificationsOption()
  $("#pref_all_events").on("change", function() { handleSelectsDependingOnAllNotificationsOption() })
  //handle exceptions forms/views
  handleExceptionsDetails()
  $(".exception_details_form").each(function() { handleExceptionsDetails(this) })
  $(".exception_details_form").on("change", function() { handleExceptionsDetails(this) })
  $(".toggle_exception_details").on("click", function() {
    var $container = $(this).parent()
    $container.find('.exception_details_view').toggle()
    $container.find('.exception_details_form').toggle()
  })
})
