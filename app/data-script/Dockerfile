FROM alpine

RUN apk update && apk add --no-cache mysql-client bash

WORKDIR /opt

COPY mydatabase.sql import.sh /opt/

RUN chmod +x /opt/import.sh

CMD ["/opt/import.sh"]