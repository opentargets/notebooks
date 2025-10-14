# Stage 1: Build stage - Used to prepare dependencies and package the application
FROM python:3.12-slim-bookworm AS base

# Install Java runtime (required for PySpark/Hail) and procps for process management
RUN echo "deb http://deb.debian.org/debian oldstable main" >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get install --no-install-recommends -y openjdk-11-jdk-headless procps make rsync && \
    # Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for better security
RUN groupadd -g 1001 ot && \
    useradd -m -s /bin/bash -u 1001 -g 1001 ot && \
    mkdir -p /notebooks && \
    chown ot:ot /notebooks

# Set up JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
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

# Set environment variables for PySpark and Hail locations
# ENV SPARK_HOME=/notebooks/.venv/lib/python3.12/site-packages/pyspark
# ENV HAIL_DIR=/notebooks/.venv/lib/python3.12/site-packages/hail

# # Copy notebooks directory contents into the image
# COPY --chown=ot:ot notebooks/ ./notebooks/

# # Copy other project files
# COPY --chown=ot:ot . .

# # Switch to non-root user
# USER ot

# Expose Jupyter Lab port
EXPOSE 8888

# Expose Spark UI ports
EXPOSE 4040 4041 4042 4043

# Default command
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]