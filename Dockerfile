FROM openjdk:8-jre

COPY build/bootScripts/rpa-professional-api /opt/app/bin/

COPY build/libs/rpa-professional-api.jar /opt/app/lib/

WORKDIR /opt/app

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD http_proxy="" curl --silent --fail http://localhost:4550/health

EXPOSE 4550

ENTRYPOINT ["/opt/app/bin/rpa-professional-api"]
