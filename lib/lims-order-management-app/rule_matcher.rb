module Lims::OrderManagementApp
  module RuleMatcher
   
    NoMatchingRule = Class.new(StandardError)
    SampleExtractionProcessField = "cellular_material.extraction_process"

    def initialize_rules(rule_settings)
      @ruleset = rule_settings["rules"]
    end

    # @param [Lims::ManagementApp::Sample] sample
    # @return [Hash]
    # @example returned value: {"11111111-2222-3333-4444-555555555555" => "samples.extraction.manual_dna_and_rna.input_tube_nap"}
    # @raise [NoMatchingRule]
    def matching_rule(sample)
      item_roles = {}
      @ruleset.each do |ruleset_items|
        ruleset_items.each do |rules|
          role = rules.keys.first
          rule_items = rules.values[0]
          rule_extraction_process = rule_items[SampleExtractionProcessField]

          # For all the other rules than extraction process (if any)
          valid = rule_items.reject { |r,_| r == SampleExtractionProcessField }.all? do |rule_key, rule_value|
            sample_value = rule_key.split('.').inject(sample) do |sample, field|
              sample && sample[field.to_sym]
            end
          end
          next unless valid

          # Extraction process rule 
          sample[:cellular_material][:extraction_process].each do |sample_extraction_process, container_uuids|
            if sample_extraction_process == rule_extraction_process 
              container_uuids.each do |container_uuid|
                item_roles[container_uuid] = role
              end
            end
          end
        end
      end

      raise NoMatchingRule if item_roles.empty?
      item_roles
    end
  end
end
