module Fog
  module Storage
    class GoogleJSON
      class Real
        # Change access control list for an Google Storage bucket
        # https://cloud.google.com/storage/docs/json_api/v1/bucketAccessControls/insert
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to create
        # * acl<~Hash> - ACL hash to add to bucket, see GCS documentation above
        #    * entity
        #    * role
        def put_bucket_acl(bucket_name, acl)
          raise ArgumentError.new("bucket_name is required") unless bucket_name
          raise ArgumentError.new("acl is required") unless acl

          acl_update = ::Google::Apis::StorageV1::ObjectAccessControl.new(
              :entity => acl[:entity],
              :role => acl[:role],
          )

          @storage_json.insert_bucket_access_control(bucket_name, acl_update)
        end
      end

      class Mock
        def put_bucket_acl(_bucket_name, _acl)
          Fog::Mock.not_implemented
        end
      end
    end
  end
end
