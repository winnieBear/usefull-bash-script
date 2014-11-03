#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: ${0} jdk-file.tar.gz [directory]"
	exit 1
else
	tar -xvf $1
	jdkname=$(tar -tvf $1 | head -1 | awk '{print $NF}')
	if [ -n $2 ]; then
		BASE_PATH=$2
	else
		mkdir -p /opt
		BASE_PATH=/opt
	fi
fi

user=$(whoami)
# TODO 根据用户判断

mv ${jdkname} ${BASE_PATH}/jdk

if [ -d ${BASE_PATH}/jdk ]; then
	export JAVA_HOME=${BASE_PATH}/jdk
	export CLASSPATH=.:${JAVA_HOME}/lib
	export PATH=${JAVA_HOME}/bin:${PATH}

	cat << EOF >> /etc/profile

# add this line if /opt/profile exists
[ -r ${BASE_PATH}/profile ] && . ${BASE_PATH}/profile
EOF

	cat << EOF > ${BASE_PATH}/profile
# customsize profile in the directory 
# tar -xvf jdk-*-linux-*.tar.gz

BASE_PATH=\$(cd "\$(dirname \${0})" && pwd)

# add this line to the /etc/profile
# [ -r \${BASE_PATH}/profile ] && . \${BASE_PATH}/profile
# for example scriptfile in /opt
# [ -r /opt/profile ] && . /opt/profile

if [ -d \${BASE_PATH}/jdk ]; then
	export JAVA_HOME=\${BASE_PATH}/jdk
	export CLASSPATH=.:\${JAVA_HOME}/lib
	export PATH=\${JAVA_HOME}/bin:\${PATH}
fi
EOF

fi

if [[ $(java -verion 2>&1 | grep "open") != "" || $(which java) == "" ]]; then
	chmod a+x "${JAVA_HOME}/bin/java"
	chmod a+x "${JAVA_HOME}/bin/javac"
	chmod a+x "${JAVA_HOME}/bin/javaws"
	chmod -R root:root "${JAVA_HOME}"
	update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java"
	update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac"
	update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws"
	update-alternatives --config java
	update-alternatives --config javac
	update-alternatives --config javaws
fi
