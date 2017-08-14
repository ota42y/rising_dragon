[![Build Status](https://travis-ci.org/ota42y/rising_dragon.svg?branch=master)](https://travis-ci.org/ota42y/rising_dragon)
[![Dependency Status](https://gemnasium.com/badges/github.com/ota42y/rising_dragon.svg)](https://gemnasium.com/github.com/ota42y/rising_dragon)
[![Code Climate](https://codeclimate.com/github/ota42y/rising_dragon/badges/gpa.svg)](https://codeclimate.com/github/ota42y/rising_dragon)

# RisingDragon

Use AWS SQS/SNS as event worker for Microservices. 

([Shoryuken](https://github.com/phstc/shoryuken) wrapper)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rising_dragon', '>= 0.3.3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rising_dragon
    
## Publisher Usage
```ruby
require 'aws-sdk'
require 'rising_dragon'

sns_client = Aws::SNS::Client.new(
    access_key_id: Settings.aws.access_key_id,
    secret_access_key: Settings.aws.secret_access_key,
    region: Settings.aws.region,
)

publisher = ::RisingDragon::SNS::Publisher.new(sns_client)

data = { id: 1, name: "first last" }
publisher.publish("SNSTopicName", "EventType", data)
```

## Worker Usage

execute `bundle exec shoryuken -r steps_worker.rb`

### setting file
```ruby
# steps_worker.rb
require 'aws-sdk'
require 'rising_dragon'

RisingDragon.sqs_client = Aws::SQS::Client.new(
  secret_access_key: Settings.aws.secret_access_key,
  access_key_id:     Settings.aws.access_key_id,
  region:            Settings.aws.steps_sqs.region
)

class StepsEventHandler < ::RisingDragon::SQS::Handler
  def handle(event)
    puts event.type
    puts event.data
    puts event.id
    puts event.timestamp
  end
end

class SQSWorker
  include RisingDragon::SQS::Worker

  rising_dragon_options "SQSQueueName"
  
  rising_dragon_register "StepsEvent", StepsEventHandler
  rising_dragon_ignore "IgnoreEvent"
end
```

### event structure
```ruby
{
    Message: {
        type: "StepsEvent",
        data: {
            # write youre event data
            "id": 42,
            "datetime": DateTime.new(2016, 04, 01, 16, 00, 00, "+09:00")
        },
        id: SecureRandom.uuid,
        timestamp: (Time.now.to_f * 1000).to_i
    }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ota42y/rising_dragon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

