function fish_greeting
    # ASCII art and header
    set_color cyan
    echo '╔════════════════════════════════════════════════════════════════════════════╗'
    echo '║                        System Information                                  ║'
    echo '╚════════════════════════════════════════════════════════════════════════════╝'
    set_color normal

    # System info with better formatting
    set_color blue
    echo -n "├─ OS:           "
    set_color normal
    echo (uname -rs)
    
    set_color blue
    echo -n "├─ Kernel:       "
    set_color normal
    echo (uname -r)
    
    set_color blue
    echo -n "├─ Shell:        "
    set_color normal
    echo (fish --version)
    
    set_color blue
    echo -n "├─ Terminal:     "
    set_color normal
    echo $TERM
    
    set_color blue
    echo -n "├─ Uptime:       "
    set_color normal
    echo (uptime -p | sed 's/up //')

    # Memory section
    set_color blue
    echo "├─ Memory:"
    set_color normal
    echo "│  ├─ Total:    "(free -h | awk '/^Mem/ {print $2}')
    echo "│  ├─ Used:     "(free -h | awk '/^Mem/ {print $3}')
    echo "│  └─ Free:     "(free -h | awk '/^Mem/ {print $4}')
    
    # CPU section
    set_color blue
    echo "├─ CPU:"
    set_color normal
    echo "│  ├─ Load:     "(uptime | sed 's/.*load average: //')
    echo "│  └─ Cores:    "(nproc)

    # Storage section
    set_color blue
    echo "├─ Storage:"
    set_color normal
    echo "│  ├─ Total:    "(df -h / | awk 'NR==2 {print $2}')
    echo "│  ├─ Used:     "(df -h / | awk 'NR==2 {print $3}')
    echo "│  └─ Free:     "(df -h / | awk 'NR==2 {print $4}')

    # Network section
    set_color blue
    echo "├─ Network:"
    set_color normal
    echo "│  └─ IP:       "(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n1)
    

    # Git configuration with better formatting
    if command -v git > /dev/null
        set -l git_name (git config --global user.name)
        set -l git_email (git config --global user.email)
        if test -n "$git_name" -a -n "$git_email"
            set_color blue
            echo "└─ Git Config:"
            set_color normal
            echo "   ├─ User:     $git_name"
            echo "   └─ Email:    $git_email"
        end
    end
    
    echo # Empty line for spacing
    
    # Help tip with better formatting
    set_color yellow
    echo "Type 'help' for commands or 'fish_config' for configuration options"
    set_color cyan
    echo '════════════════════════════════════════════════════════════════════════════'
    set_color normal
end

cd ~/Documents/compass 2>/dev/null; or cd ~

if status is-interactive
    function fish_prompt
        # Get current directory and three parent levels
        set -l current_dir (basename $PWD)
        set -l parent_dir (basename (dirname $PWD))
        set -l grandparent_dir (basename (dirname (dirname $PWD)))
        set -l great_grandparent_dir (basename (dirname (dirname (dirname $PWD))))
        
        # If we're in home directory, just show ~
        if test "$PWD" = "$HOME"
            set_color cyan
            echo -n "~"
        else
            # If parent is home, show ~/current
            if test (dirname $PWD) = "$HOME"
                set_color cyan
                echo -n "~"
                set_color red
                echo -n "/"
                set_color cyan
                echo -n "$current_dir"
            else
                # If grandparent is home, show ~/parent/current
                if test (dirname (dirname $PWD)) = "$HOME"
                    set_color cyan
                    echo -n "~"
                    set_color red
                    echo -n "/"
                    set_color cyan
                    echo -n "$parent_dir"
                    set_color yellow
                    echo -n "/"
                    set_color cyan
                    echo -n "$current_dir"
                else
                    # If great-grandparent is home, show ~/grandparent/parent/current
                    if test (dirname (dirname (dirname $PWD))) = "$HOME"
                        set_color cyan
                        echo -n "~"
                        set_color red
                        echo -n "/"
                        set_color cyan
                        echo -n "$grandparent_dir"
                        set_color yellow
                        echo -n "/"
                        set_color cyan
                        echo -n "$parent_dir"
                        set_color magenta
                        echo -n "/"
                        set_color cyan
                        echo -n "$current_dir"
                    else
                        # Show great-grandparent/grandparent/parent/current
                        set_color cyan
                        echo -n "$great_grandparent_dir"
                        set_color red
                        echo -n "/"
                        set_color cyan
                        echo -n "$grandparent_dir"
                        set_color yellow
                        echo -n "/"
                        set_color cyan
                        echo -n "$parent_dir"
                        set_color magenta
                        echo -n "/"
                        set_color cyan
                        echo -n "$current_dir"
                    end
                end
            end
        end
        
        # Git information display
        if command -v git >/dev/null
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1
                set -l git_branch (git branch 2>/dev/null | sed -n '/\* /s///p')
                set -l repo_name (basename (git rev-parse --show-toplevel 2>/dev/null))
                if test -n "$git_branch"
                    set_color yellow
                    echo -n " ["
                    set_color cyan
                    echo -n "$repo_name"
                    set_color white
                    echo -n ":"
                    set_color magenta
                    echo -n "$git_branch"
                    set_color yellow
                    echo -n "]"
                end
            end
        end
        
        # New line with three colored carets
        echo
        set_color red
        echo -n ">"
        set_color yellow
        echo -n ">"
        set_color green
        echo -n "> "
        set_color normal
    end
end

# Set FZF default command to use `fd` for finding files
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

function colorstuff
    while read -l input
        switch $input
            case "*error*"
                set_color red
                echo $input
                set_color normal
            case "*warning*"
                set_color yellow
                echo $input
                set_color normal
            case "*success*"
                set_color green
                echo $input
                set_color normal
            case "*info*"
                set_color blue
                echo $input
                set_color normal
            case "*"
                echo $input
        end
    end
end

# Path configurations
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/Downloads/nvim-linux64/bin $PATH
set -gx PATH $PATH $HOME/.linkerd2/bin
set -gx KUBECONFIG "/home/ben/Downloads/k8s-services-kubeconfig.yaml"

# Editor configurations
set -gx VISUAL nvim
set -gx EDITOR nvim

# Environment variables
set -x DESIRED_MEM 24576
set -x PROTOC /usr/bin/protoc
set -x CARGO_PROFILE_DEV_BUILD_OVERRIDE_DEBUG true

# Aliases
alias nvim_c='cd ~/.config/nvim/ && nvim'
alias tmux_c='nvim ~/Documents/compass/tools/tmux/tmux-startup.sh'
alias fish_c='nvim ~/.config/fish/config.fish'
alias alacritty_c='nvim ~/.config/alacritty/alacritty.toml'
alias compass='cd ~/Documents/compass/'
alias core='cd ~/Documents/compass/core/'
alias git_compass='cd ~/Documents/compass/ && lazygit'
alias compass_services='cd ~/Documents/compass-services/'
alias ls='exa --tree --level=2 --icons'

# Add this after your aliases:

# Function to run ls after cd
function cd
    if test (count $argv) -gt 0
        builtin cd $argv
        and exa --tree --level=1 --icons
    else
        builtin cd ~
        and exa --tree --level=1 --icons
    end
end