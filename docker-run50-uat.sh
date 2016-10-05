docker stop es-logs
docker rm es-logs

docker stop kibana-logs
docker rm kibana-logs

docker stop logstash-to-es-one
docker rm logstash-to-es-one

docker stop logstash-to-es-two
docker rm logstash-to-es-two

docker run --restart=always --name es-logs -d -e ES_JAVA_OPTS="-Xms2g -Xmx2g" \
   -p 9200:9200 -p 9300:9300 -v /srv/esdata50:/usr/share/elasticsearch/data elasticsearch:5.0

docker run --restart=always --name kibana-logs --link es-logs:elasticsearch -p 5601:5601 -d kibana:5.0

docker run -d --restart=always --name logstash-to-es-one -v `pwd`/testdata:/conf -p 5044:5044 \
    logstash:5.0 logstash -f /conf/logstash-one.conf

docker run -d --restart=always --name logstash-to-es-two -v `pwd`/testdata:/conf -p 5045:5044 \
    logstash:5.0 logstash -f /conf/logstash-two.conf

#docker run -d --restart=always --name graphana-logs -p 3000:3000 \
#    -v /srv/grafana:/var/lib/grafana --link es-logs:elasticsearch \
#    -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
#    grafana/grafana:develop
