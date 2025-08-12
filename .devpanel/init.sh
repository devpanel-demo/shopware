#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (C) 2021 DevPanel
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation version 3 of the
# License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# For GNU Affero General Public License see <https://www.gnu.org/licenses/>.
# ----------------------------------------------------------------------

# Update .env.local file
CONNECT_STRING="${DB_DRIVER}://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

# Replace the placeholder in .env.local
sed -i "s|APP_URL={app_url}|APP_URL=${DP_HOSTNAME}|" $APP_ROOT/.env.local
sed -i "s|DATABASE_URL={connect_string}|DATABASE_URL=\"${CONNECT_STRING}\"|" $APP_ROOT/.env.local

echo '> Install shopware package';
cd $APP_ROOT
sudo bin/console system:install --basic-setup

# Allow composer plugin without prompt
composer config --no-plugins allow-plugins.php-http/discovery true

# Install profiler and other dev tools, eg Faker for demo data generation
composer require --dev shopware/dev-tools

bin/build-administration.sh
bin/build-storefront.sh
#bin/console assets:install --force
bin/console assets:install

echo "Import database"
cd $APP_ROOT
APP_ENV=prod bin/console framework:demodata && APP_ENV=prod bin/console dal:refresh:index
#mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < ".devpanel/dumps/shopware.sql"
