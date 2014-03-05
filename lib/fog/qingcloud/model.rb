require 'fog/core/model'
require 'fog/qingcloud/core'

module Fog
  module QingCloud
    class Model < Fog::Model

      # Define a common modify_attributes method for some resources
      def self.inherited(child)
        resource_type = Fog::QingCloud.underscore_string(child.to_s.split(':').last)
        aliased_resource_type = {
          'server' => 'instance',
          'address' => 'eip',
          'key_pair' => 'keypair'
        }
        resource_type = aliased_resource_type.fetch(resource_type, resource_type)

        attributes_modifable_resources = ['instance', 'volume', 'vxnet', 'eip', 
          'security_group', 'keypair', 'image']
        if attributes_modifable_resources.include?(resource_type)
          child.class_eval <<-EOS, __FILE__, __LINE__
            def modify_attributes(name, description)
              requires :id
              raise Fog::QingCloud::Errors::CommonClientError, "name or description must be specified" unless name || description
              service.modify_resource_attributes(id, '#{resource_type}', name, description)
              merge_attributes('keypair_name' => name, 'description' => description)
              true
            end
          EOS
        end
      end
    end
  end
end
