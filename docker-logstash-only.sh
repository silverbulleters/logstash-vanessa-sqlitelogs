echo "$1"

docker run --rm -v "$1":/srv -p 5044:5044 --link es-logs:elasticsearch \
    logstash:5.0 bash -c 'logstash-plugin install /srv/logstash-input-sqliteonec-0.1.4.gem; logstash -f /srv/testdata/logstash-one.conf'

docker run --rm -v "$1":/srv -p 5045:5044 --link es-logs:elasticsearch \
    logstash:5.0 bash -c 'logstash-plugin install /srv/logstash-input-sqliteonec-0.1.4.gem; logstash -f /srv/testdata/logstash-two.conf'
  
