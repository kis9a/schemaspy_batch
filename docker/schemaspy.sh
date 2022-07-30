#!/bin/sh

if [ -d "$SCHEMASPY_DRIVERS" ]; then
  export DRIVER_PATH="$SCHEMASPY_DRIVERS"
else
  export DRIVER_PATH=/drivers_inc/
fi

printf "Using drivers:"

# shellcheck disable=SC2012
ls -Ax "$DRIVER_PATH" | sed -e 's/  */, /g'

exec java -jar /usr/local/lib/schemaspy/schemaspy*.jar -dp "$DRIVER_PATH" -o "$SCHEMASPY_OUTPUT" "$@"
