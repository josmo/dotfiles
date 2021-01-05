#!/usr/bin/env sh


DOMAINS=`cat $HOME/.local_config/vpn_domains`

setup_dns() {
  echo "setup vpn dns for $DOMAINS"
  if [ ! -d "/etc/resolver" ]; then
    sudo mkdir /etc/resolver
  fi
  for domain in $DOMAINS
  do
    sudo rm -f /etc/resolver/$domain
    for vpn_dns in $INTERNAL_IP4_DNS
    do
      echo "nameserver $vpn_dns" | sudo tee -a /etc/resolver/$domain
    done
  done

}
teardown_dns() {
  echo "teardown vpn dns for $DOMAINS"
  for domain in $DOMAINS
  do
    sudo rm -f /etc/resolver/$domain
  done

  if [ -d "/etc/resolver" ] && [ ! "$(ls -A /etc/resolver)" ]; then
    sudo rmdir  /etc/resolver
  fi
}

case "$reason" in
	pre-init)
		;;
	connect)
                setup_dns
		;;
	disconnect)
                teardown_dns
		;;
	attempt-reconnect)
		;;
	reconnect)
		;;
	*)
		echo "unknown reason '$reason'. Maybe vpnc-script is out of date" 1>&2
		exit 1
		;;
esac

echo "setup slice"
vpn-slice \
10.65.0.1/16
