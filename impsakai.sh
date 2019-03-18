#! /bin/bash

sed -i "777c portal.iframesuppress=:all:sakai.scorm.singlepackage.tool:sakai.scorm.tool" /sakai0/tomcat/sakai/sakai.properties;
# Install the Sakai master project
cd /sakai0/sakai/master;
mvn clean install > /sakai0/logs-implementacion/ins-sakai.log;
# mvn clean install -Dmaven.test.skip=true sakai:deploy

# Install and deploy Sakai
cd /sakai0/sakai;
mvn clean install sakai:deploy -Dmaven.tomcat.home=/sakai0/tomcat -Dsakai.home=/sakai0/tomcat/sakai -Djava.net.preferIPv4Stack=true -Dmaven.test.skip=true > /sakai0/logs-implementacion/imp-sakai.log;
# -Dsakai.home=/sakai0/tomcat/sakai
