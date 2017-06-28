module Fog
  module Storage
    class GoogleJSON
      class Real
        # Get access control list for an Google Storage object
        # https://cloud.google.com/storage/docs/json_api/v1/objectAccessControls/get
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket containing object
        # * object_name<~String> - name of object to get access control list for
        # * options<~Hash>:
        #   * 'versionId'<~String> - specify a particular version to retrieve
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
        def get_object_acl(bucket_name, object_name, options = {})
          raise ArgumentError.new("bucket_name is required") unless bucket_name
          raise ArgumentError.new("object_name is required") unless object_name

          @storage_json.list_object_access_controls(bucket_name, object_name,
                                                    :generation => options["versionId"])
        end
      end

      class Mock
        def get_object_acl(bucket_name, object_name)
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
