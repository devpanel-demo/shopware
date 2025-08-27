#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (C) 2025 DevPanel
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

set -e

INPUT="db.sql"
OUTPUT="db_fixed.sql"

#== Import database
if [[ $(mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "show tables;") == '' ]]; then
  if [[ -f "$APP_ROOT/.devpanel/dumps/db.sql.tgz" ]]; then
    echo 'Import mysql file ...'
    cd $APP_ROOT/.devpanel/dumps
    tar -xvzf db.sql.tgz
    # sed -i 's/INSERT INTO/INSERT IGNORE INTO/g' db.sql
    # sed -i 's/REPLACE INTO `media`/REPLACE INTO `media` (`id`, `user_id`, `media_folder_id`, `mime_type`, `file_extension`, `file_size`, `meta_data`, `file_name`, `media_type`, `thumbnails_ro`, `private`, `uploaded_at`, `created_at`, `updated_at`, `path`, `config`)/g' db.sql

    # Process only INSERT INTO `media` blocks
    # awk '
    # BEGIN { in_media=0 }
    # /^INSERT INTO `media`/ { in_media=1 }
    # in_media && /^\(/ {
    #   sub(/,\'[A-Fa-f0-9]{32}\'\)/,")")  # remove last hash column
    # }
    # { print }
    # ' "$INPUT" > "$OUTPUT"

    # echo "✅ Cleaned media inserts written to $OUTPUT"

    mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME < db.sql
    mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME -e "update sales_channel_domain set url='$APP_URL' where url='http://localhost';"
    # rm -rf $APP_ROOT/.devpanel/dumps/*
  fi
fi

if [[ -n "$DB_SYNC_VOL" ]]; then
  if [[ ! -f "/var/www/build/.devpanel/init-container.sh" ]]; then
    echo 'Sync volume...'
    sudo chown -R 1000:1000 /var/www/build
    rsync -av --delete --delete-excluded $APP_ROOT/ /var/www/build
  fi
fi
