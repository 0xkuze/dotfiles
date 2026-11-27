#!/bin/sh
# Over SSH (Mac mini) the login keychain is locked, so the key comes from ~/.secrets.env.
KEY=${NEON_API_KEY:-$(/usr/bin/security find-generic-password -a "$USER" -s NEON_API_KEY -w)}
printf '{"Authorization":"Bearer %s"}\n' "$KEY"
