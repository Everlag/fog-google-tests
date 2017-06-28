module Fog
  module Storage
    class GoogleJSON
      class Real
        # Create an object in an Google Storage bucket
        # https://cloud.google.com/storage/docs/json_api/v1/objects/insert
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to create object in
        # * object_name<~String> - Name of object to create
        # * data<~File> - File or String to create object from
        # * options<~Hash>:
        #   * 'Cache-Control'<~String> - Caching behaviour
        #   * 'Content-Disposition'<~String> - Presentational information for the object
        #   * 'Content-Encoding'<~String> - Encoding of object data
        #   * 'Content-MD5'<~String> - Base64 encoded 128-bit MD5 digest of message (defaults to Base64 encoded MD5 of object.read)
        #   * 'Content-Type'<~String> - Standard MIME type describing contents (defaults to MIME::Types.of.first)
        #   * 'x-goog-acl'<~String> - Permissions, must be in ['private', 'public-read', 'public-read-write', 'authenticated-read']
        #   * "x-goog-meta-#{name}" - Headers to be returned with object, note total size of request without body must be less than 8 KB.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * headers<~Hash>:
        #     * 'ETag'<~String> - etag of new object
        def put_object(bucket_name, object_name, data, options = {})
          object_config = ::Google::Apis::StorageV1::Object.new(
            :name => object_name,
          )
          request_options = ::Google::Apis::RequestOptions.default.merge(options)

          @storage_json.insert_object(bucket_name, object_config,
                                      :upload_source => data,
                                      :options => request_options)
        end
      end

      class Mock
        def put_object(_bucket_name, _object_name, _data, _options = {})
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
