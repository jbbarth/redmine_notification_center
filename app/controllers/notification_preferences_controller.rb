class NotificationPreferencesController < ApplicationController
  unloadable
  before_filter :require_login

  def update
    @pref = User.current.pref
    @pref[:notification_preferences] = params_pref
    if @pref.save
      flash[:notice] = l(:notice_account_updated)
    end
    redirect_to :controller => 'my', :action => 'account', :tab => 'notifications'
  end

  protected
  def params_pref
    hash = params[:pref] || Hash.new
    #equivalent of symbolize_keys, but recursive
    hash = deep_symbolize(hash.to_hash)
    #don't set alternate notification address if checkbox is unchecked
    hash.delete(:other_notification_address) unless hash[:other_notification_address_check]
    #use "zero" values when unset ; it repairs broken-ness of checkboxes in html...
    hash = zero_options.deep_merge(hash)
    #transform string to integers in exceptions
    #+ default values for all those checkboxes-related arrays
    [:for_projects, :for_roles, :for_issue_trackers, :for_issue_priorities].each do |key|
      hash[:exceptions][key] = (hash[:exceptions][key] || []).map(&:to_i)
    end
    #normalize other_notification_address
    hash[:other_notification_address] = hash[:other_notification_address].strip
    #return
    hash
  end

  def deep_symbolize(hash)
    hash.inject({}) do |memo,(key,val)|
      memo[key.to_sym] = val.is_a?(Hash) ? deep_symbolize(val) : val
      memo
    end
  end

  def zero_options
    {
      :none_at_all => '0', :all_events  => '0', :other_notification_address => '',
      :by_module   => { :issue_tracking_custom => { :if_author => '0', :if_assignee => '0', :others => '0' } },
      :exceptions => { :no_self_notified => '0', :no_issue_updates => '0' }
    }
  end
end
