#!/bin/bash

set -e

if [ "$DEBUG" == "True" ]; then
	# check if the postgres service is up before starting django migration
    until export MYSQL_PASSWORD=$DATABASE_PASSWORD; mysql -h "$HOST" -u"$DATABASE_USER" -p"$DATABASE_PASSWORD" -e '\s; show databases'; do
      >&2 echo "Mysql is unavailable - sleeping"
      sleep 5
    done

    >&2 echo "Mysql is up - executing command"
fi

yes | python manage.py migrate

# Forward app logs to docker log collector
tail -n0 -F /var/logs/app_logs/*.log &

# start uwsgi
exec uwsgi --emperor dockerify/uwsgi/ --gid www-data

