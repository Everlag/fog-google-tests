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

  def test_files_create
    sleep(1)

    @client.directories.get(some_bucket_name).files.create(
        :key => new_object_name,
        :body => some_temp_file_name
    )
  end

  def test_files_get
    sleep(1)

    content = @client.directories.get(some_bucket_name).files.get(some_object_name)
    assert_equal(content.body, temp_file_content)
  end

  def test_files_head
    sleep(1)

    content = @client.directories.get(some_bucket_name).files.head(some_object_name)
    assert_equal(content.content_length, temp_file_content.length)
    assert_equal(content.key, some_object_name)
  end

  def test_files_destroy
    sleep(1)

    file_name = new_object_name
    @client.directories.get(some_bucket_name).files.create(
        :key => file_name,
        :body => some_temp_file_name
    )

    @client.directories.get(some_bucket_name).files.destroy(file_name)

    assert_raises(Google::Apis::ClientError) do
      @client.directories.get(some_bucket_name).files.get(file_name)
    end
  end

  def test_files_all
    sleep(1)

    file_name = new_object_name
    @client.directories.get(some_bucket_name).files.create(
        :key => file_name,
        :body => some_temp_file_name
    )

    result = @client.directories.get(some_bucket_name).files.all
    if result.nil?
      raise StandardError.new("no files found")
    end

    unless result.any? { |file| file.key == file_name  }
      raise StandardError.new("failed to find expected file")
    end
  end

  def test_files_each
    file_name = new_object_name
    @client.directories.get(some_bucket_name).files.create(
        :key => file_name,
        :body => some_temp_file_name
    )

    found_file = false
    @client.directories.get(some_bucket_name).files.each do |file|
      if file.key == file_name
        found_file = true
      end
    end
    assert_equal(found_file, true, "failed to find expected file while iterating")
  end

  def test_files_copy
    sleep(1)

    target_object_name = new_object_name
    @client.directories.get(some_bucket_name).files.get(some_object_name)
        .copy(some_bucket_name, target_object_name)

    content = @client.directories.get(some_bucket_name).files.get(target_object_name)
    assert_equal(content.body, temp_file_content)
  end

end
