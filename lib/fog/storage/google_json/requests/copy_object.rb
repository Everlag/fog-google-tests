module Fog
  module Storage
    class GoogleJSON
      class Real
        # Copy an object from one Google Storage bucket to another
        # https://cloud.google.com/storage/docs/json_api/v1/objects/copy
        #
        # ==== Parameters
        # * source_bucket_name<~String> - Name of source bucket
        # * source_object_name<~String> - Name of source object
        # * target_bucket_name<~String> - Name of bucket to create copy in
        # * target_object_name<~String> - Name for new copy of object
        # * options<~Hash>:
        #   * 'x-goog-metadata-directive'<~String> - Specifies whether to copy metadata from source or replace with data in request.  Must be in ['COPY', 'REPLACE']
        #   * 'x-goog-copy_source-if-match'<~String> - Copies object if its etag matches this value
        #   * 'x-goog-copy_source-if-modified_since'<~Time> - Copies object it it has been modified since this time
        #   * 'x-goog-copy_source-if-none-match'<~String> - Copies object if its etag does not match this value
        #   * 'x-goog-copy_source-if-unmodified-since'<~Time> - Copies object it it has not been modified since this time
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'ETag'<~String> - etag of new object
        #     * 'LastModified'<~Time> - date object was last modified
        #
        def copy_object(source_bucket_name, source_object_name, target_bucket_name, target_object_name, options = {})
          # TODO: respect options
          @storage_json.copy_object(source_bucket_name, source_object_name,
                                    target_bucket_name, target_object_name)
        end
      end

      class Mock
        def copy_object(source_bucket_name, source_object_name, target_bucket_name, target_object_name, _options = {})
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
