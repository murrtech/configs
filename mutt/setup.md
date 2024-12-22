# Setting Up Mutt-Wizard on Arch Linux

## Initial Installation

1. Install required packages:
```bash
yay -S mutt-wizard isync msmtp pass abook notmuch
```

## GPG and Pass Setup

1. Generate GPG key:
```bash
gpg --full-generate-key
```
   - Choose `(1) RSA and RSA`
   - Use 4096 bits for key size
   - Choose expiration (0 for no expiration)
   - Enter your details:
     - Real name
     - Email address
     - Optional comment

2. Initialize pass with your email:
```bash
pass init your.email@gmail.com
```

## Gmail Preparation

1. Enable 2-Factor Authentication:
   - Go to Google Account → Security
   - Enable 2-Step Verification if not already enabled

2. Generate App Password:
   - Go to Google Account → Security → App passwords
   - Select "Mail" and "Other" (name it "mutt")
   - Save the 16-character password

3. Enable IMAP:
   - Go to Gmail settings → See all settings
   - Go to "Forwarding and POP/IMAP"
   - Enable IMAP

## Setting Up Mutt-Wizard

1. Create mail directories:
```bash
mkdir -p ~/.local/share/mail/your.email@gmail.com/INBOX
chmod 700 ~/.local/share/mail
chmod 700 -R ~/.local/share/mail/your.email@gmail.com
```

2. Add Gmail account:
```bash
mw -a your.email@gmail.com
```
   - Choose "Gmail" when prompted
   - Enter the App Password (not regular Gmail password)

3. Set as default account:
```bash
mw -D your.email@gmail.com
```

## Configure Mail Sync

1. Edit mbsync config:
```bash
nano ~/.mbsyncrc
```

2. Use this configuration:
```
IMAPStore your.email@gmail.com-remote
Host imap.gmail.com
Port 993
User your.email@gmail.com
PassCmd "pass your.email@gmail.com"
AuthMechs LOGIN
TLSType IMAPS
SystemCertificates yes

MaildirStore your.email@gmail.com-local
Subfolders Verbatim
Path /home/username/.local/share/mail/your.email@gmail.com/
Inbox /home/username/.local/share/mail/your.email@gmail.com/INBOX

Channel your.email@gmail.com
Expunge Both
Far :your.email@gmail.com-remote:
Near :your.email@gmail.com-local:
Patterns * !"[Gmail]/All Mail"
Create Both
SyncState *
MaxMessages 1000
MaxAge 30
ExpireUnread yes
```

3. Sync mail:
```bash
mbsync -a
```

## Using Neomutt

1. Open neomutt:
```bash
neomutt
```

2. Basic navigation:
   - `j` or `↓` - move down
   - `k` or `↑` - move up
   - `Enter` - open selected email
   - `q` - go back/quit current view
   - `m` - compose new mail
   - `r` - reply
   - `R` - reply all
   - `d` - mark for deletion
   - `$` - sync mailbox
   - `s` - save/move email
   - `/` - search
   - `l` - limit view (filter)

3. Folder navigation:
   - `c` - change folder
   - `y` - change mailbox
   - `gi` - go to inbox
   - `ga` - go to all mail

## Troubleshooting

1. If no emails sync:
   - Verify IMAP is enabled in Gmail
   - Confirm you're using the App Password
   - Check mbsync logs: `mbsync -V your.email@gmail.com`

2. If certificate errors occur:
   - Verify `SystemCertificates yes` is set
   - Ensure `TLSType IMAPS` is used instead of `SSLType`

3. If maildir errors occur:
   - Verify mail directories exist
   - Check permissions are set to 700
   - Ensure paths in .mbsyncrc are correct