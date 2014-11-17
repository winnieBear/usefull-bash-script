#!/bin/bash
# install/update jdk shell script
#set -x
debug=y

pkgname=""
basepath=/opt

show_err() {
echo -e "\033[1;31m$@\033[0m" 1>&2
}

show_warn() {
echo -e "\033[1;33m$@\033[0m"
}

Usage() {
	args=( "help" "update" "install" )
	desc=( "show this help messages" "update jdk from jdk-file.tar.gz" "install jdk from jdk-file.tar.gz" )
	echo "Usage:\t$0 [argument]  jdk-file.tar.gz  [directory]\n"
	for ((i=0; i<${#args[@]}; i++)); do
		printf "\t%-15s%-s\n" "${args[i]}" "${desc[i]}"
	done
	echo ""
}

# check whether is root user
if [ "$(whoami)" != "root" ]; then
	show_err "Please run this script as root"
	exit 1
fi

# check jdk package name and unzip it
if [[ -n "$2" && "$2" =~ jdk.*\.tar\.gz ]]; then
	pkgname=$2
else
	show_err "Please use valid jdk packget, like jdk-8u20-linux-x64.tar.gz"
	Usage
	exit 1
fi

if [ ! -e "$2" ]; then
	show_err "File $2 not exists"
	exit 1
fi

# check basepath
if [[ -n "$3" && -d "$(dirname $3)" ]]; then
	basepath=${3%%/}
fi

# update jdk config
update_config() {
	chmod a+x "${JAVA_HOME}/bin/java"
	chmod a+x "${JAVA_HOME}/bin/javac"
	chmod a+x "${JAVA_HOME}/bin/javaws"
	chown -R root:root "${JAVA_HOME}"
	if [ -z "$debug" ]; then
		update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java"
		update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac"
		update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws"
		update-alternatives --config java
		update-alternatives --config javac
		update-alternatives --config javaws
	fi
}

install() {
	# check whether java or openjava exists
	if [ -z "$debug" ] && [ -n "$(which java)" ]; then
		if [ -n "$(java -verion 2>&1 | grep open)" ]; then
			show_warn "OpenJDK exists, still want to install?[y|N]"
			read still_install
			if [[ ! "$still_install" =~ y|Y|yes|Yes ]]; then
				show_err "Stop to install/update jdk..."
				exit 1
			else
				show_warn "OpenJDK will be replace after install"
			fi
		else
			show_warn "jdk exists, please use update"
			exit 1
		fi
	fi

	mkdir -p $basepath
	jdkname=$(tar -tvf $pkgname | head -1 | awk '{print $NF}')
	tar -xvf $pkgname
	mv "$jdkname" "${basepath}/jdk"

	if [ -n "$debug" ]; then
		OLD_JAVA_HOME=$JAVA_HOME
		OLD_CLASSPATH=$CLASSPATH
		OLD_PATH=$PATH
	fi

	if [ -d "${basepath}/jdk" ]; then
		export JAVA_HOME=${basepath}/jdk
		export CLASSPATH=.:${JAVA_HOME}/lib
		export PATH=${JAVA_HOME}/bin:${PATH}

	# Add this line to /etc/profile
		cat << EOF >> /etc/profile

# add this line if /opt/profile exists
[ -r "${basepath}/profile" ] && . ${basepath}/profile

EOF

	# Add customisize profile
		cat << EOF >> ${basepath}/profile
# customsize profile in the directory 
# jdk profile
# tar -xvf jdk-*.tar.gz

basepath=$basepath

# add this line to the /etc/profile
# [ -r "\${basepath}/profile" ] && . \${basepath}/profile
# for example scriptfile in /opt
# [ -r /opt/profile ] && . /opt/profile

if [ -d "\${basepath}/jdk" ]; then
	export JAVA_HOME=\${basepath}/jdk
	export CLASSPATH=.:\${JAVA_HOME}/lib
	export PATH=\${JAVA_HOME}/bin:\${PATH}
fi
EOF

		update_config
	fi
	if [ -n "$debug" ]; then
		JAVA_HOME=$OLD_JAVA_HOME
		CLASSPATH=$OLD_CLASSPATH
		PATH=$OLD_PATH
	fi
}

update() {
	if [[ -z "$debug" && "${basepath}/jdk/bin/java" == "$(which java)" ]]; then
		jdkname=$(tar -tvf $pkgname | head -1 | awk '{print $NF}')
		tar -xvf $pkgname
		mv "${jdkname}" "${basepath}/jdk"

		if [ -n "$debug" ]; then
			OLD_JAVA_HOME=$JAVA_HOME
			OLD_CLASSPATH=$CLASSPATH
			OLD_PATH=$PATH
		fi

		if [ -d "${basepath}/jdk" ]; then
			export JAVA_HOME=${basepath}/jdk
			export CLASSPATH=.:${JAVA_HOME}/lib
			export PATH=${JAVA_HOME}/bin:${PATH}
			update_config
		fi

		if [ -n "$debug" ]; then
			JAVA_HOME=$OLD_JAVA_HOME
			CLASSPATH=$OLD_CLASSPATH
			PATH=$OLD_PATH
		fi

	else
		show_err "${basepath}/jdk/ not exists"
		exit 1
	fi
}

case "$1" in
	update)
		update
		;;
	install)
		install
		;;
	help|*)
		Usage
		exit;;
esac

