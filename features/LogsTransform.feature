Feature: Implements Logstash Event Types
    In order to research metrix
    As a devops engineer
    I want to see in index types what i may analyse, and it does not string

Background:
    Given Plugin is loaded 
    And setting "servinfo" set to "testdata/servinfo" in config
    And setting "guid" set to "likeguid" in config
    And setting "basename" set to "MyVanessaERP" in config
    And setting "path_since" set to "MyVanessaERPLogstash" in config
    And i register plugin with settings

Scenario Outline: Types transform
    When start queue in logstash
    And i read row from logs
    Then collumn "<ColumnName>" transform to type "<EventCollumnType>" with "<Analyzed>"
    And in queue there is 1 event 
    And i stop queue

Examples:
    | ColumnName | EventCollumnType | Analyzed | 
    | curetimestamp | LogStash::Timestamp | true |
    | transactionStatus | LogStash::String | true |
