require "json"
require "securerandom"

require "shoryuken"

require "rising_dragon/version"
require "rising_dragon/event"
require "rising_dragon/error"
require "rising_dragon/sns/publisher"
require "rising_dragon/sqs/emitter"
require "rising_dragon/sqs/handler"
require "rising_dragon/sqs/worker"

module RisingDragon
  extend SingleForwardable
  def_delegators(:Shoryuken, :sqs_client, :sqs_client=)
end
