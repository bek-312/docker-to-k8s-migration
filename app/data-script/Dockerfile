FROM alpine:3.20

# we only need mysql-client (bash not required if your script uses /usr/bin/env sh)
RUN apk update && apk add --no-cache mysql-client

WORKDIR /opt
COPY mydatabase.sql import.sh /opt/

# normalize line endings (in case of CRLF) and ensure executable
RUN sed -i 's/\r$//' /opt/import.sh && chmod +x /opt/import.sh

# run via sh to avoid exec format issues even if shebang is missing/wrong
CMD ["/bin/sh", "-c", "/opt/import.sh"]