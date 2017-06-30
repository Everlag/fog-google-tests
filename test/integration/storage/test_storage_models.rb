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

  def bucket_prefix
    "fog-integration-test"
  end

  def object_prefix
    "fog-integration-test-object"
  end

  def new_directory_name
    "#{bucket_prefix}-#{SecureRandom.uuid}"
  end

  def new_file_name
    "#{object_prefix}-#{SecureRandom.uuid}"
  end

  # def test_directories_put
  #   sleep(1)
  #
  #   dir_name = new_directory_name
  #   directory = @client.directories.create(:key => dir_name)
  #   assert_equal(directory.key, dir_name)
  # end
  #
  # def test_directories_get
  #   sleep(1)
  #
  #   dir_name = new_directory_name
  #   @client.directories.create(:key => dir_name)
  #   directory = @client.directories.get(dir_name)
  #   assert_equal(directory.key, dir_name)
  # end

  def test_directories_all
    sleep(1)
    dir_name = new_directory_name
    @client.directories.create(:key => dir_name)

    result = @client.directories.all
    if result.nil?
      raise StandardError.new("no directories found")
    end

    unless result.any? { |directory| directory.key == dir_name }
      raise StandardError.new("failed to find expected directory")
    end
  end
end
