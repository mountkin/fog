require 'fog/core/collection'
require 'fog/qingcloud/models/compute/image'

module Fog
  module Compute
    class QingCloud

      class Images < Fog::Collection

        attribute :filters

        model Fog::Compute::QingCloud::Image

        ACTIVE_STATUS = %w[pending available deprecated suspended]

        # Creates a new  machine image
        #
        # QingCloud.images.new
        #
        # ==== Returns
        #
        # Returns the details of the new image

        def initialize(attributes)
          self.filters ||= {}
          filters['status'] = ACTIVE_STATUS unless filters['status']
          super
        end

        def all(filters = filters)
          self.filters = filters
          data = service.describe_images(filters).body
          load(data['images_set'])
        end

        def get(image_id)
          if image_id
            self.class.new(:service => service).all('image-id' => image_id).first
          end
        end
      end

    end
  end
end
