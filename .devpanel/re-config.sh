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

#== If webRoot has not been difined, we will set appRoot to webRoot

if [[ ! -n "$APACHE_RUN_USER" ]]; then
  export APACHE_RUN_USER=www-data
fi
if [[ ! -n "$APACHE_RUN_GROUP" ]]; then
  export APACHE_RUN_GROUP=www-data
fi

#== If webRoot has not been defined, we will set appRoot to webRoot
if [[ ! -n "$WEB_ROOT" ]]; then
  export WEB_ROOT=$APP_ROOT
fi
mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "update sales_channel_domain set url='https://$DP_HOSTNAME' where url='http://localhost';"
cd $APP_ROOT
cp -r $APP_ROOT/.devpanel/.gitignore $APP_ROOT/.gitignore

echo ">>> Install Dependencies";
composer install --no-interaction --optimize-autoloader

echo ">>> Install Shopware Application";
bin/console system:install --basic-setup --force

echo ">>> Add Devpanel Admin User";
bin/console user:create devpanel --password=devpanel --email=developer@devpanel.com --firstName=DevPanel

echo ">>> allow-plugins";
composer config --no-plugins allow-plugins.php-http/discovery true

# echo ">>> Install dev-tools";
# composer require --dev shopware/dev-tools
# bin/console cache:clear
echo ">>> Successful, please refresh your web page.";