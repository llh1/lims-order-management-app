require 'lims-order-management-app/spec_helper'
require 'lims-order-management-app/sample_json_decoder'

module Lims::OrderManagementApp
  describe SampleJsonDecoder do
    let(:decoder) { Class.new { include SampleJsonDecoder }.new }

    context "sample decoders" do
      it "gets the right decoder for a sample message" do
        decoder.sample_decoder_for("sample").should == SampleJsonDecoder::SampleDecoder 
      end

      it "gets the right decoder for a bulk create sample message" do
        decoder.sample_decoder_for("bulk_create_sample").should == SampleJsonDecoder::BulkCreateSampleDecoder
      end

      it "gets the right decoder for a bulk update sample message" do
        decoder.sample_decoder_for("bulk_update_sample").should == SampleJsonDecoder::BulkUpdateSampleDecoder
      end

      it "gets the right decoder for a sample collection message" do
        decoder.sample_decoder_for("sample_collection").should == SampleJsonDecoder::SampleCollectionDecoder
      end

      it "raises an exception if for a unknown decoder" do
        expect do
          decoder.sample_decoder_for("dummy")
        end.to raise_error(SampleJsonDecoder::UndefinedDecoder)
      end
    end

    context "sample resources" do
      let(:result) { decoder.sample_resource(payload) }

      context "single sample" do
        let(:payload) { '{"sample":{"actions":{"read":"http://localhost:9292/53dd1d50-b3df-0130-55ac-282066132de2","create":"http://localhost:9292/53dd1d50-b3df-0130-55ac-282066132de2","update":"http://localhost:9292/53dd1d50-b3df-0130-55ac-282066132de2","delete":"http://localhost:9292/53dd1d50-b3df-0130-55ac-282066132de2"},"uuid":"53dd1d50-b3df-0130-55ac-282066132de2","state":"draft","supplier_sample_name":"supplier sample name","gender":"Male","sanger_sample_id":"StudyX-20","sample_type":"Cell Pellet","scientific_name":"homo sapiens","common_name":"man","hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","taxon_id":9606,"volume":100,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":true,"is_re_submitted_sample":false,"dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"rna":{"pre_amplified":true,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"extraction method","concentration":120,"sample_purified":true,"concentration_determined_by_which_method":"method"},"cellular_material":{"lysed":true},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"}},"action":"create","date":"2013-06-10 09:37:44 UTC","user":"user"}'}
        it "gets the right sample for a sample payload" do
          result.should be_a(Array)
          result.first.should be_a(Hash)
          result.size.should == 1
          result.first[:sample].should be_a(Lims::ManagementApp::Sample)
        end
      end

      context "bulk samples" do
        let(:payload) { <<-EOD
        {"bulk_create_sample":{"actions":{},"user":"user","application":"application","result":{"samples":[{"actions":{"read":"http://localhost:9292/2b0272c0-b401-0130-55d7-282066132de2","create":"http://localhost:9292/2b0272c0-b401-0130-55d7-282066132de2","update":"http://localhost:9292/2b0272c0-b401-0130-55d7-282066132de2","delete":"http://localhost:9292/2b0272c0-b401-0130-55d7-282066132de2"},"uuid":"2b0272c0-b401-0130-55d7-282066132de2","state":"draft","supplier_sample_name":"supplier sample name","gender":"Male","sanger_sample_id":"S2-24","sample_type":"RNA","scientific_name":"homo sapiens","common_name":"man","hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","taxon_id":9606,"volume":100,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":true,"is_re_submitted_sample":false,"dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"cellular_material":{"lysed":false},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"}},{"actions":{"read":"http://localhost:9292/2b030b70-b401-0130-55d7-282066132de2","create":"http://localhost:9292/2b030b70-b401-0130-55d7-282066132de2","update":"http://localhost:9292/2b030b70-b401-0130-55d7-282066132de2","delete":"http://localhost:9292/2b030b70-b401-0130-55d7-282066132de2"},"uuid":"2b030b70-b401-0130-55d7-282066132de2","state":"draft","supplier_sample_name":"supplier sample name","gender":"Male","sanger_sample_id":"S2-25","sample_type":"RNA","scientific_name":"homo sapiens","common_name":"man","hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","taxon_id":9606,"volume":100,"date_of_sample_collection":"2013-06-24T00:00:00+01:00","is_sample_a_control":true,"is_re_submitted_sample":false,"dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02T00:00:00+00:00","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"cellular_material":{"lysed":false},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"}}]},"volume":100,"date_of_sample_collection":"2013-06-24","is_sample_a_control":true,"is_re_submitted_sample":false,"hmdmc_number":"123456","ebi_accession_number":"accession number","sample_source":"sample source","mother":"mother","father":"father","sibling":"sibling","gc_content":"gc content","public_name":"public name","cohort":"cohort","storage_conditions":"storage conditions","dna":{"pre_amplified":false,"date_of_sample_extraction":"2013-06-02","extraction_method":"extraction method","concentration":120,"sample_purified":false,"concentration_determined_by_which_method":"method"},"rna":null,"cellular_material":{"lysed":false},"genotyping":{"country_of_origin":"england","geographical_region":"europe","ethnicity":"english"},"common_name":"man","gender":"Male","sample_type":"RNA","taxon_id":9606,"supplier_sample_name":"supplier sample name","scientific_name":"homo sapiens","quantity":2,"state":"draft","sanger_sample_id_core":"S2"},"action":"bulk_create_sample","date":"2013-06-10 13:39:59 UTC","user":"user"}
        EOD
        }
        it "gets the right samples" do
          result.should be_a(Array)
          result.size.should == 2
          result.each do |sample|
            sample.should be_a(Hash)
            sample[:sample].should be_a(Lims::ManagementApp::Sample)
          end
        end
      end
    end
  end
end
