#!/bin/bash

cd "$(dirname "$0")"

exists() {
	echo "Skipping $1 -- already exists"
}

maycp() {
    [[ ! -f "$2" ]] || {
        exists "$2"
        return
    }

    cp "$1" "$2"
}

#Pre-check

if [[ "$UID" != 0 ]] && [[ -f "/etc/certmaker/certmaker.config" ]] ; then
    echo "Certmaker is already installed on this machine for root. User certmaker cannot co-exist with root certmaker."
    exit 1
fi

# ---------------------
# Create main dirs

BINS=/usr/bin
CONFIGD=/etc/certmaker
DATAD=/var/certmaker

if [[ "$UID" != 0 ]] ; then
    BINS="$HOME/.local/bin"
    CONFIGD="$HOME/.config/certmaker"
    DATAD="$HOME/.local/certmaker"
fi

mkdir -p "$BINS"
mkdir -p "$CONFIGD"
mkdir -p "$DATAD"/{hosts,default-cnf}

# ---------------------
# Deploy

if [[ "$*" =~ cert-getter ]]; then
	cp bin/cert-getter.sh "$BINS/"

	echo "cert-getter.sh installed"
else
	cp bin/certmaker "$BINS/"

	if [[ ! -f "$CONFIGD/certmaker.config" ]]; then
	    sed "
	    s=%CASTORE%=$DATAD/ca=
	    s=%HOSTSTORE%=$DATAD/hosts=
	    s=%DEFAULTCNF%=$DATAD/default-cnf=
	    s=%USER%=$(whoami)=
	    " cm-config/default-certmaker.config > "$CONFIGD/certmaker.config"
	else
		exists "$CONFIGD/certmaker.config"
	fi

	maycp cm-config/host.cnf "$DATAD/default-cnf/host.cnf"
	maycp cm-config/ca.cnf "$DATAD/default-cnf/ca.cnf"

	echo "Installed certmaker"
fi
