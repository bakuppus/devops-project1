FROM tomcat:8.0

COPY tomcat-users.xml /usr/local/tomcat/conf/

RUN mkdir -p /usr/local/tomcat/webapps/dev
COPY javaee7-simple-sample.war  /usr/local/tomcat/webapps/dev

CMD chmod +x /usr/local/tomcat/bin/

CMD ["catalina.sh", "run"]

EXPOSE 8080
