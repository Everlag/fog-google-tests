module Fog
  module Storage
    class GoogleJSON
      class Real
        # Delete an Google Storage bucket
        # https://cloud.google.com/storage/docs/json_api/v1/buckets/delete
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to delete
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * status<~Integer> - 204
        def delete_bucket(bucket_name)
          @storage_json.delete_bucket(bucket_name)
        end
      end

      class Mock
        def delete_bucket(_bucket_name)
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
