
# frozen_string_literal: true
class ShopLoadtest::SpaController < ::ApplicationController
  requires_plugin 'discourse-shop-loadtest'
  skip_before_action :check_xhr
  skip_before_action :redirect_to_login_if_required

  def index
    strategy = SiteSetting.shop_test_strategy
    prefix = SiteSetting.shop_test_route_prefix.presence || "shop"
    ShopLoadtest.log!("SSR index path=#{request.fullpath} strategy=#{strategy}")
    @strategy = strategy
    @prefix = prefix
    render :index, layout: true
  end
end
