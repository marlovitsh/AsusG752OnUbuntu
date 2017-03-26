#!/usr/bin/env bash

### get the full version string for the current distro, eg "16.04.2"
_getDistributorVersion() {
	version=$(lsb_release -a 2>/dev/null | grep "Release:" -i)
	# extract second word which is the result
	array=( $version ) # do not use quotes in order to allow word expansion
	version=${array[1]}
    printf "%s" $version
}

### get the main version string for the current distro, eg "16" from "16.04.2"
_getDistributorVersionMain() {
	version=$(_getDistributorVersion)
	IFS='.' read -r -a arr <<< "$version"
	result=${arr[0]}
    printf "%s" $result
}

### get the sub version string for the current distro, eg "04" from "16.04.2"
_getDistributorVersionSub() {
	version=$(_getDistributorVersion)
	IFS='.' read -r -a arr <<< "$version"
	result=${arr[1]}
    printf "%s" $result
}

### get the update version string for the current distro, eg "12" from "16.04.2"
_getDistributorVersionUpdate() {
	version=$(_getDistributorVersion)
	IFS='.' read -r -a arr <<< "$version"
	result=${arr[2]}
    printf "%s" $result
}

### get the distribution id for the current distro, eg "Ubuntu" for Ubuntu, Kubuntu, Lubuntu, Wasta, etc
### this does NOT return the "subversions" Lubuntu, Kubuntu, etc!
_getDistributorId() {
	id=$(lsb_release -a 2>/dev/null | grep "Distributor ID:" -i)
	# extract third word which is the result
	array=( $id ) # do not use quotes in order to allow word expansion
	id=${array[2]}
    printf "%s" $id
}

### test if the current distro is an ubuntu version, eg Ubuntu, Kubuntu, Lubuntu, Wasta, etc
_isUbuntuVariant(){
	distributorId=$(_getDistributorId)
	distributorId=${distributorId,,} # lowercasing
	if [[ "$distributorId" == "ubuntu" ]]; then
    	printf "%i" 1
	else
    	printf "%i" 0
	fi
}

