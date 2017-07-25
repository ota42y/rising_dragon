require "spec_helper"
require "securerandom"

describe RisingDragon::SQS::Worker do
  let(:ignore_event) { "IgnoreEvent" }

  let(:id) { SecureRandom.uuid }
  let(:timestamp) { (Time.now.to_f * 1000).to_i }
  let(:test_class_handler) do
    d = instance_double("HandleTestClass")
    allow(HandleTestClass).to receive(:new).and_return(d)
    allow(d).to receive(:handle)
    d
  end

  # test class....
  class RescueClass
    def call(_e)
    end
  end

  class HandleTestClass < ::RisingDragon::SQS::Handler
    def handle(_event)
    end
  end

  class NotOverwriteHandle < ::RisingDragon::SQS::Handler
  end

  class TestSQSWorker
    include RisingDragon::SQS::Worker

    rising_dragon_options "SQSQueueName"

    rising_dragon_register "StepEvent", HandleTestClass
    rising_dragon_register "NotOverwriteEvent", NotOverwriteHandle
    rising_dragon_ignore "IgnoreEvent"

    def rescue_from(e)
      RescueClass.new.call(e)
    end
  end

  it do
    body_hash = {
      "Message" => {
        type: "StepEvent",
        data: {
          "id": 42,
          "datetime": DateTime.new(2016, 0o4, 0o1, 16, 0o0, 0o0, "+09:00"),
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    TestSQSWorker.new.perform("msg", body_hash)

    expect(test_class_handler).to have_received(:handle) do |event|
      expect(event.id).to eq id
      expect(event.timestamp).to eq Time.at(timestamp / 1000.0)
      expect(event.type).to eq "StepEvent"
      expect(event.data["id"]).to eq 42
      expect(event.data["datetime"]).to eq DateTime.new(2016, 0o4, 0o1, 16, 0o0, 0o0, "+09:00").to_s
    end
  end

  it "IgnoreEvent" do
    body_hash = {
      "Message" => {
        type: ignore_event,
        data: {
          "event": "event",
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    TestSQSWorker.new.perform("msg", body_hash)

    expect(test_class_handler).not_to have_received(:handle)
  end

  it "UnKnownEvent" do
    body_hash = {
      "Message" => {
        type: "UnKnownEvent",
        data: {
          "event": "event",
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    TestSQSWorker.new.perform("msg", body_hash)

    expect(test_class_handler).not_to have_received(:handle)
  end

  it "NotOverwriteEvent" do
    body_hash = {
      "Message" => {
        type: "NotOverwriteEvent",
        data: {
          "event": "event",
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    d = instance_double("RescueClass")
    allow(RescueClass).to receive(:new).and_return(d)
    allow(d).to receive(:call)

    TestSQSWorker.new.perform("msg", body_hash)

    expect(d).to have_received(:call).once
  end
end
