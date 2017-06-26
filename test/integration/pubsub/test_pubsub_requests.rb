require "helpers/integration_test_helper"
require "securerandom"
require "base64"

class TestPubsubRequests < FogIntegrationTest
  def setup
    @client = Fog::Google::Pubsub.new
    # Ensure any resources we create with test prefixes are removed
    Minitest.after_run do
     delete_test_resources
    end
  end

  def delete_test_resources
    result = @client.list_topics
    unless result.topics.nil?
      result.topics.
          map { |t| t.name }.
          select { |t| t.start_with?(topic_resource_prefix) }.
          each { |t| @client.delete_topic(t) }
    end

    # subscriptions = @client.list_subscriptions[:body]["subscriptions"]
    # unless subscriptions.nil?
    #   subscriptions.
    #     map { |s| s["name"] }.
    #     select { |s| s.start_with?(subscription_resource_prefix) }.
    #     each { |s| @client.delete_subscription(s) }
    # end
  end

  def topic_resource_prefix
    "projects/#{@client.project}/topics/fog-integration-test"
  end

  def subscription_resource_prefix
    "projects/#{@client.project}/subscriptions/fog-integration-test"
  end

  def new_topic_name
    "#{topic_resource_prefix}-#{SecureRandom.uuid}"
  end

  def new_subscription_name
    "#{subscription_resource_prefix}-#{SecureRandom.uuid}"
  end

  def some_topic_name
    # create lazily to speed tests up
    @some_topic ||= new_topic_name.tap do |t|
      @client.create_topic(t)
    end
    @some_topic
  end

  def some_subscription_name
    # create lazily to speed tests up
    @some_subscription ||= new_subscription_name.tap do |s|
      @client.create_subscription(s, some_topic_name)
    end
    @some_subscription
  end

  def test_create_topic
    name = new_topic_name
    result = @client.create_topic(name)
    assert_equal(result.name, name)
  end

  def test_get_topic
    result = @client.get_topic(some_topic_name)
    assert_equal(result.name, some_topic_name)
  end

  def test_list_topics
    # Force a topic to be created just so we have at least 1 to list
    name = new_topic_name
    @client.create_topic(name)
    result = @client.list_topics

    contained = result.topics.any? {
      |topic| topic.name == name
    }
    assert_equal(true, contained, 'known topic not contained within listed topics')
  end

  def test_delete_topic
    topic_to_delete = new_topic_name
    @client.create_topic(topic_to_delete)

    @client.delete_topic(topic_to_delete)
  end

  def test_publish_topic
    @client.publish_topic(some_topic_name , [:data => Base64.strict_encode64("some message")])
  end

  def test_create_subscription
    push_config = {}
    ack_deadline_seconds = 18

    subscription_name = new_subscription_name
    result = @client.create_subscription(subscription_name, some_topic_name,
                                         push_config, ack_deadline_seconds)
    assert_equal(result.name, subscription_name)
  end

  def test_get_subscription
    subscription_name = some_subscription_name
    result = @client.get_subscription(subscription_name )

    assert_equal(result.name, subscription_name)
  end

  def test_list_subscriptions
    # Force a subscription to be created just so we have at least 1 to list
    subscription_name = new_subscription_name
    @client.create_subscription(subscription_name , some_topic_name)
    result = @client.list_subscriptions

    contained = result.subscriptions.any? {
        |sub| sub.name == subscription_name
    }
    assert_equal(true, contained, 'known subscription not contained within listed subscriptions')
  end

  def test_delete_subscription
    subscription_to_delete = new_subscription_name
    @client.create_subscription(subscription_to_delete, some_topic_name)

    result = @client.delete_subscription(subscription_to_delete)
  end

  def test_pull_subscription
    subscription_name = new_subscription_name
    message_bytes= Base64.strict_encode64("some message")
    @client.create_subscription(subscription_name, some_topic_name)
    @client.publish_topic(some_topic_name, [:data => message_bytes])

    result = @client.pull_subscription(subscription_name)

    contained = result.received_messages.any? {
        |received| received.message.data== message_bytes
    }
    assert_equal(true, contained, 'sent messsage not contained within pulled responses')
  end

  # def test_acknowledge_subscription
  #   subscription = new_subscription_name
  #   @client.create_subscription(subscription, some_topic_name)
  #   @client.publish_topic(some_topic_name, [:data => Base64.strict_encode64("some message")])
  #   pull_result = @client.pull_subscription(subscription)
  #
  #   result = @client.acknowledge_subscription(subscription, pull_result[:body]["receivedMessages"][0]["ackId"])
  #
  #   assert_equal(200, result.status, "request should be successful")
  # end
end
