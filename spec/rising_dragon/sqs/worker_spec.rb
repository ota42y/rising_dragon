require 'spec_helper'

describe RisingDragon::SQS::Worker do
  let(:ignore_event) { 'IgnoreEvent' }

  let(:id) { SecureRandom.uuid }
  let(:timestamp) { (Time.now.to_f * 1000).to_i }
  let(:test_class_handler) do
    d = instance_double('HandleTestClass')
    allow(HandleTestClass).to receive(:new).and_return(d)
    allow(d).to receive(:handle)
    d
  end

  let(:sqs_client_mock) { instance_double('Aws::SQS::Client') }
  let(:queue_mock) do
    d = instance_double('Shoryuken::Queue')
    allow(d).to receive(:url).and_return(queue_url)
    allow(d).to receive(:name).and_return(queue_name)
    d
  end
  let(:queue_url) { 'aws_queue_url' }
  let(:queue_name) { 'aws_queue_name' }

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

    rising_dragon_options 'SQSQueueName'

    rising_dragon_register 'StepEvent', HandleTestClass
    rising_dragon_register 'NotOverwriteEvent', NotOverwriteHandle
    rising_dragon_ignore 'IgnoreEvent'

    def rescue_from(e)
      RescueClass.new.call(e)
    end
  end

  it do
    body_hash = {
      'Message' => {
        type: 'StepEvent',
        data: {
          "id": 42,
          "datetime": '2016-04-01T16:00:00+09:00',
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    message_data = {
      message_id: :message_id,
      receipt_handle: :receipt_handle,
      md5_of_body: :md5_of_body,
      body: body_hash.to_json,
      attributes: :attributes,
      md5_of_message_attributes: :md5_of_message_attributes,
      message_attributes: :message_attributes
    }

    message = ::Aws::SQS::Types::Message.new(message_data)
    sqs_message = ::Shoryuken::Message.new(sqs_client_mock, queue_mock, message)

    test_class_handler

    TestSQSWorker.new.perform(sqs_message, body_hash)

    expect(test_class_handler).to have_received(:handle) do |event|
      expect(event.id).to eq id
      expect(event.timestamp).to eq Time.at(timestamp / 1000.0)
      expect(event.type).to eq 'StepEvent'
      expect(event.data['id']).to eq 42
      expect(event.data['datetime']).to eq '2016-04-01T16:00:00+09:00'

      allow(sqs_client_mock).to receive(:delete_message).with(queue_url: queue_url, receipt_handle: :receipt_handle)
      event.delete!
      expect(sqs_client_mock).to have_received(:delete_message).with(queue_url: queue_url, receipt_handle: :receipt_handle).once
    end
  end

  it 'IgnoreEvent' do
    body_hash = {
      'Message' => {
        type: ignore_event,
        data: {
          "event": 'event',
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    TestSQSWorker.new.perform('msg', body_hash)

    expect(test_class_handler).not_to have_received(:handle)
  end

  it 'UnKnownEvent' do
    body_hash = {
      'Message' => {
        type: 'UnKnownEvent',
        data: {
          "event": 'event',
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    TestSQSWorker.new.perform('msg', body_hash)

    expect(test_class_handler).not_to have_received(:handle)
  end

  it 'NotOverwriteEvent' do
    body_hash = {
      'Message' => {
        type: 'NotOverwriteEvent',
        data: {
          "event": 'event',
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    d = instance_double('RescueClass')
    allow(RescueClass).to receive(:new).and_return(d)
    allow(d).to receive(:call)

    TestSQSWorker.new.perform('msg', body_hash)

    expect(d).to have_received(:call).once
  end

  it 'UnRegisterEvent' do
    body_hash = {
      'Message' => {
        type: 'UnRegisterEvent',
        data: {
          "event": 'event',
        },
        id: id,
        timestamp: timestamp,
      }.to_json,
    }

    test_class_handler

    d = instance_double('RescueClass')
    allow(RescueClass).to receive(:new).and_return(d)
    allow(d).to receive(:call)

    TestSQSWorker.new.perform('msg', body_hash)

    expect(d).to have_received(:call).once
  end
end
