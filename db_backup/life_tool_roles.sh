#!/usr/bin/env bash
"/Users/victor/Programs/pgsql/bin/pg_dump" \
  --host=localhost \
  --port=2040 \
  --username=postgres \
  --roles-only \
  --file="/Users/victor/Source/life_tool2/db/life_tool_roles.sql"

