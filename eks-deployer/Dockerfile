FROM amazonlinux:2023

# Allow Docker to pass the target architecture (amd64 or arm64)
ARG TARGETARCH

# Install base utilities
RUN dnf update -y && \
    dnf install -y --allowerasing tar gzip unzip curl jq git && \
    dnf clean all

# Install AWS CLI v2 based on architecture
RUN if [ "$TARGETARCH" = "arm64" ]; then AWS_ARCH="aarch64"; else AWS_ARCH="x86_64"; fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# Install kubectl (v1.30)
RUN curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/${TARGETARCH}/kubectl && \
    chmod +x ./kubectl && mv ./kubectl /usr/local/bin/

# Install eksctl
RUN curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${TARGETARCH}.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Setup Workspace
WORKDIR /workspace
COPY deploy.sh /usr/local/bin/deploy.sh
RUN chmod +x /usr/local/bin/deploy.sh

# Run the deployment script when the container starts
ENTRYPOINT ["/usr/local/bin/deploy.sh"]
