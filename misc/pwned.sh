#! /bin/bash
# check password against have I been pwned with simple bash script
# ex. ./pwned.sh password
# Fred Posner. July 2019.
# Always be kind.

PASSWORD=$1
SHA1PASS=$(echo -n "$PASSWORD" | sha1sum | awk '{print $1}')
HASHPASS=${SHA1PASS:0:5}
HASHLEFT=${SHA1PASS:5}
COUNT=$(curl -s https://api.pwnedpasswords.com/range/$HASHPASS | grep -i $HASHLEFT | awk -F: '{print $2}')

if [ -z ${COUNT} ]; then echo "Password looks good."; else echo "password found: $COUNT"; fi