require 'cucumber'
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/sqliteonec"
require "logstash/codecs/plain"

Given(/^Plugin is loaded$/) do                                                        
  @plugin_class =  LogStash::Inputs::SqliteOnec
  @config = {}
end                                                                                   
                                                                                      
Given(/^setting "([^"]*)" set to "([^"]*)" in config$/) do |setname, setvalue|               
  @config.merge!({setname => setvalue})
end                                                                                   

Given(/^i register plugin with settings$/) do
  p @config
  @plugin = @plugin_class.new(@config)
end

When(/^start queue in logstash$/) do                                                  
  pending # Write code here that turns the phrase above into concrete actions         
end                                                                                   
                                                                                      
When(/^i read row from logs$/) do                                                     
  pending # Write code here that turns the phrase above into concrete actions         
end                                                                                                                                                       
                                                                                      
Then(/^in queue there is (\d+) event$/) do |arg1|                                     
  pending # Write code here that turns the phrase above into concrete actions         
end                                                                                   
                                                                                      
Then(/^i stop queue$/) do                                                             
  pending # Write code here that turns the phrase above into concrete actions         
end                                                                                   
                                                                                       
Then(/^collumn "([^"]*)" transform to type "([^"]*)" with "([^"]*)"$/) do |arg1, arg2, arg3|                               
  pending # Write code here that turns the phrase above into concrete actions                                              
end                                                                                                                        
                