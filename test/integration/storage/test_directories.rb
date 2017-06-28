require "helpers/integration_test_helper"
require "integration/storage/storage_shared"
require "securerandom"
require "base64"
require "tempfile"

class TestStorageRequests < StorageShared
  def test_directories_put
    sleep(1)

    dir_name = new_bucket_name
    directory = @client.directories.create(:key => dir_name)
    assert_equal(directory.key, dir_name)
  end

  def test_directories_get
    sleep(1)

    dir_name = new_bucket_name
    @client.directories.create(:key => dir_name)
    directory = @client.directories.get(dir_name)
    assert_equal(directory.key, dir_name)
  end

  def test_directories_destroy
    sleep(1)

    dir_name = new_bucket_name
    @client.directories.create(:key => dir_name)

    @client.directories.destroy(dir_name)

    assert_raises(Google::Apis::ClientError) do
      @client.directories.get(dir_name)
    end
  end

  def test_directories_all
    sleep(1)
    dir_name = new_bucket_name
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
