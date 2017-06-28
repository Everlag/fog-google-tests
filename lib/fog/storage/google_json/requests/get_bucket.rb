module Fog
  module Storage
    class GoogleJSON
      class Real
        # List information about objects in an Google Storage bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to list object keys from
        # * options<~Hash> - config arguments for list.  Defaults to {}.
        #   * 'ifMetagenerationMatch'<~Long> - Makes the return of the bucket metadata
        #     conditional on whether the bucket's current metageneration matches the
        #     given value.
        #   * 'ifMetagenerationNotMatch'<~Long> - Makes the return of the bucket
        #     metadata conditional on whether the bucket's current metageneration does
        #     not match the given value.
        #   * 'projection'<~String> - Set of properties to return. Defaults to 'noAcl',
        #     also accepts 'full'.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     See Google documentation on Bucket resource:
        #     https://cloud.google.com/storage/docs/json_api/v1/buckets#resource
        #

        def get_bucket(bucket_name, options = {})
          raise ArgumentError.new("bucket_name is required") unless bucket_name

          @storage_json.get_bucket(bucket_name,
                                   :if_metageneration_match => options["ifMetagenerationMatch"],
                                   :if_metageneration_not_match => options["ifMetagenerationNotMatch"],
                                   :projection => options["projection"])
        end
      end

      class Mock
        def get_bucket(_bucket_name, _options = {})
          raise Fog::Errors::MockNotImplemented
        end
      end
    end
  end
end
