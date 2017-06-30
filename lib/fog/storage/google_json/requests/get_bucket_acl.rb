module Fog
  module Storage
    class GoogleJSON
      class Real
        # Get access control list for an Google Storage bucket
        # https://cloud.google.com/storage/docs/json_api/v1/bucketAccessControls/list
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to get access control list for
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'AccessControlPolicy'<~Hash>
        #       * 'Owner'<~Hash>:
        #         * 'DisplayName'<~String> - Display name of object owner
        #         * 'ID'<~String> - Id of object owner
        #       * 'AccessControlList'<~Array>:
        #         * 'Grant'<~Hash>:
        #           * 'Grantee'<~Hash>:
        #              * 'DisplayName'<~String> - Display name of grantee
        #              * 'ID'<~String> - Id of grantee
        #             or
        #              * 'URI'<~String> - URI of group to grant access for
        #           * 'Permission'<~String> - Permission, in [FULL_CONTROL, WRITE, WRITE_ACP, READ, READ_ACP]
        #
        def get_bucket_acl(bucket_name)
          raise ArgumentError.new("bucket_name is required") unless bucket_name

          @storage_json.list_bucket_access_controls(bucket_name)
        end
      end

      class Mock
        def get_bucket_acl(bucket_name)
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
