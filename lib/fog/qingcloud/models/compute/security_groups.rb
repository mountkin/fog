require 'fog/core/collection'
require 'fog/qingcloud/models/compute/security_group'

module Fog
  module Compute
    class QingCloud

      class SecurityGroups < Fog::Collection

        attribute :filters
        attribute :server

        model Fog::Compute::QingCloud::SecurityGroup

        # Creates a new security group
        #
        # QingCloud.security_groups.new

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        # Returns an array of all security groups that have been created
        #
        # QingCloud.security_groups.all

        def all(filters = filters)
          unless filters.is_a?(Hash)
            Fog::Logger.deprecation("all with #{filters.class} param is deprecated, use all('group-name' => []) instead [light_black](#{caller.first})[/]")
            filters = {'group-name' => [*filters]}
          end
          self.filters = filters
          data = service.describe_security_groups(filters).body
          load(data['security_group_set'])

          if server
            self.replace(self.select do |sg| 
                sg.resources.select {|r| r['resource_type'] == 'instance' && r['resource_id'] == server.id}.any?
              end
            )
          end
          self
        end

        # Used to retrieve a security group
        # group name is required to get the associated flavor information.
        #
        # You can run the following command to get the details:
        # QingCloud.security_groups.get("default")

        def get_by_name(group_name)
          if group_name
            self.class.new(:service => service).all('group-name' => group_name).first
          end
        end

        # Used to retrieve a security group
        # group id is required to get the associated flavor information.
        #
        # You can run the following command to get the details:
        # QingCloud.security_groups.get_by_id("sg-aaaaaaaa")

        def get(group_id)
          if group_id
            self.class.new(:service => service).all('group-id' => group_id).first
          end
        end
        
        def new(attributes = {})
          if server
            super({ :server => server }.merge!(attributes))
          else
            super
          end
        end

      end

    end
  end
end
