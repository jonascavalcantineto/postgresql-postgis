#!/bin/bash

chmod 775 /var/lib/postgresql/
chown postgres /var/lib/postgresql/ -R

if [ ! -f /var/lib/postgresql/data/postgresql.conf ]
then
    su - postgres -c "/usr/lib/postgresql/${PGSQL_VERSION}/bin/initdb -E UTF-8 -D /var/lib/postgresql/data/"
fi

sleep 3

su - postgres -c "/usr/lib/postgresql/${PGSQL_VERSION}/bin/pg_ctl -l /var/log/postgresql/server.log -D /var/lib/postgresql/data/ start"
if [ $? == 0 ]
then
    sleep 5
    createdb -U postgres -E UTF8 template_postgis
    
    #-- Enable PostGIS (includes raster)
    #psql -U postgres -d postgres -c "CREATE EXTENSION postgis;"
    if [ $? == 0 ]
    then
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/postgis.sql
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/spatial_ref_sys.sql
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/postgis_comments.sql
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/rtpostgis.sql
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/raster_comments.sql
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/topology.sql
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/topology_comments.sql
        psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/contrib/postgis-${POSTGIS_SQL_VERSION}/legacy.sql
    #     #-- Enable Topology
    #     psql -U postgres -d postgres -c "CREATE EXTENSION postgis_topology;"
    #     #-- Enable Template
    #     createdb  -h localhost -U postgres -E UTF8 template_postgis 

    #     psql -U postgres -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis'" \
    #     psql -U postgres -d template_postgis -f /usr/share/postgresql/${PGSQL_VERSION}/extension/postgis--${POSTGIS_SQL_VERSION}.sql
    #     psql -U postgres -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;" 
    #     psql -U postgres -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
    #     psql -U postgres -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
    else
        echo "[WARNING] - DATAs EXIST"
    fi

else
    echo "[ERROR] - Start PostgreSQL!!!"
fi