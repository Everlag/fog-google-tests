require "tempfile"

module Fog
  module Storage
    class GoogleJSON
      class Real
        # Get an object from Google Storage
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
        #
        def get_object(bucket_name, object_name, options = {}, &_block)
          raise ArgumentError.new("bucket_name is required") unless bucket_name
          raise ArgumentError.new("object_name is required") unless object_name

          # The previous semantics require returning the content of the request
          # rather than taking a filename to populate. Hence, tempfile.
          buf = Tempfile.new("fog-google-storage-temp")

          # Two requests are necessary, first for metadata, then for content.
          # google-api-ruby-client doesn't allow fetching both metadata and content
          request_options = ::Google::Apis::RequestOptions.default.merge(options)
          object = @storage_json.get_object(bucket_name, object_name,
                                            :options => request_options).to_h
          @storage_json.get_object(bucket_name, object_name,
                                   :download_dest => buf.path,
                                   :options => request_options)

          object[:body] = buf.read
          buf.unlink


          object
        end
      end

      class Mock
        def get_object(_bucket_name, _object_name, _options = {})
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
