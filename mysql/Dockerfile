FROM ubuntu:18.04

ENV MYSQL_DATA_DIR=/var/lib/mysql
ENV MYSQL_RUN_DIR=/run/mysqld
ENV MYSQL_LOG_DIR=/var/log/mysql

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y mysql-server
RUN rm -rf ${MYSQL_DATA_DIR}
RUN rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 3306/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/mysqld_safe"]
