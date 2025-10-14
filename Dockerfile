# Stage 1: Build stage - Used to prepare dependencies and package the application
FROM python:3.12-slim-bookworm AS base

# Add Debian Bullseye repository for Java 11 (not available in Bookworm)
RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list.d/bullseye.list && \
    echo "Package: *\nPin: release n=bullseye\nPin-Priority: 100" > /etc/apt/preferences.d/bullseye

# Install Java runtime (required for PySpark/Hail) and procps for process management
RUN apt-get update && \
    apt-get install --no-install-recommends -y openjdk-11-jdk-headless/bullseye procps make rsync && \
    # Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for better security
RUN groupadd -g 1001 ot && \
    useradd -m -s /bin/bash -u 1001 -g 1001 ot && \
    mkdir -p /notebooks && \
    chown ot:ot /notebooks

# Detect architecture and set JAVA_HOME
ARG TARGETARCH
RUN JAVA_DIR=$(ls -d /usr/lib/jvm/java-11-openjdk-* 2>/dev/null | head -1) && \
    ln -sf ${JAVA_DIR} /usr/lib/jvm/java-11-current

ENV JAVA_HOME=/usr/lib/jvm/java-11-current
ENV PATH="${JAVA_HOME}/bin:${PATH}"

FROM base AS builder

WORKDIR /notebooks

# Add UV binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
COPY . /notebooks
RUN chown -R ot:ot /notebooks
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-dev

# Place executables in the environment at the front of the path
ENV PATH="/notebooks/.venv/bin:$PATH"

# Stage 2: Test stage - For running notebook tests
FROM builder AS test

# Install test dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --all-extras

# Set working directory
WORKDIR /notebooks

# Run tests by default
CMD ["uv", "run", "pytest", "tests/", "-v", "-m", "notebook"]

# Stage 3: Production stage - For running Jupyter Lab
FROM builder AS production

# Set working directory
WORKDIR /notebooks

# Expose Jupyter Lab port
EXPOSE 8888

# Expose Spark UI ports
EXPOSE 4040 4041 4042 4043

# Default command
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]