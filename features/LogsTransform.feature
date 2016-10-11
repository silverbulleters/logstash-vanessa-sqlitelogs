Feature: Implements Logstash Event Types
    In order to research metrix
    As a devops engineer
    I want to see in index types what i may analyse, and it does not string

Background:
    Given Plugin is loaded
    And i delete the database "MyVanessaERPLogstash"
    And setting "onec_server_reg_path" set to "testdata/servinfo" in config beside current dir
    And setting "onec_base_guid" set to "likeguid" in config
    And setting "onec_base_name" set to "MyVanessaERP" in config
    And setting "path_since" set to "MyVanessaERPLogstash" in config
    And i register plugin with settings

Scenario Outline: Types transform
    When start queue in logstash
    And i read row from logs
    And in queue there is 1 event
    And i stop queue
    Then collumn "<ColumnName>" transform to type "<EventCollumnType>" with "<Analyzed>"
    
Examples:
    | ColumnName | EventCollumnType | Analyzed | 
    | curetimestamp | LogStash::Timestamp | true |
    | transactionStatus | LogStash::String | true |
