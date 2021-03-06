#%include util.sh

### New registered host Usage:new-host
#
# Create a new stored host for certfiying
#
# Generates a key + CSR pair stored against the name
#
# 	certmaker new host HOST
#
###/doc

cm:host:new-host() {
	cm:helpcheck new-host "$@"

	if [[ -z "$*" ]]; then
		out:fail "You need to specify a name for the host configuration. Try adding '--help'"
	fi

	local myhost myhostd
	myhost="$1"; shift
	myhostd="$hoststore/$myhost"

	[[ "$myhost" =~ ^[a-zA-Z0-9_.-]+$ ]] || out:fail "Host name can only contain letters, numbers, underscore, period and dash."

	[[ ! -d "$myhostd" ]] || out:fail "Host '$myhost' already exists."

	mkdir -p "$myhostd"

	cm:template host "$myhostd/$myhost.cnf"
}
