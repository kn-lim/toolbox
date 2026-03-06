FROM debian:13.3-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install mise
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:$PATH"

# Install tools and copy binaries to staging directory
WORKDIR /build
COPY mise.toml .
RUN mise trust . && \
    mise install && \
    mkdir /tools && \
    for tool in argocd jq task terragrunt terraform yq; do \
        cp $(mise which $tool) /tools/$tool; \
    done

FROM debian:13.3-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /tools/ /usr/local/bin/

WORKDIR /
