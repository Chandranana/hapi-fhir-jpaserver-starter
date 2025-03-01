#!/bin/bash -ex
# -----------------------------------------------------------------------------
#
# Package	: tomcat
# Version	: v11.0.0-M3
# Source repo	: https://github.com/apache/tomcat.git
# Language      : Java
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer	: Chandranana Naik <Naik.Chandranana@ibm.com>
#
# Disclaimer: This script has been tested in non-root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------


PACKAGE_NAME=tomcat
PACKAGE_VERSION=${1:-11.0.0-M3}
PACKAGE_URL=https://github.com/apache/tomcat.git

OS_NAME=`cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f2 | tr -d '"'`

cd ${HOME}
apt-get update -y
apt-get install -y git wget
apt-get install -y java-17-openjdk-devel.ppc64le

##Set JAVA_HOME
JAVA_HOME=$(update-alternatives --list | grep java_sdk_17_openjdk | cut -f  3)
export PATH=$JAVA_HOME/bin:$PATH

## Installing apache-ant
wget http://mirror.downloadvn.com/apache/ant/binaries/apache-ant-1.10.12-bin.tar.gz
tar -xf apache-ant-1.10.12-bin.tar.gz
export ANT_HOME=${HOME}/apache-ant-1.10.12/
export PATH=${PATH}:${ANT_HOME}/bin

##Cloning the repo
if ! git clone $PACKAGE_URL; then
    echo "------------------$PACKAGE_NAME:clone_fails---------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    exit 0
fi

##Configuring tomcat build
cd tomcat
git checkout $PACKAGE_VERSION
yes | cp build.properties.default build.properties
echo >> build.properties
echo "skip.installer=true" >> build.properties

##Building tomcat server

if ! ant release ; then
       echo "------------------$PACKAGE_NAME:Build_fails---------------------"
       echo "$PACKAGE_VERSION $PACKAGE_NAME"
       echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Build_Fails"
       exit 1
fi

echo "==========================================================================="
echo "Tomcat server installed successfully. Use below commands to start the server"
echo "============================================================================"

##Testing tomcat server on port 8080

echo "export CATALINA_HOME=${HOME}/tomcat/output/dist"
printf 'export PATH=%s/tomcat/output/dist/bin:${PATH} \n' "${HOME}"
echo "export JAVA_HOME=$JAVA_HOME"
printf 'export PATH=$JAVA_HOME/bin:$PATH \n'
echo "cd ${HOME}/tomcat/output/dist/bin"
printf "\n"
echo "Start the server using command(server might take few seconds to start): catalina.sh run &"
echo "curl localhost:8080"
printf "\n"
echo "To stop the server: catalina.sh stop"
