module Fog
  module Storage
    class GoogleJSON
      class File < Fog::Model
        identity :key, :aliases => ["Key", :name]

        attribute :acl
        attribute :predefined_acl
        attribute :cache_control,       :aliases => ["cacheControl",
                                                                    :cache_control]
        attribute :content_disposition, :aliases => ["contentDisposition",
                                                                    :content_disposition]
        attribute :content_encoding,    :aliases => ["contentEncoding",
                                                                    :content_encoding]
        attribute :content_length,      :aliases => ["size", :size], :type => :integer
        attribute :content_md5,         :aliases => ["md5Hash", :md5_hash]
        attribute :content_type,        :aliases => ["contentType", :content_type]
        attribute :crc32c
        attribute :etag,                :aliases => ["etag", :etag]
        attribute :time_created,        :aliases => ["timeCreated", :time_created]
        attribute :last_modified,       :aliases => ["updated", :updated]
        attribute :generation
        attribute :metageneration
        attribute :metadata,            :aliases => ["metadata", :metadata]
        attribute :self_link,           :aliases => ["selfLink", :self_link]
        attribute :media_link,          :aliases => ["mediaLink", :media_link]
        attribute :owner
        attribute :storage_class, :aliases => "storageClass"

        @valid_predefined_acls = %w(private projectPrivate bucketOwnerFullControl bucketOwnerRead authenticatedRead publicRead)

        def predefined_acl=(new_acl)
          unless @valid_predefined_acls.include?(new_acl)
            raise ArgumentError.new("acl must be one of [#{@valid_predefined_acls.join(', ')}]")
          end
          @predefined_acl = new_acl
        end

        # TODO: Implement object ACLs
        # def acl=(new_acl)
        #   valid_acls = ["private", "projectPrivate", "bucketOwnerFullControl", "bucketOwnerRead", "authenticatedRead", "publicRead"]
        #   unless valid_acls.include?(new_acl)
        #     raise ArgumentError.new("acl must be one of [#{valid_acls.join(', ')}]")
        #   end
        #   @acl = new_acl
        # end

        def body
          attributes[:body] ||= last_modified && (file = collection.get(identity)) ? file.body : ""
        end

        def body=(new_body)
          attributes[:body] = new_body
        end

        attr_reader :directory

        def copy(target_directory_key, target_file_key, options = {})
          requires :directory, :key
          service.copy_object(directory.key, key, target_directory_key, target_file_key, options)
          target_directory = service.directories.new(:key => target_directory_key)
          target_directory.files.get(target_file_key)
        end

        def destroy
          requires :directory, :key
          service.delete_object(directory.key, key)
          true
        rescue Fog::Errors::NotFound
          false
        end

        remove_method :metadata=
        def metadata=(new_metadata)
          if attributes[:metadata].nil?
            attributes[:metadata] = {}
          end
          attributes[:metadata].merge!(new_metadata)
        end

        # TODO: Not functional
        remove_method :owner=
        def owner=(new_owner)
          if new_owner
            attributes[:owner] = {
              :entity => new_owner["entity"],
              :entityId  => new_owner["entityId"]
            }
          end
        end

        def public=(new_public)
          if new_public
            @predefined_acl = "publicRead"
          else
            @predefined_acl = "private"
          end
          new_public
        end

        def public_url
          requires :directory, :key

          acl = service.get_object_acl(directory.key, key).body
          access_granted = acl["items"].detect { |entry| entry["entity"] == "allUsers" && entry["role"] == "READER" }

          if access_granted
            if directory.key.to_s =~ /^(?:[a-z]|\d(?!\d{0,2}(?:\.\d{1,3}){3}$))(?:[a-z0-9]|\.(?![\.\-])|\-(?![\.])){1,61}[a-z0-9]$/
              "https://#{directory.key}.storage.googleapis.com/#{key}"
            else
              "https://storage.googleapis.com/#{directory.key}/#{key}"
            end
          end
        end

        def save(options = {})
          requires :body, :directory, :key
          if options != {}
            Fog::Logger.deprecation("options param is deprecated, use acl= instead [light_black](#{caller.first})[/]")
          end
          options["contentType"] = content_type if content_type
          options["predefinedAcl"] ||= @predefined_acl if @predefined_acl # predefinedAcl may need to be in parameters
          options["acl"] ||= @acl if @acl # Not sure if you can provide both acl and predefinedAcl
          options["cacheControl"] = cache_control if cache_control
          options["contentDisposition"] = content_disposition if content_disposition
          options["contentEncoding"] = content_encoding if content_encoding
          options["metadata"] = metadata

          service.put_object(directory.key, key, body, options)
          self.content_length = Fog::Storage.get_body_size(body)
          self.content_type ||= Fog::Storage.get_content_type(body)
          true
        end

        # params[:expires] : Eg: Time.now to integer value.
        def url(expires)
          requires :key
          collection.get_https_url(key, expires)
        end

        private

        attr_writer :directory
      end
    end
  end
end
