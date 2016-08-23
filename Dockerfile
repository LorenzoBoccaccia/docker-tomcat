FROM  openjdk:8-jdk

# Expose web port
EXPOSE 8080
EXPOSE 8443

# Tomcat Version
ENV TOMCAT_VERSION_MAJOR 8
ENV TOMCAT_VERSION_FULL  8.5.4

# Download and install
RUN curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz &&\
  curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.md5 &&\
  md5sum -c apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.md5 &&\
  gunzip -c apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz | tar -xf - -C /opt &&\
  rm -f apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.md5 &&\
  ln -s /opt/apache-tomcat-${TOMCAT_VERSION_FULL} /opt/tomcat &&\
  rm -rf /opt/tomcat/webapps/examples /opt/tomcat/webapps/docs 

RUN sed -i 's/52428800/5242880000/g' /opt/tomcat/webapps/manager/WEB-INF/web.xml 


# Configuration
ADD tomcat-users.xml /opt/tomcat/conf/
ADD context.xml /opt/tomcat/webapps/manager/META-INF/
ADD run.sh /opt/tomcat/bin/

# SSL

RUN keytool -genkey -keystore /opt/tomcat/keystore -alias tomcat -keyalg RSA -keysize 4096 -validity 720 -noprompt  -dname "CN=$(hostname), OU=, O=, L=, S=, C=" -storepass password -keypass password

RUN sed -i '109i <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol" maxThreads="150" SSLEnabled="true" scheme="https" secure="true" clientAuth="false" sslProtocol="TLS" keyAlias="tomcat" keystoreFile="/opt/tomcat/keystore" keystorePass="password" />'  /opt/tomcat/conf/server.xml


RUN chmod a+x /opt/tomcat/bin/run.sh
# Set environment
ENV CATALINA_HOME /opt/tomcat

# Launch Tomcat on startup
CMD ${CATALINA_HOME}/bin/run.sh
