#! /bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="${dir}"

misc_cmds=( "git" "openssl" "docker" "gpg" "gpgv" "qemu-system-x86_64" "id" \
            "wget" "dd" "losetup" "sfdisk" "partx" "partprobe" "parted" "mkfs" "mount" "umount" "shasum" "ssh" "scp" "sudo" \
            "bison" "flex" "pkg-config" "bc" "date" "jq" "realpath" "make" "mkfs.vfat")

misc_libs=( "libelf" "libcrypto" )


function checkMISC {
    needs_exit=false

    for i in "${misc_cmds[@]}"
    do
        PATH=/sbin:/usr/sbin:$PATH command -v "$i" >/dev/null 2>&1 || {
            echo >&2 "$i required";
            needs_exit=true
        }
    done

    for i in "${misc_libs[@]}"
    do
    pkg-config "$i" >/dev/null 2>&1 || {
        echo >&2 "$i required";
        needs_exit=true
    }
    done

    if [[ ! -f "/lib/ld-linux.so.2" ]]
    then
        echo "i386 libc required";
        needs_exit=true
    fi

    if $needs_exit ; then
        echo 'Please install all missing dependencies!';
        exit 1;
    fi

    echo "Miscellaneous tools and dependencies OK"
}

function checkGCC {
   maxver="8"

   command -v gcc >/dev/null 2>&1 || {
      echo >&2 "GCC required";
      exit 1;
   }

   currentver="$(gcc -dumpversion | cut -d . -f 1)"

   if [ "$currentver" -gt "$maxver" ]; then
         echo "GCC version ${currentver} is not supported. Needs version ${maxver} or earlier."
	 echo "Hint: If you've got multiple versions of GCC installed, update-alternatives(1) might "
	 echo "help with configuring which one should be invoked when issuing the gcc command."
         exit 1
   else
       echo "GCC supported"
   fi
}

function checkGO {
   minver=("1" "11")

   command -v go >/dev/null 2>&1 || {
      echo >&2 "GO required";
      exit 1;
   }

   ver=$(go version | cut -d ' ' -f 3 | sed 's/go//')
   majorver="$(echo $ver | cut -d . -f 1)"
   minorver="$(echo $ver | cut -d . -f 2)"

   if [ "$majorver" -le "${minver[0]}" ] && [ "$minorver" -lt "${minver[1]}" ]; then
         echo "GO version ${majorver}.${minorver} is not supported. Needs version ${minver[0]}.${minver[1]} or later."
         exit 1
   else
       echo "GO supported"
   fi

   echo "$PATH"|grep -q "$(go env GOPATH)/bin" || { echo "$(go env GOPATH)/bin must be added to PATH"; exit 1; }
}

function checkDebootstrap {
    if findmnt -T "${root}" | grep -cq "nodev"; then
        echo "The directory ${root} is mounted with the nodev option but debootstrap needs mknod to work."
        exit 1
    fi
    echo "Filesystem for debootstrap OK"
}

