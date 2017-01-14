#!/usr/bin/env bash
"/Users/victor/Programs/pgsql/bin/pg_dump" \
  --host=localhost \
  --port=2040 \
  --username=lt_admin \
  --dbname=life_tool \
  --encoding=UTF8 \
  --schema-only \
  --file="/Users/victor/Source/life_tool2/db/life_tool.sql"
