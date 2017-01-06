#!/usr/bin/env bash
"/Users/victor/Programs/pgsql/bin/pg_dump" \
  --host=localhost \
  --port=2040 \
  --username=lt_admin \
  --password \
  --dbname=life_tool \
  --format=p \
  --encoding=UTF8 \
  --schema-only \
  --file="/Users/victor/Source/life_tool2/db/life_tool.sql"
