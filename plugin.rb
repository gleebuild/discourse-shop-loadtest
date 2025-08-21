
# frozen_string_literal: true
# name: discourse-shop-loadtest
# about: A single plugin to test multiple strategies to make /shop and /shop/admin load successfully
# version: 0.0.1
# authors: LoadTestKit
# required_version: 3.0.0

enabled_site_setting :shop_test_enabled
register_asset 'stylesheets/common/shop-loadtest.scss'

after_initialize do
  module ::ShopLoadtest
    PLUGIN_NAME = "discourse-shop-loadtest"
    class << self
      def log!(message)
        begin
          dir = "/var/www/discourse/public"
          file = File.join(dir, "mall.txt")
          FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
          timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
          File.open(file, "a") { |f| f.puts("#{timestamp} | [loadtest] #{message}") }
        rescue => e
          Rails.logger.warn("[shop-loadtest] log error: #{e.class}: #{e.message}")
        end
      end
    end
  end

  require_relative 'app/controllers/shop_loadtest/spa_controller'
  require_relative 'lib/shop_loadtest/engine'

  prefix = SiteSetting.shop_test_route_prefix.presence || "shop"
  strategy = SiteSetting.shop_test_strategy
  inject_nav = SiteSetting.shop_test_nav_inject

  ShopLoadtest.log!("booting... strategy=#{strategy} prefix=/#{prefix} inject_nav=#{inject_nav}")

  case strategy
  when "ssr_prepend", "all_on"
    ShopLoadtest.log!("register routes.prepend for /#{prefix}")
    Discourse::Application.routes.prepend do
      get "/#{prefix}" => "shop_loadtest/spa#index"
      get "/#{prefix}/admin" => "shop_loadtest/spa#index", constraints: StaffConstraint.new
      get "/#{prefix}/*anything" => "shop_loadtest/spa#index"
    end
  when "ssr_append"
    ShopLoadtest.log!("register routes.append for /#{prefix}")
    Discourse::Application.routes.append do
      get "/#{prefix}" => "shop_loadtest/spa#index"
      get "/#{prefix}/admin" => "shop_loadtest/spa#index", constraints: StaffConstraint.new
      get "/#{prefix}/*anything" => "shop_loadtest/spa#index"
    end
  end

  if %w[admin_plugins all_on].include?(strategy)
    ShopLoadtest.log!("add_admin_route + admin/plugins/shop")
    add_admin_route 'shop_test.title', 'shop'
    Discourse::Application.routes.prepend do
      get '/admin/plugins/shop' => 'admin/plugins#index', constraints: StaffConstraint.new
    end
  end

  if %w[engine_mount all_on].include?(strategy)
    ShopLoadtest.log!("mount test engine at /#{prefix}-api")
    Discourse::Application.routes.append do
      mount ::ShopLoadtest::Engine, at: "/#{prefix}-api"
    end
  end

  ShopLoadtest.log!("routes ready")
end
