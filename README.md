# RisingDragon

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rising_dragon`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rising_dragon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rising_dragon

## Usage

```ruby
require 'rising_dragon'
require 'securerandom'

class StepEventHandler < ::RisingDragon::SQS::Handler
  def handle(event)
    puts event.type
    puts event.data
    puts event.id
    puts event.timestamp
  end
end

class SQSWorker
  include RisingDragon::SQS::Worker

  rising_dragon_options queue: "test", auto_delete: true

  def self.register_handlers(emitter)
    emitter.register "StepEvent", StepEventHandler
    emitter.ignore "RequlEvent"
  end
end

body_hash = {
    Message: {
        type: "StepEvent",
        data: {
            "id": 42,
            "datetime": DateTime.new(2016, 04, 01, 16, 00, 00, "+09:00")
        },
        id: SecureRandom.uuid,
        timestamp: (Time.now.to_f * 1000).to_i
    }
}

SQSWorker.new.perform("msg", body_hash.to_json)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ota42y/rising_dragon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

