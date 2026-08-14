FROM alpine:3.21

RUN apk add --no-cache inotify-tools curl

COPY watch.sh /usr/local/bin/watch.sh
RUN chmod +x /usr/local/bin/watch.sh

CMD ["/usr/local/bin/watch.sh"]
