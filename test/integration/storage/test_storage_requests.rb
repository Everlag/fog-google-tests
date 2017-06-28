require "helpers/integration_test_helper"
require "integration/pubsub/pubsub_shared"
require "securerandom"
require "base64"

class TestStorageRequests < FogIntegrationTest
  def setup
    @client = Fog::Storage::Google.new
    # Ensure any resources we create with test prefixes are removed
    Minitest.after_run do
      # delete_test_resources
    end
  end

  def bucket_prefix
    "fog-integration-test"
  end

  def new_bucket_name
    "#{bucket_prefix}-#{SecureRandom.uuid}"
  end

  def test_put_bucket
    @client.put_bucket(new_bucket_name)
  end

  def test_get_bucket
    # Create a new bucket to grab it
    bucket_name = new_bucket_name
    @client.put_bucket(bucket_name)

    bucket = @client.get_bucket(bucket_name)
    assert_equal(bucket.name, bucket_name)
  end

  def test_delete_bucket
    # Create a new bucket to delete it
    bucket_to_delete = new_bucket_name
    @client.put_bucket(bucket_to_delete)

    @client.delete_bucket(bucket_to_delete)

    assert_raises(Google::Apis::ClientError) do
        @client.get_bucket(bucket_to_delete)
    end
  end
end
