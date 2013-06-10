require 'lims-busclient'
require 'common'
require 'lims-order-management-app/sample_json_decoder'
require 'lims-order-management-app/order_creator'
require 'lims-order-management-app/rule_matcher'

module Lims::OrderManagementApp
  class SampleConsumer
    include Lims::BusClient::Consumer
    include RuleMatcher
    include SampleJsonDecoder
    include Virtus
    include Aequitas

    attribute :queue_name, String, :required => true, :writer => :private, :reader => :private
    attribute :log, Object, :required => true, :writer => :private, :reader => :private
    attribute :order_creator, OrderCreator, :required => true, :writer => :private, :reader => :private

    NoSamplePublished = Class.new(StandardError)

    SAMPLE_PUBLISHED_STATE = "published"
    EXPECTED_ROUTING_KEY_PATTERNS = [
      '*.*.sample.create', '*.*.sample.updatesample', 
      '*.*.bulkcreatesample.*', '*.*.bulkupdatesample.*' 
    ].map { |k| Regexp.new(k.gsub(/\./, "\\.").gsub(/\*/, "[^\.]*")) }

    def initialize(amqp_settings, api_settings)
      @queue_name = amqp_settings.delete("queue_name")
      consumer_setup(amqp_settings)
      @order_creator = OrderCreator.new(api_settings)
      set_queue
    end

    def set_logger(logger)
      @log = logger
    end

    private

    # @param [Array] samples
    def before_filter!(samples)
      samples.reject! do |resource|
        resource[:sample].state != SAMPLE_PUBLISHED_STATE 
      end
      raise NoSamplePublished, "No samples with a published state found" if samples.empty?
    end

    def set_queue
      self.add_queue(queue_name) do |metadata, payload|
        log.info("Message received with the routing key: #{metadata.routing_key}") 
        if expected_message?(metadata.routing_key)
          log.debug("Processing message with routing key: '#{metadata.routing_key}' and payload: #{payload}") 
          consume_message(metadata, payload)
        else
          metadata.reject
          log.debug("Message rejected: unexpected message (routing key: #{metadata.routing_key})") 
        end
      end
    end

    def consume_message(metadata, payload)
      begin
        samples = sample_resource(payload)
        # TODO : before_filter!(samples)
        # TODO: we assume hereby that all the samples 
        # have the same sample_type and the same lysed option.
        pipeline = matching_rule(samples.first[:sample])
        order_creator.execute(samples, pipeline)
      rescue NoSamplePublished, RuleMatcher::NonMatchingRule => e
        metadata.reject
        log.error("Sample message rejected: #{e}")
      rescue OrderCreator::TubeNotFound => e
        metadata.reject(:requeue => true)
        log.error("Sample message requeued: #{e}")
      else
        #metadata.ack
        log.info("Sample message processed and acknowledged. Order created.")
      end
    end

    def expected_message?(routing_key)
      EXPECTED_ROUTING_KEY_PATTERNS.each do |pattern|
        return true if routing_key.match(pattern)
      end
      false
    end
  end
end
