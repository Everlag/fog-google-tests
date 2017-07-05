module Fog
  module Storage
    class GoogleJSON
      class Files < Fog::Collection
        extend Fog::Deprecation
        deprecate :get_url, :get_https_url

        attribute :common_prefixes, :aliases => "CommonPrefixes"
        attribute :delimiter,       :aliases => "Delimiter"
        attribute :directory
        attribute :page_token,      :aliases => %w(pageToken page_token)
        attribute :max_results,     :aliases => ["MaxKeys", "max-keys"]
        attribute :prefix,          :aliases => "Prefix"

        model Fog::Storage::GoogleJSON::File

        def all(options = {})
          requires :directory

          data = service.list_objects(directory.key, options).to_h[:items] || []
          data = data.each { |object| object[:key] = object[:name] }
          load(data)
        end

        alias_method :each_file_this_page, :each
        def each
          if !block_given?
            self
          else
            subset = dup.all

            subset.each_file_this_page { |f| yield f }
            while subset.is_truncated
              subset = subset.all(:marker => subset.last.key)
              subset.each_file_this_page { |f| yield f }
            end

            self
          end
        end

        def get(key, options = {}, &block)
          requires :directory
          data = service.get_object(directory.key, key, options, &block)
          new(:key => key,
              :body => data)
        rescue Fog::Errors::NotFound
          nil
        end

        def get_https_url(key, expires)
          requires :directory
          service.get_object_https_url(directory.key, key, expires)
        end

        def head(key, options = {})
          requires :directory
          data = service.head_object(directory.key, key, options)
          file_data = data.headers.merge(:key => key)
          new(file_data)
        rescue Fog::Errors::NotFound
          nil
        end

        def new(attributes = {})
          requires :directory
          super({ :directory => directory }.merge(attributes))
        end
      end
    end
  end
end
