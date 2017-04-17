#!/bin/bash

# Get a certificate for a site

function faile {
	echo "--- $* ---" >&2
	exit 1
}

function argcheck {
	local arg="$1"; shift

	if [[ -z "$1" ]]; then
		faile "Please specify $*"
	fi
}

function get_issuer_cert {
# example line -- CA Issuers - URI:http://cert.int-x3.letsencrypt.org/
}

action="$1"; shift
domain="$1"; shift

argcheck "$action" "action (view|add)"
argcheck "$domain" domain name

connectstring="$domain"
if [[ ! "$domain" =~ :[0-9]+$ ]]; then
	connectstring="$domain:443"
fi

domaindir=/usr/share/ca-certificates/domains

tmpcert="$(mktemp)"

openssl s_client -servername "$domain" -connect "$connectstring" </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$tmpcert" || faile "Could not connect to [$domain]"

case "$action" in
add)
	sudo mkdir "$domaindir" -p
	sudo mv "$tmpcert" "$domaindir/$domain.crt"

	sudo dpkg-reconfigure ca-certificates
	;;
view)
	openssl x509 -text -noout -in "$tmpcert"
	;;
*)
	faile Invalid action
	;;
esac
