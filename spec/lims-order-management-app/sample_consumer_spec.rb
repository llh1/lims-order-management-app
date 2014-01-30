require 'lims-order-management-app/spec_helper'
require 'lims-order-management-app/sample_consumer'

module Lims::OrderManagementApp
  describe SampleConsumer do
    before do
      Lims::OrderManagementApp::OrderCreator.any_instance.stub(:initialize_api)
    end

    let(:consumer) { described_class.new({}, {}, {}, {}) }

    context "draft samples" do
      let(:samples) do 
        [
          {:sample => Lims::ManagementApp::Sample.new},
          {:sample => Lims::ManagementApp::Sample.new}
        ]
      end

      it "raises an exception if no samples in a published state" do
        expect do
          consumer.send(:before_filter!, samples)
        end.to raise_error(SampleConsumer::NoSamplePublished)
      end
    end

    context "1 published sample" do
      let(:samples) do
        [
          {:sample => Lims::ManagementApp::Sample.new(:state => "published")},
          {:sample => Lims::ManagementApp::Sample.new}
        ]
      end

      let!(:before_filter!) { consumer.send(:before_filter!, samples) }

      it "keeps only the published sample" do
        samples.size.should == 1
        samples.first.should be_a(Hash)
        samples.first[:sample].should be_a(Lims::ManagementApp::Sample)
      end
    end
  end
end
