# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/sqliteonec"
require "logstash/codecs/plain"

describe LogStash::Inputs::SqliteOnec do

  let(:config) { 
      {
        "path_since" => "TimeStamperDB",
        "onec_base_name" => "My Super 1C Base",
        "onec_base_guid" => "likeguid",
        "onec_server_reg_path" => File.expand_path('../../../servinfo', __FILE__)
      } 
  }

  let(:plugin) { LogStash::Inputs::SqliteOnec.new(config) }
  let(:queue) { Queue.new }

  before :each do
  end

  after :each do
  end

  context "when registering and tearing down" do
    it "should register without raising exception" do
      expect { plugin.register }.to_not raise_error
      plugin.stop
    end
  end

  context "then run - there is a timestamp on event" do
    it "should convert it to LogStash::Timestamp " do
      plugin.register
      # TODO - add the run check
    end
  end

end
