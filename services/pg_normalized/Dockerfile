FROM postgis/postgis:13-3.3
WORKDIR /tmp/db
RUN mkdir /data && chown postgres /data
COPY schema.sql /docker-entrypoint-initdb.d/01.sql
