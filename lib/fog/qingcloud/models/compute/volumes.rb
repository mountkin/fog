require 'fog/core/collection'
require 'fog/qingcloud/models/compute/volume'

module Fog
  module Compute
    class QingCloud

      class Volumes < Fog::Collection

        attribute :filters
        attribute :server

        model Fog::Compute::QingCloud::Volume
        ACTIVE_STATUS = %w[pending available in-use suspended]

        # Used to create a volume.  There are 3 arguments and zone and size are required.  You can generate a new key_pair as follows:
        # QingCloud.volumes.create(:zone => 'us-east-1a', :size => 10)

        def initialize(attributes)
          self.filters ||= {}
          filters['status'] = ACTIVE_STATUS unless filters['status']
          super
        end

        # Used to return all volumes.
        # QingCloud.volumes.all
        #
        # The volume can be retrieved by running QingCloud.volumes.get("vol-1e2028b9").  See get method below.
        #

        def all(filters = filters)
          unless filters.is_a?(Hash)
            Fog::Logger.deprecation("all with #{filters.class} param is deprecated, use all('volume-id' => []) instead [light_black](#{caller.first})[/]")
            filters = {'volume-id' => [*filters]}
          end
          self.filters = filters
          data = service.describe_volumes(filters).body
          load(data['volume_set'].map {|v|
              i = v.delete('instance')
              v['instance_id'] = i['instance_id'] if i
              v
            }
          )
          if server
            self.replace(self.select {|volume| volume.server_id == server.id})
          end
          self
        end

        # Used to retrieve a volume
        # volume_id is required to get the associated volume information.
        #
        # You can run the following command to get the details:
        # QingCloud.volumes.get("vol-1e2028b9")
        #
        # ==== Returns
        #
        #>> QingCloud.volumes.get("vol-1e2028b9")
        # <Fog::QingCloud::Compute::Volume
        #    id="vol-1e2028b9",
        #    attached_at=nil,
        #    zone="us-east-1a",
        #    created_at=Tue Nov 23 23:30:29 -0500 2010,
        #    delete_on_termination=nil,
        #    device=nil,
        #    server_id=nil,
        #    size=10,
        #    snapshot_id=nil,
        #    status="available",
        #    tags={}
        #  >
        #

        def get(volume_id)
          if volume_id
            self.class.new(:service => service).all('volume-id' => volume_id).first
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
