FROM  postgres:9.5
LABEL MAINTAINER="Jonas Cavalcanti <jonascavalcantineto@gmail.com> | Allan Almeida <allan.almeida@etice.ce.gov.br>"
LABEL  app_type="bd"
LABEL  app_state="prod_int"

RUN    apt-get update 
RUN    apt-get install -y \
            	vim \
            	telnet \
            	wget \
				supervisor \
				postgresql-contrib
RUN set -ex \ 
		&& sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen \
    	&& locale-gen

ENV LANG="pt_BR.UTF-8"
ENV PGSQL_VERSION="9.5"
ENV POSTGIS_VERSION="3"
ENV POSTGIS_SQL_VERSION="3.0"

RUN set -ex \
	&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
	&& sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'

RUN    apt-get update 
RUN    apt-get install -y \
           	postgresql-${PGSQL_VERSION}-postgis-${POSTGIS_VERSION} \
           	postgresql-${PGSQL_VERSION}-postgis-${POSTGIS_VERSION}-scripts
            	
# RUN set -ex \
# 	&& sed -i "/echo/d" /usr/share/postgresql/${PGSQL_VERSION}/extension/postgis--${POSTGIS_SQL_VERSION}.sql


ADD confs/supervisord.conf /etc/supervisord.conf

ADD confs/start-postgresql.sh /start-postgresql.sh
RUN chmod +x /start-postgresql.sh

ADD confs/start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /var/lib/postgresql/data

CMD ["/start.sh"]
	
