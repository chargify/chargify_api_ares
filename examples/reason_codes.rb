$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end

# Retrieve a list of all your site's reason_codes
reason_codes = Chargify::ReasonCode.find(:all)
#[#<Chargify::ReasonCode:0x007fb67da028d8 @attributes={"id"=>673, "site_id"=>11532, "code"=>"one", "description"=>"One for the money", "position"=>1, "created_at"=>"2017-04-10T04:17:21.000Z", "updated_at"=>"2017-04-10T04:19:30.000Z"}, @prefix_options={}, @persisted=true>, #<Chargify::ReasonCode:0x007fb67da02158 @attributes={"id"=>674, "site_id"=>11532, "code"=>"two", "description"=>"Two for the show", "position"=>2, "created_at"=>"2017-04-10T04:17:27.000Z", "updated_at"=>"2017-04-10T04:19:37.000Z"}, @prefix_options={}, @persisted=true>, #<Chargify::ReasonCode:0x007fb67da01a28 @attributes={"id"=>675, "site_id"=>11532, "code"=>"three", "description"=>"Three to get ready", "position"=>3, "created_at"=>"2017-04-10T04:17:38.000Z", "updated_at"=>"2017-04-10T04:19:43.000Z"}, @prefix_options={}, @persisted=true>, #<Chargify::ReasonCode:0x007fb67da012f8 @attributes={"id"=>681, "site_id"=>11532, "code"=>"four", "description"=>"Four to go", "position"=>4, "created_at"=>"2017-04-10T04:19:50.000Z", "updated_at"=>"2017-04-10T04:19:50.000Z"}, @prefix_options={}, @persisted=true>]
