require "helpers/integration_test_helper"
require "integration/pubsub/pubsub_shared"
require "securerandom"
require "base64"
require "tempfile"

class TestStorageRequests < FogIntegrationTest
  def setup
    @client = Fog::Storage::Google.new
    # Ensure any resources we create with test prefixes are removed
    Minitest.after_run do
      # delete_test_resources
    end
  end

  def delete_test_resources
    puts "a temp file name is #{some_temp_file_name}"

    unless @some_temp_file.nil?
      @some_temp_file.close
      @some_temp_file.unlink
    end

    buckets_result = @client.list_buckets

    unless buckets_result.items.nil?
      begin
        buckets_result.items.
            map(&:name).
            select { |t| t.start_with?(bucket_prefix) }.
            each { |t|
              begin
              sleep(1.5)
              @client.delete_bucket(t)
              # Given that bucket operations are specifically rate-limited, we handle that
              # by waiting a significant amount of time and trying.
              rescue Google::Apis::RateLimitError
                sleep(10)
                @client.delete_bucket(t)
              end
              }
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

  def new_bucket_name
    "#{bucket_prefix}-#{SecureRandom.uuid}"
  end

  def some_bucket_name
    # create lazily to speed tests up
    @some_bucket ||= new_bucket_name.tap do |t|
      @client.put_bucket(t)
    end
  end

  def temp_file_content
    "hello world"
  end

  def some_temp_file_name
    @some_temp_file ||= Tempfile.new("fog-google-storage").tap do |t|
      t.write(temp_file_content)
    end
    @some_temp_file.path
  end

  def test_put_bucket
    sleep(1)

    bucket_name = new_bucket_name
    bucket = @client.put_bucket(bucket_name)
    assert_equal(bucket.name, bucket_name)
  end

  # def test_get_bucket
  #   sleep(1)
  #
  #   bucket = @client.get_bucket(some_bucket_name)
  #   assert_equal(bucket.name, some_bucket_name)
  # end
  #
  # def test_delete_bucket
  #   sleep(1)
  #
  #   # Create a new bucket to delete it
  #   bucket_to_delete = new_bucket_name
  #   @client.put_bucket(bucket_to_delete)
  #
  #   @client.delete_bucket(bucket_to_delete)
  #
  #   assert_raises(Google::Apis::ClientError) do
  #       @client.get_bucket(bucket_to_delete)
  #   end
  # end
  #
  # def test_list_buckets
  #   sleep(1)
  #
  #   # Create a new bucket to ensure at least one exists to find
  #   bucket_name = new_bucket_name
  #   @client.put_bucket(bucket_name)
  #
  #   result = @client.list_buckets
  #   if result.items.nil?
  #     raise StandardError("no buckets found")
  #   end
  #
  #   contained = result.items.any? { |bucket| bucket.name == bucket_name }
  #   assert_equal(true, contained, "expected bucket not present")
  # end

  def test_put_object
    sleep(1)

    @client.put_object(some_bucket_name, "some_object", some_temp_file_name)
  end

end
