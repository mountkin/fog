require 'fog/qingcloud/core'
require 'fog/compute'

module Fog
  module Compute
    class QingCloud < Fog::Service

      requires :qingcloud_access_key_id, :qingcloud_secret_access_key
      recognizes :endpoint, :region, :host, :path, :port, :scheme, :persistent, :version, :zone

      secrets    :qingcloud_secret_access_key, :hmac

      model_path 'fog/qingcloud/models/compute'
      model       :server
      collection  :servers
      model       :volume
      collection  :volumes
      model       :vxnet
      model       :subnet
      collection  :vxnets
      model       :router
      collection  :routers
      model       :address
      collection  :addresses
      model       :security_group
      collection  :security_groups
      model       :security_group_rule
      collection  :security_group_rules
      model       :key_pair
      collection  :key_pairs
      #model       :image
      #collection  :images
      
      model       :flavor
      collection  :flavors
      
      request_path 'fog/qingcloud/requests/compute'
      request :describe_instances
      request :run_instances
      request :terminate_instances
      request :start_instances
      request :stop_instances
      request :reboot_instances
      request :reset_instances
      request :resize_instances
      
      request :describe_volumes
      request :create_volumes
      request :delete_volumes
      request :attach_volumes
      request :detach_volumes
      #request :resize_volumes
     
      request :describe_vxnets
      request :create_vxnets
      request :delete_vxnets
      request :join_vxnet
      request :leave_vxnet
      request :describe_vxnet_instances

      request :describe_routers
      request :create_routers
      request :delete_routers
      request :update_routers
      request :routers_power
      request :join_router
      request :leave_router
      request :modify_router_attributes
      request :describe_router_statics
      request :add_router_statics
      request :delete_router_statics
      request :describe_router_vxnets
      
      request :describe_addresses
      request :allocate_address
      request :release_address
      request :associate_address
      request :disassociate_address
      request :change_address_bandwidth

      request :describe_security_groups
      request :create_security_group
      request :delete_security_groups
      request :apply_security_group
      request :describe_security_group_rules
      request :add_security_group_rules
      request :delete_security_group_rules
      request :modify_security_group_rule_attributes
      
      request :describe_key_pairs
      request :create_key_pair
      request :delete_key_pairs
      request :attach_key_pairs
      request :detach_key_pairs
      
      #request :describe_images
      #request :capture_instance
      #request :delete_images

      request :modify_resource_attributes

      class Mock
        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              :deleted_at => {},
              :modified_at => {},
              :addresses  => {},
              :images     => {},
              :instances  => {},
              :key_pairs  => {},
              :security_groups => {},
              :security_group_rule_maps => {}, #{rule_id => group_id}
              :volumes => {},
              :vxnets => {},
              :routers => {},
              :quota => {
                :addresses       => 2,
                :images          => 5,
                :volumes         => 5,
                :servers         => 5,
                :key_pairs       => 10,
                :security_groups => 10,
                :routers         => 2,
                :vxnets          => 5,
                :loadbalancers   => 2,
                :gigabytes       => 500,
                :bandwidth       => 10,
                :cores           => 10,
                :ram             => 20
              },
            }
          end
        end

        def self.reset
          @data = nil
        end

        attr_accessor :zone

        def initialize(options={})
          setup_credentials(options)
          @zone = options[:zone] || 'pek1'
        end

        def data
          self.class.data[@qingcloud_access_key_id]
        end

        def reset_data
          self.class.data.delete(@qingcloud_access_key_id)
        end

        def setup_credentials(options)
          @qingcloud_access_key_id = options[:qingcloud_access_key_id]
        end
      end

      class Real
        attr_accessor :zone
        
        def initialize(options={})
          setup_credentials(options)
          @connection_options = options[:connection_options] || {}
          @zone               = options[:zone] ||= 'pek1'
          @version            = options[:version]     ||  '1'
          @signature_method   = 'HmacSHA256'
          @signature_version  = '1'

          if @endpoint = options[:endpoint]
            endpoint = URI.parse(@endpoint)
            @host = endpoint.host
            @path = endpoint.path
            @port = endpoint.port
            @scheme = endpoint.scheme
          else
            @host = options[:host] || "api.qingcloud.com"
            @path       = options[:path]        || '/iaas/'
            @persistent = options[:persistent]  || false
            @port       = options[:port]        || 443
            @scheme     = options[:scheme]      || 'https'
          end
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}#{@path}", @persistent, @connection_options)
        end

        def reload
          @connection.reset
        end

        private
        def setup_credentials(options)
          @qingcloud_access_key_id      = options[:qingcloud_access_key_id]
          @qingcloud_secret_access_key  = options[:qingcloud_secret_access_key]

          @hmac                   = Fog::HMAC.new('sha256', @qingcloud_secret_access_key)
        end

        def request(params)
          args = Fog::QingCloud.signed_params(
            params,
            {
              :qingcloud_access_key_id  => @qingcloud_access_key_id,
              :qingcloud_session_token  => @qingcloud_session_token,
              :hmac               => @hmac,
              :host               => @host,
              :path               => @path,
              :port               => @port,
              :version            => @version,
              :signature_method   => @signature_method,
              :signature_version  => @signature_version,
              :zone               => @zone
            }
          )

          response = @connection.request({
              :expects    => 200,
              :method     => 'GET',
              :query      => args 
            })
          
          if !response.body.empty? and response.get_header('Content-Type') == 'application/json'
            response.body = Fog::JSON.decode(response.body)
            handle_error(response.body)
          end
          #puts response.body
          response
        end
        
        def handle_error(body)
          return if body['ret_code'] == 0

          err = case body['ret_code']
          when 1100, 1300
            Fog::QingCloud::Errors::CommonClientError
          when 1200
            Fog::QingCloud::Errors::AuthFailed
          when 1400
            Fog::QingCloud::Errors::PermissionDenied
          when 2100
            Fog::QingCloud::Errors::NotFound
          when 2400
            Fog::QingCloud::Errors::NotEnoughMoney
          when 2500
            Fog::QingCloud::Errors::QuotaExceeded
          when 5000
            Fog::QingCloud::Errors::InternalServerError
          when 5100
            Fog::QingCloud::Errors::ServiceUnavailable
          when 5200
            Fog::QingCloud::Errors::NotEnoughResource
          when 5300
            Fog::QingCloud::Errors::TryLater
          end

          raise err, body['message']
        end

      end
    end
  end
end
