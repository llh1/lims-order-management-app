require 'rest_client'
require 'json'

module Lims::OrderManagementApp
  module Helpers
    module API

      HEADERS = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}

      module Request
        def get(url)
          response = RestClient.get(url, HEADERS.merge(extra_headers))
          JSON.parse(response)
        end

        def post(url, parameters)
          response = RestClient.post(url, parameters.to_json, HEADERS.merge(extra_headers))
          JSON.parse(response)
        end
      end
      include Request

      def self.included(klass)
        klass.class_eval do
          attribute :root, String, :required => true, :writer => :private, :reader => :private
          attribute :extra_headers, Hash, :required => true, :writer => :private, :default => {}
        end
      end

      # According to RestClient documentation, it is necessary 
      # to set multipart to true when sending custom headers.
      def initialize_api(root_url, user_email)
        @extra_headers = {"user-email" => user_email, "multipart" => true}
        @root = get(root_url)
      end

      def url_for(model, action)
        @root[model.to_s]["actions"][action.to_s]
      end
    end
  end
end
