#!/bin/sh
files='
test-data.zip
'
DB_NORMALIZED_PY='postgresql+psycopg2://postgres:pass@localhost:21139'
DB_NORMALIZED='postgresql://postgres:pass@localhost:21139'
DB_DENORMALIZED='postgresql://postgres:pass@localhost:11139'

wait_for_db() {
    echo "waiting for $1 ..."
    i=0
    while [ "$i" -lt 90 ]; do
        if psql "$1" -c 'SELECT 1;' >/dev/null 2>&1; then echo "  $1 is ready"; return 0; fi
        i=$((i+1)); sleep 2
    done
    echo "  timed out waiting for $1" >&2; return 1
}

wait_for_db "$DB_NORMALIZED"   || exit 1
wait_for_db "$DB_DENORMALIZED" || exit 1

echo 'load normalized'
for file in $files; do
    python3 load_tweets.py --db "$DB_NORMALIZED_PY" --inputs "$file"
done

echo 'load denormalized'
for file in $files; do
    unzip -p "$file" \
        | sed 's/\\u0000//g' \
        | psql "$DB_DENORMALIZED" -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done
