#!/bin/bash

OS_CODENAME=$(cat /etc/*-release | grep -i codename | head -n1 | cut -d"=" -f2)
PKG=virtualbox
PKG_URL=http://download.virtualbox.org/virtualbox
PKG_LATEST=$(curl ${PKG_URL} 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | sort -n | tail -n1)
PKG_FILE=$(curl -sSL ${PKG_URL}/${PKG_LATEST} | sed -e 's/<[^>]*>//g' | grep -oiE "${PKG}.*${PKG_LATEST}.*${OS_CODENAME}_amd64.deb")
PKG_INSTALLED=$(vboxmanage -v 2>/dev/null)

if [[ ! "${PKG_INSTALLED}" =~ "${PKG_LATEST}" ]]; then
    echo -e ""
    echo -e "Installing latest ${PKG} version ${PKG_LATEST}."
    echo -e "For automatisation use -y as first argument."
    echo -e "ctrl^c to abort"
    if [[ "${1}" != "-y" ]]; then
        read
    fi
    mkdir -p /tmp/${PKG} && cd $_
    if [[ ! -r ${PKG_FILE} ]]; then
        wget ${PKG_URL}/${PKG_LATEST}/${PKG_FILE}
    fi
    sudo dpkg -i ${PKG_FILE}
    sudo apt-get install -f -y
fi

echo -e ""
echo "Installed version: $(vboxmanage -v)"

