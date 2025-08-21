
# frozen_string_literal: true
module ShopLoadtest
  class Engine < ::Rails::Engine
    engine_name 'shop_loadtest'
    isolate_namespace ShopLoadtest
  end
end

ShopLoadtest::Engine.routes.draw do
  get '/ping' => proc { |env| [200, { 'Content-Type' => 'application/json' }, ['{"ok":true,"via":"engine"}']] }
end
