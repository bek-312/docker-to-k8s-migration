#!/usr/bin/env sh

# Wait until database is fully up
sleep 120
mysql -h data -uroot -proot mydatabase < /opt/mydatabase.sql