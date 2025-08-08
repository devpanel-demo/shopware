#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (C) 2023 DevPanel
# You can install any service here to support your project
# Please make sure you run apt update before install any packages
# Example:
# - sudo apt-get update
# - sudo apt-get install nano
#
# ----------------------------------------------------------------------

sudo apt-get update
sudo apt-get install -y nano jq
sudo chown -R 1000:1000 "/home/www/.npm"

echo '> Install node 22'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
echo "> Installed Node $(node -v), NPM $(npm -v)"
sudo chown www:www $HOME/.npm $HOME/.npmrc $HOME/.nvm

echo '> Install composer';
if [[ ! -n "$APACHE_RUN_USER" ]]; then
  export APACHE_RUN_USER=www-data
fi
if [[ ! -n "$APACHE_RUN_GROUP" ]]; then
  export APACHE_RUN_GROUP=www-data
fi

#== Composer install.
sudo chown -R www:www /var/www/html
if [[ -f "$APP_ROOT/composer.json" ]]; then
  cd $APP_ROOT && composer install;
fi

# Run shopware install
echo '> Install shopware package';
echo '> bin/console system:install --basic-setup --create-database --force';
cd $APP_ROOT
sudo bin/console system:install --basic-setup --create-database --force
sudo chown -R www:www public/ vendor/ var/

# Install profiler and other dev tools, eg Faker for demo data generation
composer require --dev shopware/dev-tools

bin/build-administration.sh
bin/build-storefront.sh
bin/console assets:install --force

#APP_ENV=prod bin/console framework:demodata && APP_ENV=prod bin/console dal:refresh:index
