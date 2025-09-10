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
DUMPS_DIR=$APP_ROOT/.devpanel/dumps
mkdir -p $DUMPS_DIR

# Step 1 - Export and compress database
cd $WORK_DIR
echo -e "> Export database"
mysqldump  -h$DB_HOST -u$DB_USER -p$DB_PASSWORD --quick --lock-tables=false --ignore-table=$DB_NAME.media $DB_NAME > $DUMPS_DIR/db.sql --no-tablespaces
sed -i 's/INSERT INTO/INSERT IGNORE INTO/g' $DUMPS_DIR/db.sql

# - Append media structure only (no rows)
mysqldump -h$DB_HOST -u$DB_USER -p$DB_PASSWORD \
  --quick --lock-tables=false --no-tablespaces \
  $DB_NAME media --where="1=0" >> $DUMPS_DIR/db.sql

# - Create helper table from media
mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "
  DROP TABLE IF EXISTS media_tmp;
  CREATE TABLE media_tmp AS
  SELECT
    id, user_id, media_folder_id, mime_type, file_extension,
    file_size, meta_data, file_name, media_type, thumbnails_ro,
    private, uploaded_at, created_at, updated_at, path, config
  FROM media;"

# - Dump that table data
mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD \
  --skip-triggers --no-create-info \
  $DB_NAME media_tmp > $DUMPS_DIR/media_nohash_data.sql

# - Replace ALL mentions of media_tmp with media, then append to main file
sed -i 's/`media_tmp`/`media`/g' $DUMPS_DIR/media_nohash_data.sql
sed -i 's/INSERT INTO `media`/INSERT INTO `media` (`id`, `user_id`, `media_folder_id`, `mime_type`, `file_extension`, `file_size`, `meta_data`, `file_name`, `media_type`, `thumbnails_ro`, `private`, `uploaded_at`, `created_at`, `updated_at`, `path`, `config`)/g' $DUMPS_DIR/media_nohash_data.sql

cat $DUMPS_DIR/media_nohash_data.sql >> $DUMPS_DIR/db.sql

du -h $DUMPS_DIR/db.sql

echo -e "> Compress database"
tar -czf db.sql.tgz -C $DUMPS_DIR db.sql
rm -rf db.sql

# Step 2 - Compress static files
mkdir -p $APP_ROOT/.devpanel/dumps
echo -e "> Compress static files and store to $APP_ROOT/.devpanel/dumps"
tar czf $DUMPS_DIR/files.tgz -C $WORK_DIR/public \
  --exclude='.htaccess' \
  --exclude='.htaccess.dist' \
  --exclude='index.php' \
  --exclude='maintenance.html' \
  .
