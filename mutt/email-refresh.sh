#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Install required packages
install_packages() {
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y neomutt isync offlineimap
    elif command -v yum &> /dev/null; then
        yum install -y neomutt isync offlineimap
    elif command -v pacman &> /dev/null; then
        pacman -Sy neomutt isync offlineimap
    else
        echo "Unsupported package manager"
        exit 1
    fi
}

# Create systemd service for mbsync
setup_mbsync_service() {
    cat > /etc/systemd/system/mailsync.service << 'EOL'
[Unit]
Description=Mailbox synchronization service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/mbsync -a
User=%i

[Install]
WantedBy=default.target
EOL

    cat > /etc/systemd/system/mailsync.timer << 'EOL'
[Unit]
Description=Mailbox synchronization timer

[Timer]
OnBootSec=2m
OnUnitActiveSec=5m
Unit=mailsync@%i.service

[Install]
WantedBy=timers.target
EOL
}

# Configure neomutt
setup_neomutt() {
    local user_home="/home/$SUDO_USER"
    mkdir -p "$user_home/.config/neomutt"
    
    # Add sync macro to neomuttrc
    cat >> "$user_home/.config/neomutt/neomuttrc" << 'EOL'
# IMAP settings
set imap_idle = yes
set timeout = 30

# Sync macro
macro index,pager $ "<shell-escape>mbsync -a<enter>" "run mbsync"
EOL

    chown -R "$SUDO_USER:$SUDO_USER" "$user_home/.config/neomutt"
}

# Setup offline sync
setup_offline_sync() {
    local user_home="/home/$SUDO_USER"
    
    # Create mbsync config
    cat > "$user_home/.mbsyncrc" << 'EOL'
# Add your IMAP account configuration here
# Example:
# IMAPStore example-remote
# Host imap.example.com
# User your-email@example.com
# Pass your-password
# SSLType IMAPS
EOL

    chown "$SUDO_USER:$SUDO_USER" "$user_home/.mbsyncrc"
    chmod 600 "$user_home/.mbsyncrc"
}

# Main execution
echo "Installing required packages..."
install_packages

echo "Setting up systemd services..."
setup_mbsync_service

echo "Configuring neomutt..."
setup_neomutt

echo "Setting up offline sync..."
setup_offline_sync

echo "Enabling and starting services..."
systemctl daemon-reload
systemctl enable "mailsync@$SUDO_USER.timer"
systemctl start "mailsync@$SUDO_USER.timer"

echo "Setup complete!"
echo "Please edit ~/.mbsyncrc to add your email account details"