FROM postgres:14

WORKDIR /

COPY database/database_creation.sql /docker-entrypoint-initdb.d/

EXPOSE 5432