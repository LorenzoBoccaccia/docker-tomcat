#!/bin/sh

#set up and log password

if  grep -Fq   "name=\"admin\" password=\"admin\"" /opt/apache-tomcat-8.5.4/conf/tomcat-users.xml
then

  PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  sed -i.bak "s/password=\"admin\"/password=\"$PASS\"/"  /opt/apache-tomcat-8.5.4/conf/tomcat-users.xml
 
  
fi

PASS=$(cat /opt/apache-tomcat-8.5.4/conf/tomcat-users.xml | awk 'NR >= 9 && NR <= 9' | awk '{print substr( $0, 22, 60 )}')

echo "*********************************************"
echo "*********************************************"
echo "*********************************************"
echo "*********************************************"
echo Manager $PASS
echo "*********************************************"
echo "*********************************************"
echo "*********************************************"
echo "*********************************************"




${CATALINA_HOME}/bin/catalina.sh run
