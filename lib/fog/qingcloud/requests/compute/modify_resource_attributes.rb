module Fog
  module Compute
    class QingCloud
      class Real

        # Delete a key pair that you own
        # {API Reference}[https://docs.qingcloud.com/api/instance/modify_instance_attributes.html]
        # {API Reference}[https://docs.qingcloud.com/api/eip/modify_eip_attributes.html]
        # {API Reference}[https://docs.qingcloud.com/api/volume/modify_volume_attributes.html]
        # {API Reference}[https://docs.qingcloud.com/api/vxnet/modify_vxnet_attributes.html]
        # {API Reference}[https://docs.qingcloud.com/api/sg/modify_security_group_attributes.html]
        # {API Reference}[https://docs.qingcloud.com/api/keypair/modify_key_pair_attributes.html]
        # {API Reference}[https://docs.qingcloud.com/api/image/modify_image_attributes.html]
        def modify_resource_attributes(id, resource_type, name = nil, description = nil)
          aliased_resource_type = {
            'address'  => 'eip',
            'server'   => 'instance'
          }
          resource_type = aliased_resource_type.fetch(resource_type, resource_type)
          action = "Modify#{Fog::QingCloud.camelcase_string(resource_type)}Attributes"
          action = "ModifyKeyPairAttributes" if resource_type == 'keypair'

          name_key = "#{resource_type}_name"
          args = {
            'action'      => action,
            name_key      => name,
            'description' => description,
            resource_type => id
          }
          puts args
          request(args)
        end

      end

      class Mock

        def modify_resource_attributes(id, resource_type, name = nil, description = nil)
          resource_type = 'eip' if resource_type == 'address'
          resource_type = 'instance' if resource_type == 'server'
          
          supported_types = ['instance', 'volume', 'vxnet', 'eip', 
            'security_group', 'keypair', 'image']
          raise Fog::QingCloud::Errors::CommonClientError, "unsupported resource type #{resource_type}" unless supported_types.include?(resource_type)
          action = "Modify#{Fog::QingCloud.camelcase_string(resource_type)}AttributesResponse"
          name_key = "#{resource_type}_name"

          response = Excon::Response.new
          response.status = 200
          key = "#{resource_type}s".to_sym
          self.data[key][id][name_key] = name if name
          self.data[key][id]['description'] = description if description 

          response.body = {
            'action'   => action,
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
