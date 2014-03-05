module Fog
  module Compute
    class QingCloud
      class Real


        # Delete a security group that you own
        # {API Reference}[https://docs.qingcloud.com/api/sg/delete_security_groups.html]
        def delete_security_groups(id)
          args = Fog::QingCloud.indexed_param('security_groups', id)
          args['action'] = 'DeleteSecurityGroups'
          request(args)
        end

      end

      class Mock
        def delete_security_groups(id)
          ids = [*id]
          if (unknown_groups = ids - self.data[:security_groups].keys).empty?
            used_sgs = []
            ids.each do |id|
              used_sgs << id if self.data[:instances].find {|server_id, s| s['security_group']['security_group_id'] == id}
              used_ids << id if self.data[:routers].find {|rid, r| r['security_group_id'] == id}
            end

            raise Fog::QingCloud::Errors::PermissionDenied, "security groups #{used_sgs.join(', ')} are in use and can't be deleted." unless used_sgs.empty?

            self.data[:security_groups].delete_if {|k, v| ids.include? k}
            
            response = Excon::Response.new
            response.status = 200
            response.body = {
              'action' => 'DeleteSecurityGroupsResponse',
              'security_groups' => ids,
              'ret_code' => 0
            }
            response
          else
            raise Fog::QingCloud::Errors::NotFound, "security group '#{unknown_groups.join(', ')}' does not exist"
          end
        end
      end
    end
  end
end
