docker pull dpage/pgadmin4
docker run -p 8081:80 \
    -e 'PGADMIN_DEFAULT_EMAIL=localuser@local.com' \
    -e 'PGADMIN_DEFAULT_PASSWORD=localuser' \
    -d dpage/pgadmin4

echo "localuser@local.com:localuser | localhost:8081"

