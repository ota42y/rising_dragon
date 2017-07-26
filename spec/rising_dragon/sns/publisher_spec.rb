require "spec_helper"

describe RisingDragon::SNS::Publisher do
  let(:stub_sns_client) { double }
  let(:publisher) { ::RisingDragon::SNS::Publisher.new(stub_sns_client) }

  context "correct" do
    let(:topic_name) { "UserManager" }
    let(:event_type) { "UpdateUserData" }
    let(:data) { { id: 1, name: "first last" } }
    let(:stub_arn) { double }
    let(:stub_topic) do
      stub_topic = double
      allow(stub_topic).to receive(:topic_arn).and_return(stub_arn)
      stub_topic
    end

    before do
      allow(stub_sns_client).to receive(:create_topic).with(name: topic_name).and_return(stub_topic)
    end

    it do
      allow(stub_sns_client).to receive(:publish) do |arg|
        expect(arg[:topic_arn]).to eq(stub_arn)

        json = JSON.parse(arg[:message])
        expect(json["id"].is_a?(String)).to eq true
        expect(json["timestamp"].is_a?(Integer)).to eq true
        expect(json["type"]).to eq event_type
        expect(json["data"]["id"]).to eq data[:id]
        expect(json["data"]["name"]).to eq data[:name]
      end

      publisher.send_event!(topic_name, event_type, data)
    end

    it "use cache" do
      allow(stub_sns_client).to receive(:publish)

      publisher.send_event!(topic_name, event_type, data)
      publisher.send_event!(topic_name, event_type, data)

      expect(stub_sns_client).to have_received(:publish).twice
      expect(stub_sns_client).to have_received(:create_topic).once
    end

    it "not use cache" do
      allow(stub_sns_client).to receive(:publish)

      publisher.use_cache = false
      publisher.send_event!(topic_name, event_type, data)
      publisher.send_event!(topic_name, event_type, data)

      expect(stub_sns_client).to have_received(:publish).twice
      expect(stub_sns_client).to have_received(:create_topic).twice
    end
  end
end
