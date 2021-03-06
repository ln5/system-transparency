#!/bin/bash 

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

failed="\e[1;5;31mfailed\e[0m"

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "${dir}/../" && pwd)"

gopath="$(go env GOPATH)"
if [ -z "${gopath}" ]; then
    echo "GOPATH is not set!"
    echo "Please refer to https://golang.org/cmd/go/#hdr-GOPATH_environment_variable1"
    echo -e "installing stconfig tool $failed"; exit 1;
fi
uroot_src="${gopath}/src/github.com/u-root/u-root"
branch="stboot"

choose_branch=false
while getopts "bu" opt; do
  case $opt in
    b)
      choose_branch=true
      ;;
    u)
      echo "[INFO]: updating ${uroot_src}";
      GOPATH="${gopath}" go get github.com/u-root/u-root
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      exit 1
      ;;
  esac
done

echo "[INFO]: unsing GOPATH ${gopath}"
if [ ! -d "${uroot_src}" ]; then
    echo "u-root source code repository not found!"
    while true; do
       read -rp "Download u-root soure code now? (y/n)" yn
       case $yn in
          [Yy]* ) GOPATH=${gopath} go get github.com/u-root/u-root; break;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes or no.";;
       esac
    done 
else
    echo "[INFO]: using repository ${uroot_src}"
fi
cd "${uroot_src}"

if "${choose_branch}" ; then
    git branch
    read -rp "Enter branch: "  branch
fi

echo "[INFO]: switch to branch ${branch}"
git checkout --quiet "${branch}" || { echo -e "installing u-root $failed"; exit 1; }
git status
echo "[INFO]: install stconfig tool"
GOPATH="${gopath}" go install "${uroot_src}/tools/stconfig" || { echo -e "installing stconfig tool $failed"; exit 1; }
if [ ! -d "${root}/configs/" ]; then
    echo "[INFO]: make configuration direktory"
    mkdir  "${root}/configs/"
fi
echo "[INFO]: configuration directory is ${root}/configs"
