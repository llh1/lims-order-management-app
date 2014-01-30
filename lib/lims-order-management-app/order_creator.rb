require 'common'
require 'lims-order-management-app/helpers/api'
require 'lims-order-management-app/rule_matcher'

module Lims::OrderManagementApp
  class OrderCreator
    include Virtus
    include Aequitas
    include Helpers::API
    include Lims::OrderManagementApp::RuleMatcher

    SampleContainerNotFound = Class.new(StandardError)

    attribute :user_email, String, :required => true, :writer => :private
    attribute :study_uuid, String, :required => true, :writer => :private
    attribute :cost_code, String, :required => true, :writer => :private

    # @param [Hash] api_settings
    def initialize(order_settings, api_settings, rule_settings)
      url = api_settings["url"]      
      @user_email = order_settings["user_email"]
      @study_uuid = order_settings["study_uuid"]
      @cost_code = order_settings["cost_code"]
      initialize_api(url, @user_email)
      initialize_rules(rule_settings)
    end

    # @param [Array] samples
    def create!(samples)
      container_roles = container_roles(samples)
      order_parameters = order_parameters(container_roles)
      post_order(order_parameters)
    end

    private

    # @param [Array] samples
    # @return [Hash] 
    # @example: {"11111111-2222-3333-4444-555555555555" => "role"}
    def container_roles(samples)
      {}.tap do |result|
        samples.each do |sample_data|
          matching_rule(sample_data[:sample]).each do |container_uuid, role|
            result[container_uuid] = role unless result.has_key?(container_uuid)
          end
        end
      end
    end

    # @param [Hash] container_roles
    # @return [Hash]
    def order_parameters(container_roles)
      roles_to_container_uuids = container_roles.inject(Hash.new { |h,k| h[k] = [] }) do |m,(k,v)|
        m[v] << k
        m
      end

      {:order => {}.tap do |p|
        p[:study_uuid] = study_uuid 
        p[:pipeline] = 'Samples'
        p[:cost_code] = cost_code 
        p[:sources] = roles_to_container_uuids
      end
      }
    end

    # @param [Hash] order_parameters
    def post_order(order_parameters)
      post(url_for(:orders, :create), order_parameters)
    end
  end
end
