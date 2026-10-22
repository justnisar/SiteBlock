#!/bin/zsh

# Toggle access to distracting websites by updating /etc/hosts.
DOMAINS=(
  "linkedin.com"
  "www.linkedin.com"
  "youtube.com"
  "www.youtube.com"
)

HOSTS_FILE="/etc/hosts"

# If the first target is present, the domains are currently blocked.
if grep -q "${DOMAINS[1]}" "$HOSTS_FILE"; then
  for DOMAIN in "${DOMAINS[@]}"; do
    sudo sed -i '' "/$DOMAIN/d" "$HOSTS_FILE"
  done
else
  for DOMAIN in "${DOMAINS[@]}"; do
    echo "127.0.0.1 $DOMAIN" | sudo tee -a "$HOSTS_FILE" > /dev/null
  done
fi

# Refresh the local DNS cache so the browser respects the change immediately.
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
