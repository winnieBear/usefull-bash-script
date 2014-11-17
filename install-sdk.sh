#!/bin/bash
# install sdk from adt-bundle-*.zip
#debug=y

basepath=/opt

show_err() {
echo -e "\033[1;31m$@\033[0m" 1>&2
}

show_warn() {
echo -e "\033[1;33m$@\033[0m"
}

# check whether is root user
if [ "$(whoami)" != "root" ]; then
	show_err "Please run this script as root"
	exit 1
fi

# check basepath
if [[ -n "$2" && -d "$(dirname $2)" ]]; then
	basepath=${2%%/}
fi

if [[ -n "$1" && $1 =~ adt-bundle-.*\.zip ]]; then
	unzip $1
	sdkdir="${1%%\.zip}/sdk"
	if [ -d "$sdkdir" ]; then
		if [ ! -d "$basepath" ]; then
			mkdir -p $basepath
		fi
		mv $sdkdir ${basepath}/sdk

		if [ -d "${basepath}/sdk" ]; then
	# Add customisize profile
			cat << EOF >> ${basepath}/profile

# sdk profile
if [ -d "\${basepath}/sdk" ]; then
	export SDK=\${basepath}/sdk
	export PATH=\${SDK}/platform-tools:\${SDK}/tools:\${PATH}
	for i in \${SDK}/build-tools/android-*; do
		export PATH=\${i}:\${PATH}
	done
	unset i
fi

EOF

			chown -R root:root "${basepath}/sdk"
			chmod u+s "${basepath}/sdk/platform-tools/adb"
			chmod -R +r "${basepath}/sdk"
			chmod -R +x "${basepath}/sdk"
			${basepath}/sdk/tools/android update sdk --no-ui
		fi

	fi
else
	show_err "Please use valid adt packget, like adt-bundle-linux-x86_64-*.zip"
fi
