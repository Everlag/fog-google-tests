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
end
