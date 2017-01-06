#!/usr/bin/env bash
docker-compose \
  -f dc/postgres_life_tool.yml \
  up -d
