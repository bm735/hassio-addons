#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

#################
# NGINX SETTING #
#################
declare ingress_interface
declare ingress_port

ingress_port=$(bashio::addon.ingress_port)
ingress_interface=$(bashio::addon.ip_address)
ingress_entry=$(bashio::addon.ingress_entry)
sed -i "s/%%port%%/${ingress_port}/g" /etc/nginx/servers/ingress.conf
sed -i "s/%%interface%%/${ingress_interface}/g" /etc/nginx/servers/ingress.conf
sed -i "s|%%ingress_entry%%|${ingress_entry}|g" /etc/nginx/servers/ingress.conf

##################
# CONFIG SETTING #
##################

# Values
slug=sonarr
CONFIG_LOCATION=/config/addons_config/"$slug"/config.xml

if [ -f "$CONFIG_LOCATION" ]; then
  # Set UrlBase
  if ! bashio::config.true "ingress_disabled"; then
    bashio::log.info "Disabling ingress and enabling authentification"
    sed -i "/UrlBase/d" "$CONFIG_LOCATION"
    sed -i "/<Config>/a <UrlBase>$slug<\/UrlBase>" "$CONFIG_LOCATION"
    sed -i "/<AuthenticationMethod>external</AuthenticationMethod>/d" "$CONFIG_LOCATION"
  else
    bashio::log.info "Ingress is enabled, authentification will be disabled and should be managed through HA itself"
    # Disable local auth
    sed -i "/AuthenticationType/d" "$CONFIG_LOCATION"
    sed -i "2a <AuthenticationType>DisabledForLocalAddresses</AuthenticationType>" "$CONFIG_LOCATION"
    # Disable local auth
    sed -i "/AuthenticationMethod/d" "$CONFIG_LOCATION"
    sed -i "2a <AuthenticationMethod>external</AuthenticationMethod>" "$CONFIG_LOCATION"
  fi
fi
