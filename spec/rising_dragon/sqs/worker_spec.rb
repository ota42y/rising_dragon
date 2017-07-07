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

  RisingDragon.add_group("default_group", 25)

  class HandleTestClass < ::RisingDragon::SQS::Handler
    def handle(_event)
    end
  end

  class TestSQSWorker
    include RisingDragon::SQS::Worker

    rising_dragon_options "SQSQueueName", 1, "default_group", auto_delete: true

    rising_dragon_register "StepEvent", HandleTestClass
    rising_dragon_ignore "IgnoreEvent"
  end

  it do
    body_hash = {
      Message: {
        type: "StepEvent",
        data: {
          "id": 42,
          "datetime": DateTime.new(2016, 0o4, 0o1, 16, 0o0, 0o0, "+09:00"),
        },
        id: id,
        timestamp: timestamp,
      },
    }

    test_class_handler

    TestSQSWorker.new.perform("msg", body_hash.to_json)

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
      Message: {
        type: ignore_event,
        data: {
          "event": "event",
        },
        id: id,
        timestamp: timestamp,
      },
    }

    test_class_handler

    TestSQSWorker.new.perform("msg", body_hash.to_json)

    expect(test_class_handler).not_to have_received(:handle)
  end

  it "UnKnownEvent" do
    body_hash = {
      Message: {
        type: "UnKnownEvent",
        data: {
          "event": "event",
        },
        id: id,
        timestamp: timestamp,
      },
    }

    test_class_handler

    TestSQSWorker.new.perform("msg", body_hash.to_json)

    expect(test_class_handler).not_to have_received(:handle)
  end
end
