Spree::Core::ControllerHelpers::Order.module_eval do

  # Associate the new order with the currently authenticated user before saving
  def before_save_new_order
    @current_order.user ||= spree_current_user
    @current_order.wholesale = spree_current_user.wholesaler? if spree_current_user
  end

  def after_save_new_order
    # make sure the user has permission to access the order (if they are a guest)
    return if spree_current_user
    session[:access_token] = @current_order.token
  end

  # The current incomplete order from the session for use in cart and during checkout
  def current_order(create_order_if_necessary = false)
    return @current_order if @current_order
    @current_order ||= Spree::Order.find_by_id(session[:order_id], :include => :adjustments)
    if create_order_if_necessary and (@current_order.nil? or @current_order.completed?)
      @current_order = Spree::Order.new
      before_save_new_order
      @current_order.save!
      after_save_new_order
    end

    if spree_current_user && @current_order
      if spree_current_user.wholesaler? && !@current_order.is_wholesale?
        @current_order.to_wholesale!
      elsif !spree_current_user.wholesaler? && @current_order.is_wholesale?
        @current_order.to_fullsale!
      end
    end

    session[:order_id] = @current_order ? @current_order.id : nil
    @current_order
  end

end
