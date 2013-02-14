require 'active_resource'
require 'chargify_api_ares/config'
require 'chargify_api_ares/resources/base'
require 'chargify_api_ares/resources/component'
require 'chargify_api_ares/resources/coupon'
require 'chargify_api_ares/resources/customer'
require 'chargify_api_ares/resources/event'
require 'chargify_api_ares/resources/payment_profile'
require 'chargify_api_ares/resources/product'
require 'chargify_api_ares/resources/product_family'
require 'chargify_api_ares/resources/site'
require 'chargify_api_ares/resources/statement'
require 'chargify_api_ares/resources/subscription'
require 'chargify_api_ares/resources/transaction'
require 'chargify_api_ares/resources/usage'
require 'chargify_api_ares/resources/webhook'

if defined?(::ActiveResource::VERSION::MAJOR) &&
      ::ActiveResource::VERSION::MAJOR == 3 &&
      ::ActiveResource::VERSION::MINOR == 0 &&
      ::ActiveResource::VERSION::TINY < 20
  raise RuntimeError, 'This gem is not compatible with ActiveResource versions 3.0.0 to 3.0.19, please upgrade to at least 3.0.20'
end