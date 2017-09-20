FROM docker.elastic.co/beats/filebeat:5.4.1

COPY docker-entrypoint.sh /usr/local/bin/
#RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]