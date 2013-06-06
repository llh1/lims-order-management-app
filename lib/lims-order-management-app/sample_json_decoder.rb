require 'lims-management-app/sample/sample'
require 'json'

module Lims::OrderManagementApp
  module SampleJsonDecoder

    UndefinedDecoder = Class.new(StandardError)

    private

    # @param [String] payload
    # @return [Object] sample resource
    def sample_resource(payload)
      body = JSON.parse(payload)
      model = body.keys.first
      sample_decoder_for(model).call(body)
    end

    def sample_decoder_for(model)
      begin
        decoder = "#{model.to_s.capitalize.gsub(/_./) {|p| p[1].upcase}}Decoder"
        self.class.const_get(decoder)
      rescue NameError => e
        raise UndefinedDecoder, "#{decoder} is undefined"
      end
    end

    module SampleDecoder
      def self.call(json)
        sample_hash = json["sample"]
        sample(sample_hash)
      end

      def self.sample(sample_hash, options)
        sample = Lims::ManagementApp::Sample.new
        sample_hash.each do |k,v|
          sample.send("#{k}=", v) if sample.respond_to?("#{k}=")
        end
        {:sample => sample, :uuid => sample_hash["uuid"]}
      end
    end

    module BulkSampleDecoder
      def self.call(action, json)
        bulk_sample_hash = json[action.to_s]
        samples_hash = bulk_sample_hash["result"]["samples"]
        samples = []
        samples_hash.each do |sample_hash|
          samples << SampleJsonDecoder::SampleDecoder.sample(sample_hash)
        end
        {:samples => samples}
      end
    end

    module BulkCreateSampleDecoder
      def call(json)
        BulkSampleJsonDecoder.call("bulk_create_sample", json)
      end
    end

    module BulkUpdateSampleDecoder
      def call(json)
        BulkSampleJsonDecoder.call("bulk_create_sample", json)
      end
    end
  end
end