module Fog
  module Compute
    class QingCloud
      class Real

        # Associate an elastic IP address with an instance
        # { API Reference}[https://docs.qingcloud.com/api/eip/associate_eip.html]
        def associate_address(id, instance_id)
          args = {
              'action'   => 'AssociateEip',
              'eip'      => id,
              'instance' => instance_id
            }
          request(args)
        end

      end

      class Mock

        def associate_address(id, instance_id)
          instance = self.data[:instances][instance_id]
          eip = self.data[:addresses][id]
          unless instance
            raise Fog::QingCloud::Errors::NotFound, "The instance '#{instance_id}' does not exist."
          end

          unless eip
            raise Fog::QingCloud::Errors::NotFound, "The eip '#{id}' does not exist."
          end

          unless eip['status'] == 'available'
            raise Fog::QingCloud::Errors::PermissionDenied, "The eip can't be associated."
          end
          
          eip['resource'] = {
            'resource_name' => instance['instance_name'],
            'resource_type' => 'instance',
            'resource_id'   => instance_id
          }
          eip['status'] = 'associated'

          response = Excon::Response.new
          response.body = {
            'action'   => 'AssociateEipResponse',
            'job_id'   => Fog::QingCloud::Mock.job_id,
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
