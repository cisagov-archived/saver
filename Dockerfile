<<<<<<< HEAD
FROM python:3.12.1-alpine
=======
# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
FROM docker.io/library/python:3.13.2-alpine3.21 AS compile-stage

###
# Unprivileged user variables
###
ARG CISA_USER="cisa"
ENV CISA_HOME="/home/${CISA_USER}"
ENV VIRTUAL_ENV="${CISA_HOME}/.venv"

# Versions of the Python packages installed directly
ENV PYTHON_PIP_VERSION=25.0.1
ENV PYTHON_PIPENV_VERSION=2024.4.1
ENV PYTHON_SETUPTOOLS_VERSION=75.8.0
ENV PYTHON_WHEEL_VERSION=0.45.1

###
# Install the specified versions of pip, setuptools, and wheel into the system
# Python environment; install the specified version of pipenv into the system Python
# environment; set up a Python virtual environment (venv); and install the specified
# versions of pip, setuptools, and wheel into the venv.
#
# Note that we use the --no-cache-dir flag to avoid writing to a local
# cache.  This results in a smaller final image, at the cost of
# slightly longer install times.
###
RUN python3 -m pip install --no-cache-dir --upgrade \
        pip==${PYTHON_PIP_VERSION} \
        setuptools==${PYTHON_SETUPTOOLS_VERSION} \
        wheel==${PYTHON_WHEEL_VERSION} \
    && python3 -m pip install --no-cache-dir --upgrade \
        pipenv==${PYTHON_PIPENV_VERSION} \
    # Manually create the virtual environment
    && python3 -m venv ${VIRTUAL_ENV} \
    # Ensure the core Python packages are installed in the virtual environment
    && ${VIRTUAL_ENV}/bin/python3 -m pip install --no-cache-dir --upgrade \
        pip==${PYTHON_PIP_VERSION} \
        setuptools==${PYTHON_SETUPTOOLS_VERSION} \
        wheel==${PYTHON_WHEEL_VERSION}

###
# Check the Pipfile configuration and then install the Python dependencies into
# the virtual environment.
#
# Note that pipenv will install into a virtual environment if the VIRTUAL_ENV
# environment variable is set.
###
WORKDIR /tmp
COPY src/Pipfile src/Pipfile.lock ./
RUN pipenv check --verbose \
    && pipenv install --clear --deploy --extra-pip-args "--no-cache-dir" --verbose

# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
<<<<<<< HEAD
FROM docker.io/library/python:3.13.1-alpine3.20 AS build-stage
>>>>>>> 0d48ebd47a28a887868ea3093e675e95f3843561
=======
FROM docker.io/library/python:3.13.2-alpine3.21 AS build-stage
>>>>>>> e8ec18bb4cfbcdc26f704c489e98112d312d9bdb

###
# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
###
LABEL org.opencontainers.image.authors="vm-dev@gwe.cisa.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Unprivileged user setup variables
###
# TODO: Change this to 2048.  See cisagov/orchestrator#130 for more
# details.
ARG CISA_UID=421
ARG CISA_GID=${CISA_UID}
ARG CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/${CISA_USER}"
ENV VIRTUAL_ENV="${CISA_HOME}/.venv"

###
# Create unprivileged user
###
RUN addgroup --system --gid ${CISA_UID} ${CISA_GROUP} \
    && adduser --system --uid ${CISA_UID} --ingroup ${CISA_GROUP} ${CISA_USER}

###
# Copy in the Python virtual environment created in compile-stage, symlink the
# Python binary in the venv to the system-wide Python, and add the venv to the PATH.
#
<<<<<<< HEAD
# We need redis so we can use redis-cli to communicate with redis.  I
# also reinstall wget with openssl, since otherwise wget does not seem
# to know how to HTTPS.
#
# Note that we use apk --no-cache to avoid writing to a local cache.
# This results in a smaller final image, at the cost of slightly
# longer install times.
###
ENV DEPS \
    openssl \
    redis \
    wget
RUN apk --no-cache --quiet add ${DEPS}

###
# Make sure pip, setuptools, and wheel are the latest versions
#
# Note that we use pip3 --no-cache-dir to avoid writing to a local
# cache.  This results in a smaller final image, at the cost of
# slightly longer install times.
###
RUN pip3 install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel

###
# Install Python dependencies
###
RUN pip3 install --no-cache-dir --upgrade \
    https://github.com/cisagov/mongo-db-from-config/tarball/develop

###
# Put this just before we change users because the copy (and every
# step after it) will always be rerun by Docker, but we need to be
# root for the chown command.
###
COPY src/*.py src/*.sh ${CISA_HOME}
COPY src/include ${CISA_HOME}/include
RUN chown -R ${CISA_USER}:${CISA_GROUP} ${CISA_HOME}
=======
# Note that we symlink the Python binary in the venv to the system-wide Python so that
# any calls to `python3` will use our virtual environment. We are using short flags
# because the ln binary in Alpine Linux does not support long flags. The -f instructs
# ln to remove the existing file and the -s instructs ln to create a symbolic link.
###
COPY --from=compile-stage --chown=${CISA_USER}:${CISA_GROUP} ${VIRTUAL_ENV} ${VIRTUAL_ENV}
RUN ln -fs "$(command -v python3)" "${VIRTUAL_ENV}"/bin/python3
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"
>>>>>>> 0d48ebd47a28a887868ea3093e675e95f3843561

###
# Prepare to run
###
<<<<<<< HEAD
# TODO: Right now we need to be root at runtime in order to create
# files in ${CISA_HOME}/shared, but see cisagov/orchestrator#130.
# USER ${CISA_USER}:${CISA_GROUP}
WORKDIR ${CISA_HOME}
ENTRYPOINT ["./save_to_db.sh"]
=======
ENV ECHO_MESSAGE="Hello World from Dockerfile"
WORKDIR ${CISA_HOME}
USER ${CISA_USER}:${CISA_GROUP}
EXPOSE 8080/TCP
VOLUME ["/var/log"]
ENTRYPOINT ["example"]
CMD ["--log-level", "DEBUG", "8", "2"]
>>>>>>> 0d48ebd47a28a887868ea3093e675e95f3843561
