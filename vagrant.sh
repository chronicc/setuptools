#!/bin/bash

set -e

PKG=vagrant
PKG_URL=https://releases.hashicorp.com/vagrant
PKG_VERSION=$(curl -sSL ${PKG_URL}/ | grep -oE "${PKG}_[0-9\.]*" | head -n 1 | cut -d"_" -f2)
PKG_FILE=vagrant_${PKG_VERSION}_x86_64.deb
PKG_INSTALLED=$(dpkg -l vagrant 2>/dev/null | grep vagrant | awk '{print $3}' | cut -d":" -f2)


if [[ ! "${PKG_INSTALLED}" == "${PKG_VERSION}" ]]
then
    echo -e ""
    echo -e "Installing latest ${PKG} version ${PKG_VERSION}."
    echo -e "For automatisation use -y as first argument."
    echo -e "ctrl^c to abort"
    if [[ "${1}" != "-y" ]]
    then
        read
    fi
    sudo -v
    mkdir -p /tmp/${PKG} && cd $_
    if [[ ! -r ${PKG_FILE} ]]
    then
        CURL_TARGET="${PKG_URL}/${PKG_VERSION}/${PKG_FILE}"
        echo "Downloading ${CURL_TARGET} ..."
        curl -L ${CURL_TARGET} -O ${PKG_FILE}
    fi
    sudo dpkg -i ${PKG_FILE}
    sudo apt-get install -f -y
    pip install -U python-vagrant
fi

echo -e ""
vagrant version
if [[ -z $(vagrant version) ]]
then
    exit 1
fi

