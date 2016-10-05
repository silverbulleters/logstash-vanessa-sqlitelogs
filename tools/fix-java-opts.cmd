echo "Logsstash and Java on Windows doen not correct set the URI of log4j props files"
echo "you need to fix that with change your path of jruby"

set JAVA_OPTS=-Dlog4j.configurationFile=file:///C:/jruby/lib/ruby/gems/shared/gems/logstash-devutils-1.1.0-java/lib/logstash/devutils/rspec/log4j2.properties
