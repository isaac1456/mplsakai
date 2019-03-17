#! /bin/bash
###########################################################################################################################################
###########################################################################################################################################
#################################################### Configuracion preliminar de sakai ####################################################
###########################################################################################################################################
###########################################################################################################################################

###################################################
############### Variables del script ##############
###################################################
#Particion=;
#usuario=;

#/sakai0/tomcat/sakai/sakai.properties=;

#basedatos=;
#usuariobd=;
#contrasena=;

# variables de puertos
#spuerto=;
#puerto=;
#epuerto=;
#rpuerto=;

## determinando usuario y particion

#read -p "Por favor ingrese la particion a utilizar: " Particion;
#read -p "ingrese el usuario que ejecutará sakai: " usuario;
#echo "Utilizando " $Particion " como usuario " $usuario " para configurar sakai..."

# Determinando la base de datos, usuario y contraseña de usuario de base de datos mysql
#read -p "Ingrese el nombre de la base de datos para crear: " basedatos;
#read -p "Tambien el usuario que sera dueño de la base de datos: " usuariobd;
#read -p "Digite una contraseña de usuario: " contrasena;
#echo "La base de datos " $basedatos " y el usuario " $usuariobd " serán establecidos."
# Particion=/sakai0;
# usuario=;

# Determinando los puertos de recepcion y escuchar de sakai
#echo " no puertos 8080 8005 y 8009"
#read -p "Ingrese el puerto conector por el cual sakai se comunicará con el mundo: " puerto; # 8080
#read -p "tambien el puerto de apagado de la aplicacion: " spuerto; # 8005
#read -p "y el puerto de entrada de peticiones tomcat: " epuerto; # 8009
#read -p "y el puerto de redirección tomcat: " rpuerto; # 8443
# todas las impresiones y datos deben ir a un servidor para guardar las configuraciones por empresa.
#echo "los puertos son: " "conector: " $puerto " | puerto de apagado: " $spuerto " | puerto de entrada tomcat: " $epuerto " | puerto redirección: " $rpuerto
#echo " "

#echo " "


###################################################
######### creando logs de implementacion ##########
###################################################
mkdir /sakai0;
mkdir /sakai0/logs-implementacion;
cd /sakai0/logs-implementacion;
touch git-sakai.log wget-jtm.log apt.log x-jdk.log x-tomcat.log x-mysql.log ins-sakai.log imp-sakai.log;
cd /sakai0;


###################################################
############### Descargas necesarias ##############
###################################################
echo "Descargando archivos necesarios..."
echo " "

# Los siguientes programas son necesarios para la implementación de Sakai 11:
# •	Maven
# •	Git
# •	Java Development kit JDK, versión 8 o reciente.
# •	Servidor de aplicaciones de tomcat, versión 8.0.36 se usa aquí.
# •	Servidor Mysql 5.1 o superior.
# •	Mysql connector , la versión 5.1.39 se usa aquí.
# • servidor php5
# •	Programas relacionados con ADL LRS
# 	o	Servidor postgresql
# 	o	Dependencias 
# 			fabric 
# 			python-setuptools 
# 			python-dev 
# 			libxml2-dev 
# 			libxslt1-dev
# 	o	ADL LRS - Advanced Distributed Learning - Learning Record Store
# •	Códigos fuente relacionados con sakai
# 	o	Sakai 11 en versión estable según tags de github, 11.0 se usa aquí.
# 	o	Implementacion de Scorm  para sakai 11
# 	o	Implementacion de tincan api provider para sakai 11, SakaiXAPI-Provider.


# Agregando key y direccion de repositorio de postgresql en el sistema
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/postgresql.list'
apt-get update
apt-get upgrade


# instalar maven git php5 mysql-server postgresql-9.4 postgresql-server-dev-9.4 postgresql-contrib-9.4 fabric python-setuptools python-dev libxml2-dev libxslt1-dev
apt-get install maven git php mysql-server postgresql-10 postgresql-server-dev-10 postgresql-contrib-10 fabric python-setuptools python-dev libxml2-dev libxslt1-dev -y > /sakai0/logs-implementacion/apt.log; 

#instalando ADL LRS
apt-get install python-pip
pip install virtualenv

# JDK 8u92
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz  > /sakai0/logs-implementacion/wget-jtm.log;

# tomcat 8.0.36
wget https://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.38/bin/apache-tomcat-8.5.38.tar.gz https://www.apache.org/dist/tomcat/tomcat-8/v8.5.38/bin/apache-tomcat-8.5.38.tar.gz.sha512  >> /sakai0/logs-implementacion/wget-jtm.log;

# MySql 5.1.39
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz >> /sakai0/logs-implementacion/wget-jtm.log;
tar xzvf mysql-connector-java-5.1.39.tar.gz  >> /sakai0/logs-implementacion/x-mysql.log;

# obtener el codigo sakai 11
git clone -b 12.6 https://github.com/sakaiproject/sakai.git > /sakai0/logs-implementacion/git-sakai.log;

# 	o	Implementacion de Scorm  para sakai 11
git clone -b 12.x https://github.com/sakaicontrib/SCORM.2004.3ED.RTE

# 	o	ADL LRS - Advanced Distributed Learning - Learning Record Store
git clone -b v1.0.2 https://github.com/adlnet/ADL_LRS.git

# 	o	Implementacion de tincan api provider para sakai 11, SakaiXAPI-Provider.
git clone -b 11.x https://github.com/Apereo-Learning-Analytics-Initiative/SakaiXAPI-Provider.git

git clone -b 12.x https://github.com/sakaicontrib/certification.git

git clone -b https://github.com/EdiaEducationTechnology/edia-sakai-skinmanager.git

###################################################
########### Configuraciones preliminares ##########
###################################################
echo "Configurando Jdk 8..."
echo " "
# instalacion de java 8
tar xzvf jdk-8u201-linux-x64.tar.gz  > /sakai0/logs-implementacion/x-jdk.log;
update-alternatives --install /usr/bin/java java /sakai0/jdk1.8.0_201/bin/java 1110;
update-alternatives --install /usr/bin/javac javac /sakai0/jdk1.8.0_201/bin/javac 1110;

echo "Desplegando el servidor tomcat..."
echo " "
# instalacion de tomcat
tar xzvf apache-tomcat-8.5.38.tar.gz > /sakai0/logs-implementacion/x-tomcat.log;
ln -nsf apache-tomcat-8.5.38 tomcat; 

###################################################
############ Variables del entorno ################
###################################################
echo "Asignando variables del entorno..."
echo " "

export JAVA_HOME=/sakai0/jdk1.8.0_201;
export CATALINA_HOME=/sakai0/tomcat;
export PATH=${PATH}:${JAVA_HOME}/bin/:${CATALINA_HOME}/bin;
export MAVEN_OPTS='-Xms512m -Xmx1024m -Djava.util.Arrays.useLegacyMergeSort=true'


sed -i "17a # ----------------------------------------------------------------------------" /sakai0/tomcat/bin/catalina.sh;
sed -i "18a # Configuring CATALNA_HOME and CATALINA_BASE variables" /sakai0/tomcat/bin/catalina.sh;
sed -i "19a # ----------------------------------------------------------------------------" /sakai0/tomcat/bin/catalina.sh;
sed -i "20a \ #" /sakai0/tomcat/bin/catalina.sh;
sed -i "21a export CATALINA_HOME=`echo /sakai0`/tomcat" /sakai0/tomcat/bin/catalina.sh;
sed -i "22a export CATALINA_BASE=`echo /sakai0`/tomcat" /sakai0/tomcat/bin/catalina.sh;
sed -i "23a export JAVA_HOME=`echo /sakai0`/jdk1.8.0_201" /sakai0/tomcat/bin/catalina.sh;
sed -i "24a export PATH=${PATH}:${JAVA_HOME}/bin/:${CATALINA_HOME}/bin" /sakai0/tomcat/bin/catalina.sh;


###################################################
############## Archivo setenv.sh ##################
###################################################
echo "configurando setenv.sh"
echo " "
# mejorar velocidad de inicio tomcat
touch /sakai0/tomcat/bin/setenv.sh;
cat > /sakai0/tomcat/bin/setenv.sh <<EOF
>linea
>liena
EOF
# para ubicar archivo *.properties en otra ubicacion
# -Dsakai.home=/path/to/desired/sakai/home/
sed -i '1c #! /bin/sh' /sakai0/tomcat/bin/setenv.sh;
sed -i "2c export JAVA_OPTS='-server -Xms512m -Xmx1024m -XX:PermSize=128m -XX:NewSize=192m -XX:MaxNewSize=384m -Djava.awt.headless=true -Dhttp.agent=Sakai -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dsun.lang.ClassLoader.allowArraySyntax=true -Djava.util.Arrays.useLegacyMergeSort=true -Dsakai.demo=true'" /sakai0/tomcat/bin/setenv.sh;


##### Especificar proxy HTTP ########################################################
#
# -Dhttp.proxyHost=cache.some.domain 
# -Dhttp.proxyPort=8080

# To locate your properties file outside of your web application server environment #
# modify the Java startup command or the JAVA_OPTS environment variable and  ########
# set a system property named sakai.home. Make sure your external location  #########
# is readable and writable by your web application server. ##########################
#
# -Dsakai.home=/path/to/desired/sakai/home/

echo "borrando ejemplos de aplicaciones del servidor tomcat"
echo " "
# Borrar webapps
rm -rf /sakai0/tomcat/webapps/*;


###################################################
############## Archivo server.xml #################
###################################################
echo "Agregando codificacion UTF-8 a server.xml"
echo " "
# <Connector port="8080" URIEncoding="UTF-8" ... 
# Esta opcion es insertada antes de la linea 70
sed -i "22c <Server port=\"`echo 8005`\" shutdown=\"SHUTDOWN\">" /sakai0/tomcat/conf/server.xml; # linea 22 puerto de apagado de la aplicacion
sed -i "69c \    <Connector port=\"`echo 8080`\" protocol=\"HTTP/1.1\"" /sakai0/tomcat/conf/server.xml; # puerto del conector de la aplicacionnes
sed -i '70i \\t       URIEncoding="UTF-8"' /sakai0/tomcat/conf/server.xml; 
sed -i "72c \               redirectPort=\"`echo 8443`\" />" /sakai0/tomcat/conf/server.xml; # puerto de redirección
sed -i "92c \    <Connector port=\"`echo 8009`\" protocol=\"AJP/1.3\" redirectPort=\"`echo 8443`\" />" /sakai0/tomcat/conf/server.xml; # linea 92 puerto de entrada de peticiones tomcat


###################################################
########## Archivo catalina.properties ############
###################################################
echo "Configurando el archivo catalina.properties"
echo " "
sed -i '53c common.loader="${catalina.base}/lib","${catalina.base}/lib/*.jar","${catalina.home}/lib","${catalina.home}/lib/*.jar","${catalina.base}/common/classes/","${catalina.base}/common/lib/*.jar"' /sakai0/tomcat/conf/catalina.properties;
sed -i '71c server.loader="${catalina.base}/server/classes/","${catalina.base}/server/lib/*.jar"' /sakai0/tomcat/conf/catalina.properties;
sed -i '90c shared.loader="${catalina.base}/shared/classes/","${catalina.base}/shared/lib/*.jar"' /sakai0/tomcat/conf/catalina.properties;


###################################################
############## Archivo context.xml ################
###################################################
echo "incrementando la velocidad de inicio del servidor"
echo " "
sed -i '29a \    <JarScanner>\n \t<JarScanFilter defaultPluggabilityScan="false" />\n    </JarScanner>' /sakai0/tomcat/conf/context.xml;

###################################################
############## Carpetas necesarias ################
###################################################
echo "Agregando carpetas necesarias"
echo " "
mkdir -p /sakai0/tomcat/shared/classes /sakai0/tomcat/shared/lib /sakai0/tomcat/common/classes /sakai0/tomcat/common/lib /sakai0/tomcat/server/classes /sakai0/tomcat/server/lib;


###################################################
############ Configurar driver mysql ##############
###################################################
echo "Agregando el conector de base de datos mysql"
echo " "
cp /sakai0/mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar /sakai0/tomcat/lib/mysql-connector-java-5.1.39-bin.jar;

###################################################
##### Ejecucion de script en servidor mysql ####### # PENDIENTE POR DESARROLLAR Y VERIFICAR POLITICAS DE SEGURIDAD
###################################################
# echo "Creando la base de datos en MySql..."
# # ref http://clubmate.fi/shell-script-to-create-mysql-database/

# mysql -u root -p

# # Functions
# #ok() { echo -e '\e[32m'$1'\e[m'; } # Green

# MYSQL=`which mysql`
 
# Q1="create database ${basedatos} default character set utf8;"
# Q2="grant all on ${basedatos}.* to ${usuariobd}@'localhost' identified by '${contrasena}';"
# Q3="grant all on ${basedatos}.* to ${usuariobd}@'127.0.0.1' identified by '${contrasena}';"
# Q4= "flush privileges;"

# SQL="${Q1}${Q2}${Q3}${Q4}"

# $MYSQL -u root -p -e "$SQL"

# create database sakai11db default character set utf8;
# grant all on sakai11db.* to sakai11user@'localhost' identified by 'MysqlP.11L#2016';
# grant all on sakai11db.* to sakai11user@'127.0.0.1' identified by 'MysqlP.11L#2016';
# flush privileges;

sudo -u postgres createuser -p -s ${usuariobd}
#Enter password for new role: <db_owner_password>
#Enter it again: <db_owner_password>
sudo -u postgres psql template1
#template1=# CREATE DATABASE lrs OWNER <db_owner_name>;
#template1=# \q (exits shell)


###########################################################################################################################################
###########################################################################################################################################
#################################################### compilar e implementar sakai en tomcat ###############################################
###########################################################################################################################################
###########################################################################################################################################
echo "Compilando e implementando sakai 11..."
echo " "

# Install the Sakai master project
cd /sakai0/sakai/master;
mvn clean install > /sakai0/logs-implementacion/ins-sakai.log;
# mvn clean install -Dmaven.test.skip=true sakai:deploy

# Install and deploy Sakai
cd /sakai0/sakai;
mvn clean install sakai:deploy -Dmaven.tomcat.home=/sakai0/tomcat -Dsakai.home=/sakai0/tomcat/sakai -Djava.net.preferIPv4Stack=true -Dmaven.test.skip=true > /sakai0/logs-implementacion/imp-sakai.log;
# -Dsakai.home=/sakai0/tomcat/sakai

###########################################################################################################################################
###########################################################################################################################################
#################################################### Configurar sakai #####################################################################
###########################################################################################################################################
###########################################################################################################################################
echo "Configurando el archivo sakai.properties..."
echo " "
###################################################
############### sakai.properties ##################
###################################################

###################################################
# 1.0 crear archivo sakai.properties ##############
mkdir /sakai0/tomcat/sakai;
touch /sakai0/tomcat/sakai/sakai.properties;
# Una variable para simplicidad
/sakai0/tomcat/sakai/sakai.properties= /sakai0/tomcat/sakai/sakai.properties;

cp /sakai0/sakai/config/configuration/bundles/src/bundle/org/sakaiproject/config/bundle/default.sakai.properties /sakai0/tomcat/sakai/sakai.properties;
chown ubuntu /sakai0/tomcat/sakai/sakai.properties;
chmod 775 /sakai0/tomcat/sakai/sakai.properties;

###################################################
# 2.0 Configure home page tool set per site #######
sed -i "3199c wsetup.home.toolids.count=5" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3200c wsetup.home.toolids.1=sakai.iframe.site" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3201c wsetup.home.toolids.2=sakai.synoptic.announcement" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3202c wsetup.home.toolids.3=sakai.summary.calendar" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3203c wsetup.home.toolids.4=sakai.synoptic.messagecenter" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3204c wsetup.home.toolids.5=sakai.synoptic.chat" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3205c wsetup.home.toolids.course.count=5" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3206c wsetup.home.toolids.course.1=sakai.iframe.site" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3207c wsetup.home.toolids.course.2=sakai.synoptic.announcement" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3208c wsetup.home.toolids.course.3=sakai.summary.calendar" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3209c wsetup.home.toolids.course.4=sakai.synoptic.messagecenter" /sakai0/tomcat/sakai/sakai.properties;
sed -i "3210c wsetup.home.toolids.course.5=sakai.synoptic.chat" /sakai0/tomcat/sakai/sakai.properties;

###################################################
# 3.0 Work site setup group helper ################


###################################################
# 4.0 Session timeout warning #####################
sed -i "1219c timeoutDialogEnabled=true" /sakai0/tomcat/sakai/sakai.properties;
sed -i "1222c timeoutDialogWarningSeconds=600" /sakai0/tomcat/sakai/sakai.properties;

###################################################
# 5.0 Configure email #############################


###################################################
# 6.0 Configure logging ###########################


###################################################
# 7.0 Managing temporary files ####################


###################################################
# 6.1 Configure database ##########################
sed -i "351c username@javax.sql.BaseDataSource=`echo usersakai`" /sakai0/tomcat/sakai/sakai.properties;
sed -i "352c password@javax.sql.BaseDataSource=`echo sakaipass`" /sakai0/tomcat/sakai/sakai.properties;
sed -i "368c vendor@org.sakaiproject.db.api.SqlService=mysql" /sakai0/tomcat/sakai/sakai.properties;
sed -i "369c driverClassName@javax.sql.BaseDataSource=com.mysql.jdbc.Driver" /sakai0/tomcat/sakai/sakai.properties;
sed -i "370c hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect" /sakai0/tomcat/sakai/sakai.properties;
sed -i "371c url@javax.sql.BaseDataSource=jdbc:mysql://127.0.0.1:3306/`echo sakaidb`?useUnicode=true&characterEncoding=UTF-8" /sakai0/tomcat/sakai/sakai.properties;
sed -i "372c validationQuery@javax.sql.BaseDataSource=select 1 from DUAL" /sakai0/tomcat/sakai/sakai.properties;
sed -i "373c defaultTransactionIsolationString@javax.sql.BaseDataSource=TRANSACTION_READ_COMMITTED" /sakai0/tomcat/sakai/sakai.properties;







###################################################
######## Propiedades y archivos innecesarios ######
###################################################

echo "Ajustando los permisos y propiedades de archivos..."
echo " "
# Verificar permisos y propiedades
chown -R ubuntu:ubuntu /sakai0/tomcat && chmod -R 775 /sakai0/tomcat;
chown -R ubuntu:ubuntu /sakai0/sakai && chmod -R 775 /sakai0/sakai;
chown ubuntu:ubuntu -R /sakai0/apache-tomcat-8.5.38 && chmod -R 775 /sakai0/apache-tomcat-8.5.38;

# Borrando archivos innecesarios
echo "Borrando archivos que no son necesarios..."
echo " "
cd /sakai0;
rm -r jdk-8u201-linux-x64.tar.gz mysql-connector-java-5.1.39.tar.gz apache-tomcat-8.0.36.tar.gz apache-tomcat-8.5.38.tar.gz.sha1 mysql-connector-java-5.1.39;

# # arranque de la aplicacion
# echo "Iniciando sakai 11... "
# echo " "
# su $usuario cd /sakai0/tomcat/bin;
# su $usuario cd
