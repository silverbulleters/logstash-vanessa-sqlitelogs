require 'cucumber'
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/sqliteonec"
require "logstash/codecs/plain"

require "timecop"

Given(/^Plugin is loaded$/) do                                                        
  @plugin_class =  LogStash::Inputs::SqliteOnec
  @config = {}
end                 

Given(/^i delete the database "([^"]*)"$/) do |arg1| 
  path_to_file = File.expand_path('./' + arg1)
  begin
    File.delete(path_to_file) if File.exist?(path_to_file)
  rescue
    #todo fix ther ERR.ACESS 
  end

end                                                                                         
                                                                                      
Given(/^setting "([^"]*)" set to "([^"]*)" in config$/) do |setname, setvalue|               
  @config.merge!({setname => setvalue})
end                                                                                   

Given(/^setting "([^"]*)" set to "([^"]*)" in config beside current dir$/) do |setname, setvalue|
  @config.merge!({setname => File.expand_path('../../../' + setvalue, __FILE__)})
end

Given(/^i register plugin with settings$/) do
  @plugin = @plugin_class.new(@config)
  @plugin.register
end

When(/^start queue in logstash$/) do
  @queue = Queue.new  
end                                                                                   
                                                                                      
When(/^i read row from logs$/) do
   @runner = Thread.new do
      @plugin.run(@queue)
   end                                                     
   sleep 1
   for i in 0..1
       sleep 1
   end
end                                                                                                                                                       
                                                                                      
Then(/^in queue there is (\d+) event$/) do |arg1|                                     
  @event = @queue.pop     
end                                                                                   
                                                                                      
Then(/^i stop queue$/) do                                                             
  @plugin.stop
  @runner.exit
  Thread.kill(@runner)
end                                                                                   
                                                                                       
Then(/^collumn "([^"]*)" transform to type "([^"]*)" with "([^"]*)"$/) do |colname, coltype, isanalyzed|
  p @event.get(colname).to_s
  clazz = Object.const_get(coltype)
  expect(@event.get(colname)).to be_a(clazz)                                         
end                                                                                                                        
                