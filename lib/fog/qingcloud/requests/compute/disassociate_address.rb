module Fog
  module Compute
    class QingCloud
      class Real

        # Disassociate an elastic IP address from its instance (if any)
        # {API Reference}[https://docs.qingcloud.com/api/eip/dissociate_eips.html]
        def disassociate_address(id)
          args = {
              'action' => 'DissociateEips'
            }.merge(Fog::QingCloud.indexed_param('eips', [*id]))
          request(args)
        end

      end

      class Mock
        def disassociate_address(id)
          ids = [*id]
          unless (unknown_ids = ids - self.data[:addresses].keys).empty?
            raise Fog::QingCloud::Errors::NotFound, "eips #{ids.join(', ')} not found"
          end

          response = Excon::Response.new
          response.status = 200
          ids.each do |id|
            address = self.data[:addresses][id]
            unless address['resource'].empty?
              case address['resource_type']
              when 'router'
                self.data[:routers].map! do |r| 
                  if r['eip']['eip_id'] == id
                    r['eip'] = {}
                  end
                  r
                end
              end
              address['resource'] = {}
            end
          end
          response.status = 200
          response.body = {
            'action' => 'DissociateEipsResponse',
            'owner'  => Fog::Mock.random_letters(12),
            'job_id' => Fog::Mock.job_id,
            'ret_code' => 0
          }
          response
        end

      end
    end
  end
end
