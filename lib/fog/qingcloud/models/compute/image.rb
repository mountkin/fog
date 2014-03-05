require 'fog/qingcloud/model'

module Fog
  module Compute
    class QingCloud

      class Image < Fog::QingCloud::Model

        identity :id,                     :aliases => 'image_id'

        attribute :state,                 :aliases => 'status'
        attribute :processor_type
        attribute :transition_status
        attribute :recommended_type
        attribute :name,                  :aliases => 'image_name'
        attribute :visibility
        attribute :platform
        attribute :created_at,            :aliases => 'create_time'
        attribute :os_family
        attribute :provider
        attribute :owner
        attribute :status_time
        attribute :size
        attribute :description

        def ready?
          state == 'available'
        end

        def is_public
          visibility == 'public'
        end

      end

    end
  end
end
