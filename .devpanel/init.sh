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

# Run shopware install
echo "Connection string: mysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
echo '> Install shopware package';
echo '> bin/console system:install --basic-setup --create-database --force';
cd $APP_ROOT
#sudo bin/console system:install --basic-setup --create-database --force
sudo bin/console system:install --basic-setup
#sudo chown -R www:www public/ vendor/ var/

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
