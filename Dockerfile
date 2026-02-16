FROM jenkins/jenkins:2.541.1-jdk21
USER root

# Install Docker CLI and prerequisites
RUN apt-get update && \
    apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to jenkins user
USER jenkins

# Install recommended plugins including Blue Ocean
RUN jenkins-plugin-cli --plugins \
    blueocean \
    docker-workflow \
    json-path-api \
    configuration-as-code

# Note: More plugins can be added based on your needs
# Common additions:
# git \
# github \
# pipeline-stage-view \
# workflow-aggregator
