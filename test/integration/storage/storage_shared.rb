require "helpers/integration_test_helper"
require "integration/pubsub/pubsub_shared"
require "securerandom"
require "base64"
require "tempfile"

class StorageShared < FogIntegrationTest
  def setup
    @client = Fog::Storage::Google.new
    # Ensure any resources we create with test prefixes are removed
    Minitest.after_run do
      delete_test_resources
    end
  end

  def delete_test_resources
    unless @some_temp_file.nil?
      @some_temp_file.unlink
    end

    buckets_result = @client.list_buckets

    unless buckets_result.items.nil?
      begin
        buckets_result.items.
            map(&:name).
            select { |t| t.start_with?(bucket_prefix) }.
            each do |t|
          object_result = @client.list_objects(t)
          unless object_result.items.nil?
            object_result.items.each { |object| @client.delete_object(t, object.name) }
          end

          begin
            sleep(2)
            @client.delete_bucket(t)
              # Given that bucket operations are specifically rate-limited, we handle that
              # by waiting a significant amount of time and trying.
          rescue Google::Apis::RateLimitError
            puts "encountered rate limit, backing off"
            sleep(10)
            @client.delete_bucket(t)
          end
        end
          # We ignore errors here as they are flaky due to the delay in list operations
          # representing our operations.
      rescue Google::Apis::Error
        puts "ignoring Google Api error during delete_test_resources"
      end
    end
  end

  def bucket_prefix
    "fog-integration-test"
  end

  def object_prefix
    "fog-integration-test-object"
  end

  def new_bucket_name
    "#{bucket_prefix}-#{SecureRandom.uuid}"
  end

  def new_object_name
    "#{object_prefix}-#{SecureRandom.uuid}"
  end

  def some_bucket_name
    # create lazily to speed tests up
    @some_bucket ||= new_bucket_name.tap do |t|
      sleep(1.5)
      @client.put_bucket(t)
    end
  end

  def some_object_name
    # create lazily to speed tests up
    @some_object ||= new_object_name.tap do |t|
      @client.put_object(some_bucket_name, t, some_temp_file_name)
    end
  end

  def temp_file_content
    "hello world"
  end

  def some_temp_file_name
    @some_temp_file ||= Tempfile.new("fog-google-storage").tap do |t|
      t.write(temp_file_content)
      t.close
    end
    @some_temp_file.path
  end
end
