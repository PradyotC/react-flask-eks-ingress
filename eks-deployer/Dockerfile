FROM amazonlinux:2023

ARG TARGETARCH

# Install base utilities
RUN dnf update -y && \
    dnf install -y --allowerasing tar gzip unzip curl jq git nano bash-completion openssl && \
    dnf clean all

# Install AWS CLI v2
RUN if [ "$TARGETARCH" = "arm64" ]; then AWS_ARCH="aarch64"; else AWS_ARCH="x86_64"; fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# Install kubectl
RUN curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/${TARGETARCH}/kubectl && \
    chmod +x ./kubectl && mv ./kubectl /usr/local/bin/

# Install eksctl
RUN curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${TARGETARCH}.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && ./get_helm.sh && rm get_helm.sh

WORKDIR /workspace

# Copy in our automation scripts
COPY deploy.sh /usr/local/bin/deploy.sh
COPY destroy.sh /usr/local/bin/destroy.sh
RUN chmod +x /usr/local/bin/deploy.sh /usr/local/bin/destroy.sh

# The container will run the deploy script, then drop to an interactive bash shell
ENTRYPOINT ["/usr/local/bin/deploy.sh"]
