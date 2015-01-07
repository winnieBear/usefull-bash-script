#!/bin/bash
# install sdk from adt-bundle-*.zip
set -x
#debug=y

basepath=/var/opt
user=$(who | awk '{print $1}' | sed '/^root$/d' | uniq)

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

if [[ -n "$1" && "$(basename $1)" =~ adt-bundle-.*\.zip ]]; then
	unzip $1 -d ./
	sdkdir="$(basename ${1%%\.zip})/sdk"
	if [ -d "$sdkdir" ]; then
		if [ ! -d "$basepath" ]; then
			mkdir -p $basepath
		fi
		mv ./$sdkdir ${basepath}/sdk

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

			chown -R "$user":"$user" "${basepath}/sdk"
			chown root "${basepath}/sdk/platform-tools/adb"
			chmod u+s "${basepath}/sdk/platform-tools/adb"
			#chmod +r "${basepath}/sdk"
			#chmod +x "${basepath}/sdk/tools"
			#${basepath}/sdk/tools/android update sdk --no-ui
			if [[ $(uname -a | egrep -i "debian|ubuntu") ]]; then
				dpkg --add-architecture i386 && apt-get update && apt-get install lib32stdc++6 lib32z1 libgl1-mesa-glx
			elif [[ $(uname -a | egrep -i "arch") ]]; then
				#pacman -S lib32stdc++
			fi
		fi

	fi
else
	show_err "Please use valid adt packget, like adt-bundle-linux-x86_64-*.zip"
fi
