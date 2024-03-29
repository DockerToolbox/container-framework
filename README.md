<p align="center">
    <a href="https://github.com/DockerToolbox/">
        <img src="https://cdn.wolfsoftware.com/assets/images/github/organisations/dockertoolbox/black-and-white-circle-256.png" alt="DockerToolbox logo" />
    </a>
    <br />
    <a href="https://github.com/DockerToolbox/container-framework/actions/workflows/cicd-pipeline.yml">
        <img src="https://img.shields.io/github/workflow/status/DockerToolbox/container-framework/CICD%20Pipeline/master?style=for-the-badge" alt="Github Build Status">
    </a>
    <a href="https://github.com/DockerToolbox/container-framework/releases/latest">
        <img src="https://img.shields.io/github/v/release/DockerToolbox/container-framework?color=blue&label=Latest%20Release&style=for-the-badge" alt="Release">
    </a>
    <a href="https://github.com/DockerToolbox/container-framework/releases/latest">
        <img src="https://img.shields.io/github/commits-since/DockerToolbox/container-framework/latest.svg?color=blue&style=for-the-badge" alt="Commits since release">
    </a>
    <br />
    <a href=".github/CODE_OF_CONDUCT.md">
        <img src="https://img.shields.io/badge/Code%20of%20Conduct-blue?style=for-the-badge" />
    </a>
    <a href=".github/CONTRIBUTING.md">
        <img src="https://img.shields.io/badge/Contributing-blue?style=for-the-badge" />
    </a>
    <a href=".github/SECURITY.md">
        <img src="https://img.shields.io/badge/Report%20Security%20Concern-blue?style=for-the-badge" />
    </a>
    <a href="https://github.com/DockerToolbox/container-framework/issues">
        <img src="https://img.shields.io/badge/Get%20Support-blue?style=for-the-badge" />
    </a>
    <br />
    <a href="https://wolfsoftware.com/">
        <img src="https://img.shields.io/badge/Created%20by%20Wolf%20Software-blue?style=for-the-badge" />
    </a>
</p>

## Overview

This is a comprehensive container framework for generating multiple docker containers with the same configuration. It can be used to create containers for multiple versions of the same operating system or multiple operating systems with minimal effort.

It uses a [core](Scripts/core.sh) controller script along with a [main template](Templates/Dockerfile.tpl), a [master config](Config/config.cfg) file and a [packages](Config/packages.cfg) config file for automatically identifying the correct versions for packages to be installed when generating the required Dockerfiles.

It will combine all of the above configuration to generate the required Dockerfiles and allow you to build them locally as well as publish them to both `Docker Hub` and the `Github Container Registry (GHCR)`. The repository also contains all of the [workflows](.github/workflows/) that you need to build and publish the containers automatically via Github Actions.

## Supported Operating Systems

The framework attempts to support as many operating system distributions and versions as possible, but with the caveat that it will only use `supported` versions of operating systems. Versions which have become `end of life (EOL)` by the original vendor will get removed shortly after they go `EOL`. It is however very simple to add additional versions or flavours if desired so if you have a specific need for an EOL'd version of an operating system is required little effort to reinstate it.

### Currently Supported Operating Systems

| Operating System               | Official Base Image                                 | Our Tags                |
| ------------------------------ | --------------------------------------------------- | ----------------------- |
| AlmaLinux 8                    | [Base Image](https://hub.docker.com/_/almalinux)    | 8 & latest              |
| AlmaLinux 8 Minimal            | [Base Image](https://hub.docker.com/_/almalinux)    | 8-minimal               |
| AlmaLinux 9                    | [Base Image](https://hub.docker.com/_/almalinux)    | 9                       |
| AlmaLinux 9 Minimal            | [Base Image](https://hub.docker.com/_/almalinux)    | 9-minimal               |
| Alpine 3.13                    | [Base Image](https://hub.docker.com/_/alpine)       | 3.13                    |
| Alpine 3.14                    | [Base Image](https://hub.docker.com/_/alpine)       | 3.14                    |
| Alpine 3.15                    | [Base Image](https://hub.docker.com/_/alpine)       | 3.15                    |
| Alpine 3.16                    | [Base Image](https://hub.docker.com/_/alpine)       | 3.16 & latest           |
| Amazon Linux 1                 | [Base Image](https://hub.do\cker.com/_/amazonlinux) | 1                       |
| Amazon Linux 2                 | [Base Image](https://hub.do\cker.com/_/amazonlinux) | 2 & latest              |
| Arch Linux                     | [Base Image](https://hub.docker.com/_/archlinux)    | base & latest           |
| Centos 7                       | [Base Image](https://hub.docker.com/_/centos)       | 7 & latest              |
| Debian 10 (Buster)             | [Base Image](https://hub.docker.com/_/debian)       | 10 & buster             |
| Debian 10 (Buster) Slim        | [Base Image](https://hub.docker.com/_/debian)       | 10-slim & buster-slim   |
| Debian 11 (Bullseye)           | [Base Image](https://hub.docker.com/_/debian)       | 11, bullseye & latest   |
| Debian 11 (Bullseye) Slim      | [Base Image](https://hub.docker.com/_/debian)       | 11-slim & bullseye-slim |
| Debian 12 (Bookworm)           | [Base Image](https://hub.docker.com/_/debian)       | 12 & bookworm           |
| Debian 12 (Bookwork) Slim      | [Base Image](https://hub.docker.com/_/debian)       | 12-slim & bookworm-slim |
| Oracle Linux 7                 | [Base Image](https://hub.docker.com/_/oraclelinux)  | 7                       |
| Oracle Linux 7 Slim            | [Base Image](https://hub.docker.com/_/oraclelinux)  | 7-slim                  |
| Oracle Linux 8                 | [Base Image](https://hub.docker.com/_/oraclelinux)  | 8                       |
| Oracle Linux 8 Slim            | [Base Image](https://hub.docker.com/_/oraclelinux)  | 8-slim                  |
| Oracle Linux 9                 | [Base Image](https://hub.docker.com/_/oraclelinux)  | 9                       |
| Oracle Linux 9 Slim            | [Base Image](https://hub.docker.com/_/oraclelinux)  | 9-slim                  |
| Photon 2.0                     | [Base Image](https://hub.docker.com/_/photon)       | 2.0                     |
| Photon 3.0                     | [Base Image](https://hub.docker.com/_/photon)       | 3.0                     |
| Photon 4.0                     | [Base Image](https://hub.docker.com/_/photon)       | 4.0 & latest            |
| Rocky Linux 8                  | [Base Image](https://hub.docker.com/_/rockylinux)   | 8                       |
| Rocky Linux 8-minimal          | [Base Image](https://hub.docker.com/_/rockylinux)   | 8-minimal               |
| Rocky Linux 9                  | [Base Image](https://hub.docker.com/_/rockylinux)   | 9                       |
| Rocky Linux 9-minimal          | [Base Image](https://hub.docker.com/_/rockylinux)   | 9-minimal               |
| Scientific Linux 7             | [Base Image](https://hub.docker.com/_/sl)           | 7 & latest              |
| Ubuntu 14.04 (Trusty Tahr)     | [Base Image](https://hub.docker.com/_/ubuntu)       | 14.04 & trusty          |
| Ubuntu 16.04 (Xenial Xerus)    | [Base Image](https://hub.docker.com/_/ubuntu)       | 16.04 & xenial          |
| Ubuntu 18.04 (Bionic Beaver)   | [Base Image](https://hub.docker.com/_/ubuntu)       | 18.04 & bionic          |
| Ubuntu 20.04 (Focal Fossa)     | [Base Image](https://hub.docker.com/_/ubuntu)       | 20.04 & focal           |
| Ubuntu 22.04 (Jammy Jellyfish) | [Base Image](https://hub.docker.com/_/ubuntu)       | 22.04, jammy & latest   |

## Naming convention

We use a generic programmatically derived name for each container to ensure consistency and uniqueness for all containers.

### Local containers

```
<container prefix>-<os>-<version> e.g. container-framework-debian-10
```

### Published containers

```
<docker hub org>/<container prefix>-<os>:<version> e.g. wolfsoftwareltd/container-framework-debian:10

or

ghrc.io/<github org>/<container prefix>-<os>:<version> e.g. ghcr.io/dockertoolbox/container-framework-debian:10
```

### How names are calculated

The container names are dynamically generated based on the directory tree. All of the files are situated below the Dockerfiles directory (see below). The next level is the operating system name and the final level is the operating system version. This is used internally by the container framework to known which docker container to pull and use as the base and the target OS/version for the built container. There are other files and directories within the tree but not shown on the diagram below. The main other folder is `Templates` which is a sub folder of each OS version folder and this contains symlinks to the relevant template files (more on that later).

```
Dockerfiles
├── almalinux
│   ├── 8
│   ├── 8-minimal
│   ├── 9
│   └── 9-minimal
├── alpine
│   ├── 3.13
│   ├── 3.14
│   ├── 3.15
│   └── 3.16
├── amazonlinux
│   ├── 1
│   └── 2
├── archlinux
│   └── base
├── centos
│   └── 7
├── debian
│   ├── 10
│   ├── 10-slim
│   ├── 11
│   ├── 11-slim
│   ├── 12
│   └── 12-slim
├── oraclelinux
│   ├── 7
│   ├── 7-slim
│   ├── 8
│   ├── 8-slim
│   ├── 9
│   └── 9-slim
├── photon
│   ├── 2.0
│   ├── 3.0
│   └── 4.0
├── rockylinux
│   ├── 8
│   ├── 8-minimal
│   ├── 9
│   └── 9-minimal
├── sl
│   └── 7
└── ubuntu
    ├── 14.04
    ├── 16.04
    ├── 18.04
    ├── 20.04
    └── 22.04
```

## Development

If you want to use this container framework to develop your own Docker containers there are 4 core files that you will to update.

### config.cfg

The [configuration file](Config/config.cfg) handles various configuration components that are required either during the generate, build or publish phase. The first half of the file manages the generic container configuration. E.g. which Docker Hub org to publish under, what GitHub org to publish under, what github repo the containers are in etc.

```
# Required for generate & build phase
CONTAINER_PREFIX=''                         # Prefix to use when creating / publishing the containers

# Required for publish phase
DOCKER_HUB_ORG=''                           # Dockerhub org to publish under
GHCR_ORGNAME=''                             # Github org to publish packages under

# Required for Single OS usage only
SINGLE_OS=false
SINGLE_OS_NAME=''
NO_OS_NAME_IN_CONTAINER=false
```

The second half only needs to be touched if you are planning to create containers for a single OS and remove the OS name from the directory tree. An example of this is our [alpine-bash](https://github.com/DockerToolbox/alpine-bash) containers. As you can see below the directory tree under Dockerfiles only contains the OS version and the operating system name is configured in the config.cfg.

```
Dockerfiles
  ├── 3.13
  ├── 3.14
  ├── 3.15
  └── 3.16
```

### packages.cfg

The [packages file](Config/packages.cfg) lists all of the packages that you want/need to install during the creation of the containers. This is used during the generate phase to select the correctly versioned package for the container you are building. Simply list the package names and let the generate stage do the rest. The generate phase makes use of our [version helper](https://github.com/DockerToolbox/version-helper) code to correctly identify the specific version of the package in relation to the specific version of the operating system within the container. This might be considered overkill as you could simply install based on the package name but we wanted to go one step further and installed the latest specific versioned package.

As per the documentation from the [version helper](https://github.com/DockerToolbox/version-helper) repository, configuration can done in one of two ways:

#### Package Manager Based

This is the default and the code attempts to work out which package manager is available for a given operating system and then used the correct list of packages.

```
APK_PACKAGES=                   # Alpine Packages
APK_VIRTUAL_PACKAGE=            # Alpine Virtual Packages (These are not versioned) 
APT_PACKAGES=                   # Debian / Ubuntu Packages
PACMAN_PACKAGES=                # Arch Linux
TDNF_PACKAGES=                  # Photon Packages
YUM_PACKAGES=                   # AlmaLinux / Amazon Linux / Centos / Oracle Linux / Rocky Linux / Scientific Linux
YUM_GROUPS=                     # Yum Groups
```
> Oracle Linux 8 slim comes with `microdnf` instead of `yum` but we simply install yum using `microdnf` and then carry on as normal.

#### Operating System Based

```
DISCOVER_BY=OS                  # Tell the version-grabber to use Operating System ID instead of package manager
ALMA_PACKAGES=                  # AlmaLinux Packages
ALPINE_PACKAGES=                # Alpine Packages
ALPINE_VIRTUAL_PACKAGES=        # Alpine Virtual Packages (These are not versioned)
AMAZON_PACKAGES=                # Amazon Linux Packages
ARCH_PACKAGES=                  # Arch Linux Packages
CENTOS_PACKAGES=                # Centos Packages
DEBIAN_PACKAGES=                # Debian Packages
ORACLE_PACKAGES=                # Oracle Linux Packages
PHOTON_PACKAGES=                # Photon Linux Packages
ROCKY_PACKAGES=                 # Rocky Linux Packages
SCIENTIFIC_PACKAGES=            # Scientific Linux Packages
UBUNTU_PACKAGES=                # Ubuntu Packages
```

### labels.cfg

The [labels file](Config/labels.cfg) is used to define what static labels should be added to the Dockerfile. You can add more labels if you wish or remove any that you do not feel are required. If you want to remove all of the static labels then you can simple remove the [labels file](Config/labels.cfg). However we recommend that as a `minimum` you retain at least the `license` and `created` labels.

```
LABEL org.opencontainers.image.authors=''
LABEL org.opencontainers.image.vendor=''
LABEL org.opencontainers.image.licenses=''
LABEL org.opencontainers.image.title=''
LABEL org.opencontainers.image.description=''
LABEL org.opencontainers.image.created="$(date --rfc-3339=seconds --utc)"
```

In addition to the above static labels we also add the following `dynamic` labels

```
LABEL org.opencontainers.image.source=${GIT_URL}
LABEL org.opencontainers.image.documentation=${GIT_URL}
```
> The `${GIT_URL}` is automatically calculated by processing the git origin `git config --get remote.origin.url`

### install.tpl

The [install template](Templates/install.tpl) is the file that contains the commands that are generic to all the containers being build and contains the commands that install and configure the items that exist in the container. This is symlinked from each container directory.

### Dockerfile.tpl

The [Dockerfile Template](Templates/Dockerfile.tpl) is the main template file which is used in conjunction with the other config files mentioned above to generate the actual Dockerfile used to build the containers. The file is a very simple template.

```
FROM ${CONTAINER_OS_NAME}:${CONTAINER_OS_VERSION_ALT}

${LABELS}

RUN \
${PACKAGES}
${INSTALL}
${CLEANUP}

WORKDIR /root

ENTRYPOINT ["/bin/bash"]
```

The same file is used for all the containers and the valuables as substituted when the container is generated.

### Cleanup

There is a cleanup symlink in each container directory which points to the correct cleanup script, this removes any packages that are no longer required and also removes packages caches and other general good practice cleanup operations.

| File                        | Purpose                                                                                   |
| --------------------------- | ----------------------------------------------------------------------------------------- |
| apk-cleanup.tpl             | Cleanup for Alpine based containers.                                                      |
| apt-cleanup.tpl             | Cleanup for Debian / Ubuntu based containers.                                             |
| microdns-cleanup.tpl        | Cleanup for Oracle Linux slim based containers.                                           |
| pacman-cleanup.tpl          | Cleanup for Arch Linux based containers.                                                  |
| tdnf-cleanup.tpl            | Cleanup for Photon Linux based containers.                                                |
| yum-cleanup-with-leaves.tpl | Cleanup for Amazon Linux, Centos 7 and Scientific Linux based containers.                 |
| yum-cleanup.tpl             | Cleanup for AlmaLinux, Oracle Linux (excluding 8-slim) and Rocky Linux based containers.  |

### Helper Script

We do supply Dockerfiles within the repository, these Dockerfiles are dynamically generated using a helper script which is also supplied. The helper script is called `manage-all.sh` and can be from any level of the directory tree and is recursive.

> If you are in the top level directory you will need to use `manage.sh` instead of `manage-all.sh`

#### Command Line Options

```shell
    -h | --help     : Print this screen
    -d | --debug    : Debug mode (set -x)
    -b | --build    : Build a container (Optional: -c or --clean)
    -g | --generate : Generate a Dockerfile
    -p | --publish  : Publish a container
    -G | --ghcr     : Publish to Github Container Registry
    -t | --tags     : Add additional tags
```

> These options are available at any level of the directory tree.

#### Generate Dockerfiles

```shell
./manage-all.sh --generate
```

#### Build Containers

```shell
./manage-all.sh --build [--clean]
```

#### Publish Containers

```shell
./manage-all.sh --publish [ --ghcr ]
```

#### Advanced Usage

It is possible to generate, build and publish all of the above containers at the same time.

```shell
./manage-all.sh --generate --build --clean --publish
```
