
# to build:
#  docker build -t java-webapp .
# to run:
#  docker run -it --rm -p 8080:8080 java-webapp
# then navigate to:
#  http://localhost:8080/java-webapp-container/

FROM jetty:9.4.11
COPY target/java-webapp-container.war /var/lib/jetty/webapps/
