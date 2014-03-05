module Fog
  module Compute
    class QingCloud
      class Real

        # {API Reference}[https://docs.qingcloud.com/api/router/modify_router_attributes.html]
        def modify_router_attributes(id, attributes)
          args = {'action' => 'ModifyRouterAttributes',
                  'router' => id,
                  'eip'    => attributes['eip'],
                  'security_group' => attributes['security_group_id'],
                  'router_name' => attributes['name'],
                  'description' => attributes['description']}
          args['eip'] ||= ''
          request(args)
        end
      end

      class Mock
        def modify_router_attributes(id, attributes)
        end        
      end
    end
  end
end
