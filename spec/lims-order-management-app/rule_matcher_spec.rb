require 'lims-order-management-app/spec_helper'
require 'lims-order-management-app/rule_matcher'
require 'lims-management-app/sample/sample'

module Lims::OrderManagementApp
  describe RuleMatcher do
    let(:matcher) {
      Class.new { include RuleMatcher }.new.tap do |rule_matcher|
        rule_matcher.initialize_rules(ruleset)
      end
    }

    let(:ruleset) {
      { "rules" =>
        [
          [{"samples.extraction.manual_dna_and_rna.input_tube_nap"=>
            {"cellular_material.extraction_process"=>"DNA & RNA Manual"}
          }],
          [{"samples.extraction.qiacube_dna_and_rna.input_tube_nap"=>
            {"cellular_material.extraction_process"=>"DNA & RNA QIAcube"}
          }],
          [{"samples.extraction.manual_dna_and_rna.input_tube_nap2"=>
           {"cellular_material.extraction_process"=>"DNA & RNA Manual 2", "cellular_material.lysed"=>true},
          }],
          [{"samples.extraction.qiacube_dna_and_rna.input_tube_nap"=>
             {"cellular_material.extraction_process"=>"RNA QIAcube"}
          }]
        ]
      }
    }

    context "rule matched" do
      shared_examples_for "matching a rule" do |sample_data, role|
        it "returns the role #{role} for the sample parameter #{sample_data.inspect}" do
          matcher.matching_rule(sample_data).should == role
        end
      end

      it_behaves_like "matching a rule", 
        {:cellular_material => {:extraction_process => {"DNA & RNA Manual" => ["11111111-2222-3333-4444-555555555555"]}}}, 
        {"11111111-2222-3333-4444-555555555555" => "samples.extraction.manual_dna_and_rna.input_tube_nap"}

      it_behaves_like "matching a rule", 
        {:cellular_material => {:extraction_process => {"DNA & RNA Manual 2" => ["11111111-2222-3333-4444-666666666666"]}, :lysed => true}}, 
        {"11111111-2222-3333-4444-666666666666" => "samples.extraction.manual_dna_and_rna.input_tube_nap2"}

      it_behaves_like "matching a rule", 
        {:cellular_material => {:extraction_process => {"DNA & RNA Manual" => ["11111111-2222-3333-4444-555555555555","11111111-2222-3333-4444-666666666666"], "DNA & RNA QIAcube" => ["11111111-2222-3333-4444-777777777777"]}}}, 
        {
          "11111111-2222-3333-4444-555555555555" => "samples.extraction.manual_dna_and_rna.input_tube_nap", 
          "11111111-2222-3333-4444-666666666666" => "samples.extraction.manual_dna_and_rna.input_tube_nap",
          "11111111-2222-3333-4444-777777777777" => "samples.extraction.qiacube_dna_and_rna.input_tube_nap"
        }
    end

    context "no rule matched" do
      let(:sample) { Lims::ManagementApp::Sample.new({ 
        :sample_type => "RNA",
        :cellular_material  => {:lysed => false, :extraction_process => {"DNA & RNA Extraction" => ["11111111-2222-3333-4444-555555555555"]}}
      })}

      it "raises an exception" do
        expect do
          matcher.matching_rule(sample)
        end.to raise_error(RuleMatcher::NoMatchingRule)
      end
    end
  end
end
