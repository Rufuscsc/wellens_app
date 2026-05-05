#!/bin/bash

# Initialize bench if not exists
if [ ! -d "apps" ]; then
    echo "Initializing bench..."
    bench init --skip-redis-config-check --skip-assets --python python3 .
fi

# Set database and redis config
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis-cache:6379
bench set-config -g redis_queue redis://redis-queue:6379
bench set-config -g redis_socketio redis://redis-queue:6379

# Link the current workspace as wellens_app
if [ ! -d "apps/wellens_app" ]; then
    echo "Linking wellens_app..."
    bench get-app wellens_app /workspace
fi

# Start MariaDB check
echo "Waiting for MariaDB..."
until mysqladmin ping -h"mariadb" -u"root" -p"admin" --silent; do
    sleep 2
done

# Create a new site if not exists
if [ ! -d "sites/wellens.localhost" ]; then
    echo "Creating site wellens.localhost..."
    bench new-site wellens.localhost --admin-password admin --db-root-password admin --install-app erpnext --set-default
    bench --site wellens.localhost install-app wellens_app
fi

echo "Setup complete! You can now run 'bench start' to begin development."
