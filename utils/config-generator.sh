#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

function base64encode {
	echo -n "$1" | base64
}

function escape {
	echo -n "$1" | sed -e 's/\./\\./g;s/\//\\\//g;'
}

function generate_configs {
	echo "generate_configs started"

	if [ -f "secrets.sh" ]; then
		source "secrets.sh"
	else
		echo "WARNING: secrets.sh not found. using default secrets"
	fi

	sed_script=""
	sed_script_base64=""
	for var in taiga_smtp_password taiga_secret_key nfs_prefix nfs_server region taiga_database_password taiga_public_hostname traefik_cloud_domain jenkins_public_hostname taiga_smtp_host taiga_smtp_port taiga_smtp_user traefik_email; do
		value=$(escape "${!var}")
		base64=$(base64encode "${!var}")
		sed_script+="\$_ =~ s/\{\{$var\}\}/${value}/g;"
		sed_script_base64+="\$_ =~ s/\{\{${var}_base64\}\}/${base64}/g;"
	done
	sed_script+="print \$_"
	sed_script_base64+="print \$_"

	cd template
	find . -type d -exec mkdir -p "../${region}/{}" \;
	for i in `find . -type f -name "*.yaml"`; do
	    #echo "render ${i}"
			cat ${i} | perl -ne "$sed_script" | perl -ne "$sed_script_base64" > ../${region}/${i}
	done

	echo "generate_configs finished"
}

function render {
  eval "echo \"$(cat $1)\""
}

function remove_configs {
	echo "remove_configs started"
	rm -rf $region
	echo "remove_configs finished"
}
