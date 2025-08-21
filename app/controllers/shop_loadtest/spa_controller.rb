
# frozen_string_literal: true
class ShopLoadtest::SpaController < ::ApplicationController
  requires_plugin 'discourse-shop-loadtest'
  skip_before_action :check_xhr
  skip_before_action :redirect_to_login_if_required

  def ok
    render plain: "OK"
  end

  def index
    strategy = SiteSetting.shop_test_strategy
    prefix = SiteSetting.shop_test_route_prefix.presence || "shop"
    ShopLoadtest.log!("SSR index path=#{request.fullpath} strategy=#{strategy}")
    if params[:plain].to_s == "1"
      render plain: "SSR OK: #{request.fullpath}", layout: false
      return
    end
    html = <<~HTML
      <!doctype html><meta charset="utf-8">
      <title>Shop Load Test</title>
      <div style="padding:20px;font:14px/1.5 -apple-system,BlinkMacSystemFont,'Segoe UI',Roboto">
        <h2>Shop Load Test – SSR OK</h2>
        <p>Strategy: <b>#{strategy}</b> &nbsp; Prefix: <code>/#{prefix}</code></p>
        <p>如果你能看到这页，说明服务端渲染已命中。</p>
        <ul>
          <li><a href="/#{prefix}/ok" rel="nofollow">/#{prefix}/ok (plain OK)</a></li>
          <li><a href="/#{prefix}?plain=1" rel="nofollow">/#{prefix}?plain=1 (plain)</a></li>
          <li><a href="/admin/plugins/shop" rel="nofollow">/admin/plugins/shop</a></li>
          <li><a href="/#{prefix}-api/ping" rel="nofollow">/#{prefix}-api/ping</a></li>
        </ul>
      </div>
    HTML
    render html: html.html_safe, layout: false
  rescue => e
    ShopLoadtest.log!("SSR index error: #{e.class}: #{e.message}\n#{e.backtrace&.first(8)&.join("\n")}")
    render plain: "SSR ERROR: #{e.class}: #{e.message}", status: 500, layout: false
  end
end
