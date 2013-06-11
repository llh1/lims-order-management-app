require 'common'
require 'lims-order-management-app/helpers/api'

module Lims::OrderManagementApp
  class OrderCreator
    include Virtus
    include Aequitas
    include Helpers::API

    TubeNotFound = Class.new(StandardError)
    INPUT_TUBE_ROLE = "samples.extraction.manual.dna_and_rna.input_tube_nap"
    USER_UUID = "66666666-2222-4444-9999-000000000000"
    STUDY_UUID = "55555555-2222-3333-6666-777777777777"
    COST_CODE = "cost code"

    # @param [Hash] api_settings
    def initialize(api_settings)
      url = api_settings["url"]      
      initialize_api(url)
    end

    # @param [Array] samples
    # @param [String] pipeline
    def execute(samples, pipeline)
      sample_uuids = samples.inject([]) { |m,e| m << e[:uuid] }
      tube_uuids = tubes_by_sample_uuids(sample_uuids)
      order_parameters = generate_order_parameters(tube_uuids, pipeline)
      post_order(order_parameters)
    end

    private

    # @param [String] sample_uuids
    # @return [Array]
    # Return an array of tube uuids which contain the samples.
    def tubes_by_sample_uuids(sample_uuids)
      parameters = {:search => {
        :description => "search for tubes by sample uuids",
        :model => "tube",
        :criteria => {
          :sample => {:uuid => sample_uuids}
        }
      }}
      search = post(url_for(:searches, :create), parameters)
      result_url = search["search"]["actions"]["first"]
      result = get(result_url)

      sample_uuids_in_tubes = [].tap do |uuids|
        result["tubes"].each do |tube|
          tube["aliquots"].each do |aliquot|
            uuids << aliquot["sample"]["uuid"]
          end
        end
      end.uniq

      orphan_sample_uuids = sample_uuids - sample_uuids_in_tubes
      raise TubeNotFound, "Can't find a tube containing the samples #{orphan_sample_uuids.to_s}" unless orphan_sample_uuids.empty? 
      result["tubes"].inject([]) { |m,e| m << e["uuid"]}
    end

    # @param [Array] tube_uuids
    # @param [String] pipeline
    # @return [Hash]
    def generate_order_parameters(tube_uuids, pipeline)
      {:order => {}.tap do |p|
        p[:user_uuid] = USER_UUID 
        p[:study_uuid] = STUDY_UUID 
        p[:pipeline] = pipeline
        p[:cost_code] = COST_CODE 
        p[:sources] = {INPUT_TUBE_ROLE => tube_uuids}
      end
      }
    end

    # @param [Hash] order_parameters
    def post_order(order_parameters)
      post(url_for(:orders, :create), order_parameters)
    end
  end
end
