#!/bin/sh

# if environment variable `version` is set to v2, default aws cli version is v2
# if environment variable `version` is set to v1, not set or set to anything else, except v2, aws cli will be run from /usr/bin, and version is v1
# you can still run specific version with full path in container.
# aws cli v1 - installed at /usr/bin
# aws cli v2 - installed at /usr/local/bin

# adjust $PATH depending on the environment variable "version"
case "${version}" in
  v1) PATH="/usr/bin:$PATH" ;;
  v2) PATH="/usr/local/bin:$PATH" ;;
  *)  PATH="/usr/bin:$PATH" ;;
esac
# Then run the CMD
exec "$@"
