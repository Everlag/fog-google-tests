module Fog
  module Storage
    class GoogleJSON
      class Real
        # Get headers for an object from Google Storage
        # https://cloud.google.com/storage/docs/json_api/v1/objects/get
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket to read from
        # * object_name<~String> - Name of object to read
        # * options<~Hash>:
        #   * 'If-Match'<~String> - Returns object only if its etag matches this value, otherwise returns 412 (Precondition Failed).
        #   * 'If-Modified-Since'<~Time> - Returns object only if it has been modified since this time, otherwise returns 304 (Not Modified).
        #   * 'If-None-Match'<~String> - Returns object only if its etag differs from this value, otherwise returns 304 (Not Modified)
        #   * 'If-Unmodified-Since'<~Time> - Returns object only if it has not been modified since this time, otherwise returns 412 (Precodition Failed).
        #   * 'Range'<~String> - Range of object to download
        #   * 'versionId'<~String> - specify a particular version to retrieve
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~String> - Contents of object
        #   * headers<~Hash>:
        #     * 'Content-Length'<~String> - Size of object contents
        #     * 'Content-Type'<~String> - MIME type of object
        #     * 'ETag'<~String> - Etag of object
        #     * 'Last-Modified'<~String> - Last modified timestamp for object
        def head_object(bucket_name, object_name, options = {})
          raise ArgumentError.new("bucket_name is required") unless bucket_name
          raise ArgumentError.new("object_name is required") unless object_name

          request_options = ::Google::Apis::RequestOptions.default.merge(options)
          @storage_json.get_object(bucket_name, object_name,
                                            :options => request_options).to_h
        end
      end

      class Mock
        def head_object(bucket_name, object_name, options = {})
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
