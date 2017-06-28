module Fog
  module Storage
    class GoogleJSON
      class Real
        # Create a Google Storage bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to create
        # * options<~Hash> - config arguments for bucket.  Defaults to {}.
        #   * 'LocationConstraint'<~Symbol> - sets the location for the bucket
        #   * 'predefinedAcl'<~String> - Apply a predefined set of access controls to this bucket.
        #   * 'predefinedDefaultObjectAcl'<~String> - Apply a predefined set of default object access controls to this bucket.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * status<~Integer> - 200
        #
        # ==== See also
        # https://cloud.google.com/storage/docs/json_api/v1/buckets/insert
        def put_bucket(bucket_name, options = {})
          bucket = ::Google::Apis::StorageV1::Bucket.new(
            :name => bucket_name,
            :location => options["LocationConstraint"]
          )

          @storage_json.insert_bucket(@project, bucket,
                                      :predefined_acl => options["predefinedAcl"],
                                      :predefined_default_object_acl => options["predefined_default_object_acl"],
                                      :projection => "full")
        end
      end

      class Mock
        def put_bucket(_bucket_name, _options = {}, _body_options = {})
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
