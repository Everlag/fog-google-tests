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
            sleep(1.5)
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

  # def test_put_bucket
  #   sleep(1)
  #
  #   bucket_name = new_bucket_name
  #   bucket = @client.put_bucket(bucket_name)
  #   assert_equal(bucket.name, bucket_name)
  # end
  #
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
  #     @client.get_bucket(bucket_to_delete)
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
  #     raise StandardError.new("no buckets found")
  #   end
  #
  #   contained = result.items.any? { |bucket| bucket.name == bucket_name }
  #   assert_equal(true, contained, "expected bucket not present")
  # end
  #
  # def test_put_object
  #   sleep(1)
  #
  #   @client.put_object(some_bucket_name, new_object_name, some_temp_file_name)
  # end
  #
  # def test_get_object
  #   sleep(1)
  #
  #   content = @client.get_object(some_bucket_name, some_object_name)
  #   assert_equal(temp_file_content, content)
  # end
  #
  # def test_delete_object
  #   sleep(1)
  #
  #   object_name = new_object_name
  #   @client.put_object(some_bucket_name, object_name, some_temp_file_name)
  #   @client.delete_object(some_bucket_name, object_name)
  #
  #   assert_raises(Google::Apis::ClientError) do
  #     @client.get_object(some_bucket_name, object_name)
  #   end
  # end
  #
  # def test_copy_object
  #   sleep(1)
  #
  #   target_object_name = new_object_name
  #
  #   @client.copy_object(some_bucket_name, some_object_name,
  #                                some_bucket_name, target_object_name)
  #   content = @client.get_object(some_bucket_name, target_object_name)
  #   assert_equal(temp_file_content, content)
  # end
  #
  # def test_list_objects
  #   sleep(1)
  #
  #   expected_object = some_object_name
  #
  #   result = @client.list_objects(some_bucket_name)
  #   if result.items.nil?
  #     raise StandardError.new("no objects found")
  #   end
  #
  #   contained = result.items.any? { |object| object.name == expected_object }
  #   assert_equal(true, contained, "expected object not present")
  # end
  #
  # def test_put_bucket_acl
  #   sleep(1)
  #
  #   bucket_name = new_bucket_name
  #   @client.put_bucket(bucket_name)
  #
  #   acl = {
  #       :entity => "allUsers",
  #       :role => "READER"
  #   }
  #   @client.put_bucket_acl(bucket_name, acl)
  # end

  def test_get_bucket_acl
    sleep(1)

    bucket_name = new_bucket_name
    @client.put_bucket(bucket_name)

    acl = {
        :entity => "allUsers",
        :role => "READER"
    }
    @client.put_bucket_acl(bucket_name, acl)

    result = @client.get_bucket_acl(bucket_name)
    if result.items.nil?
      raise StandardError.new("no bucket access controls found")
    end

    contained = result.items.any? { |control| control.entity == acl[:entity] &&
                                              control.role == acl[:role]}
    assert_equal(true, contained, "expected bucket access control not present")
  end

  # def test_put_object_acl
  #   sleep(1)
  #
  #   object_name = new_object_name
  #   @client.put_object(some_bucket_name, object_name, some_temp_file_name)
  #
  #   acl = {
  #       :entity => "allUsers",
  #       :role => "READER"
  #   }
  #   @client.put_object_acl(some_bucket_name, object_name, acl)
  # end
  #
  # def test_get_object_acl
  #   sleep(1)
  #
  #   object_name = new_object_name
  #   @client.put_object(some_bucket_name, object_name, some_temp_file_name)
  #
  #   acl = {
  #       :entity => "allUsers",
  #       :role => "READER"
  #   }
  #   @client.put_object_acl(some_bucket_name, object_name, acl)
  #
  #   result = @client.get_object_acl(some_bucket_name, object_name)
  #   if result.items.nil?
  #     raise StandardError.new("no object access controls found")
  #   end
  #
  #   contained = result.items.any? { |control| control.entity == acl[:entity] &&
  #                                             control.role == acl[:role]}
  #   assert_equal(true, contained, "expected object access control not present")
  # end

end
