#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (C) 2024 DevPanel
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

echo -e "-------------------------------"
echo -e "| DevPanel Quickstart Creator |"
echo -e "-------------------------------\n"


# Preparing
WORK_DIR=$APP_ROOT
TMP_DIR=/tmp/devpanel/quickstart
DUMPS_DIR=$TMP_DIR/dumps
mkdir -p $DUMPS_DIR

# Step 1 - Compress drupal database
cd $WORK_DIR
echo -e "> Export database"
mysqldump  -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME  > $TMP_DIR/$DB_NAME.sql --no-tablespaces

echo -e "> Compress database"
tar czf $DUMPS_DIR/db.sql.tgz -C $TMP_DIR $DB_NAME.sql

echo -e "> Store database to $APP_ROOT/.devpanel/dumps"
mkdir -p $APP_ROOT/.devpanel/dumps
mv $DUMPS_DIR/db.sql.tgz $APP_ROOT/.devpanel/dumps/db.sql.tgz
