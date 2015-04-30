FROM eclm/wildfly

ENV MAVEN_VERSION 3.3.1

USER root

RUN curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

USER jboss

RUN mvn dependency:get \
		-Dartifact=com.selectica.eclm-wars:rcf-base:1.0.0-SNAPSHOT:war:jboss \
		-Dtransitive=false \
		-DremoteRepositories=central::default::http://10.100.1.218:8081/artifactory/libs-snapshot-local \
	&& mvn dependency:copy \
		-Dartifact=com.selectica.eclm-wars:rcf-base:1.0.0-SNAPSHOT:war:jboss \
		-DoutputDirectory=/opt/jboss/ \
	&& cp /opt/jboss/*.war /opt/jboss/wildfly/standalone/deployments/eclm.war
