#!/bin/bash

# install ytt
wget -O /usr/local/bin/ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.34.0/ytt-darwin-amd64
chmod +x /usr/local/bin/ytt

# print out ytt version
ytt version

# install imgpkg
wget -O /usr/local/bin/imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v0.9.0/imgpkg-darwin-amd64
chmod +x /usr/local/bin/imgpkg

# imgpkg version
imgpkg version
