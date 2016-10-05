# LogStash Input Plugin for 1C Application Logs

[![Build Status](https://travis-ci.org/silverbulleters-research/logstash-vanessa-sqlitelogs.svg?branch=master)](https://travis-ci.org/silverbulleters-research/logstash-vanessa-sqlitelogs)

* use the new sqlite format of Application Logs

## Standart Input

```
input {

    sqliteonec {
		type => "1CLog"
		path_since => "IncrementalInputTable" # table name to create last read records
		onec_base_name => "MyVanessaERP" # human readable base name
		onec_base_guid => "9c1205e0-595b-4edd-9f70-6dda09b6f888" # guid of database (get from the 1CV8Clst.lst file)
		onec_server_reg_path => "C:\srvinfo\reg_1541" # cluster server files path
    }

}
```

## Contribute

* intall JDK
* install jruby
* write tests
* read [this doc](https://www.elastic.co/guide/en/logstash/5.0/_how_to_write_a_logstash_input_plugin.html#_how_to_write_a_logstash_input_plugin)
* pull-request you needs ;-)

## Why in English and not in Russia

* let it be 1C World !!!
