ApplicationHelper.module_eval do

  def wholesaler_signed_in?
    current_user && current_user.has_spree_role?("wholesaler")
  end

end
