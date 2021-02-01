#!/bin/sh
# Push something on to $PATH depending on the environment
case "${version}" in
  v1) PATH="/usr/bin:$PATH" ;;
  v2) PATH="/usr/local/bin:$PATH" ;;
  *)  PATH="/usr/bin:$PATH" ;;
esac
# Then run the CMD
exec "$@"
