# macOS One-Click Distraction Blocker 🚫

[![macOS](https://img.shields.io/badge/macOS-Supported-black.svg?logo=apple)]()
[![Shell](https://img.shields.io/badge/Shell-zsh-green.svg)]()

A lightweight, zero-dependency macOS utility for instantly toggling access to distracting websites such as LinkedIn, YouTube, or social media. It manages the system `/etc/hosts` file and flushes the local DNS cache to make the change take effect immediately.

This setup includes passwordless execution and a silent background launcher, so you can focus without terminal prompts or extra friction.

---

## ⚙️ How it works

1. **State detection:** Checks `/etc/hosts` for the targeted domains.
2. **Dynamic routing:**
   - If the domains are currently blocked, it removes the entries and restores access.
   - If they are accessible, it sends them to `127.0.0.1` so the browser cannot reach them.
3. **DNS invalidation:** Flushes the macOS DNS cache and reloads the service so the browser reflects the change immediately without rebooting.

---

## 🛠️ Installation and setup

### 1. Create the core script

Create the utility script in a secure system location:

```bash
sudo nano /usr/local/bin/toggle_distractions
```

Paste the following script and update the `DOMAINS` array with the websites you want to block:

```bash
#!/bin/zsh

# Configuration: Target domains
DOMAINS=(
  "linkedin.com"
  "www.linkedin.com"
  "youtube.com"
  "www.youtube.com"
)

HOSTS_FILE="/etc/hosts"

# Check whether the domains are currently present in /etc/hosts
if grep -q "${DOMAINS[1]}" "$HOSTS_FILE"; then
  for DOMAIN in "${DOMAINS[@]}"; do
    sudo sed -i '' "/$DOMAIN/d" "$HOSTS_FILE"
  done
else
  for DOMAIN in "${DOMAINS[@]}"; do
    echo "127.0.0.1 $DOMAIN" | sudo tee -a "$HOSTS_FILE" > /dev/null
  done
fi
```

### 2. Flush the local DNS cache

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

### 3. Make the script executable and secure it

```bash
sudo chmod +x /usr/local/bin/toggle_distractions
sudo chown root:wheel /usr/local/bin/toggle_distractions
```

---

### 4. Configure passwordless execution

To run the toggle without entering an admin password every time, create a dedicated sudoers rule:

```bash
echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/local/bin/toggle_distractions" | sudo tee /etc/sudoers.d/toggle_distractions
sudo chmod 0440 /etc/sudoers.d/toggle_distractions
```

---

### 5. Create the silent app launcher

Use Automator to create a native macOS app so it runs without opening a terminal window:

1. Open Automator.
2. Choose **New Document** > **Application**.
3. Add **Run Shell Script**.
4. Replace the script text with:

```bash
sudo /usr/local/bin/toggle_distractions
```

5. Save the file as `Toggle Distractions.app` to your Applications folder or Desktop.

---

## 🚀 Usage

1. Double-click the `Toggle Distractions.app` launcher.
2. Open a blocked site in your browser to confirm it is unreachable.
3. Double-click the app again to restore access.
4. Refresh the page and the site should load normally again.

> Typical browser results when a site is blocked are `ERR_CONNECTION_REFUSED` or “This site can’t be reached.”