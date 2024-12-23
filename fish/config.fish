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

    echo # Empty line for spacing
    set_color yellow
    echo "Sync Commands: s_[tmux|fish|nvim|gitui|alacritty|firefox|newsboat]"
    echo "Navigate To:   d_[config|compass]"
    echo
    set_color normal
end

cd ~/Documents/compass 2>/dev/null; or cd ~

if status is-interactive
    function fish_prompt
        set_color normal
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
    set_color normal
end

# Set FZF default command to use `fd` for finding files
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

# Path configurations
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/Downloads/nvim-linux64/bin $PATH
set -gx PATH $PATH $HOME/.linkerd2/bin
set -gx KUBECONFIG "/home/ben/Downloads/k8s-services-kubeconfig.yaml"
set -gx COLORTERM truecolor
set -gx TERM_PROGRAM alacritty
set -gx VISUAL nvim
set -gx EDITOR nvim
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
alias tk='tmux kill-server'
alias git_compass='cd ~/Documents/compass/ && lazygit'
alias compass_services='cd ~/Documents/compass-services/'
alias ls='exa --tree --level=1 --only-dirs --icons'
alias tmux=_tmux
alias s_tmux="$HOME/Documents/compass/configs/arch/sync_tmux.sh"
alias s_fish="$HOME/Documents/compass/configs/arch/sync_fish.sh"
alias s_nvim="$HOME/Documents/compass/configs/arch/sync_nvim.sh"
alias s_alacritty="$HOME/Documents/compass/configs/arch/sync_alacritty.sh"
alias s_gitui="$HOME/Documents/compass/configs/arch/sync_gitui.sh"
alias s_firefox="$HOME/Documents/compass/configs/arch/sync_firefox.sh"
alias s_newsboat="$HOME/Documents/compass/configs/arch/sync_newsboat.sh"
alias d_config="cd $HOME/Documents/compass/configs/ && nvim"
alias d_orch="cd $HOME/Documents/compass/orch && nvim"
alias d_compass="cd $HOME/Documents/compass/ && nvim"

alias .='cd ..'

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

function _tmux
   # No arguments provided
   if test (count $argv) -eq 0
       # Create or attach to main session then send the key sequence for prefix + s
       command tmux new-session -A -s main \; send-keys C-b s
   else
       # Pass through any tmux arguments
       command tmux $argv
   end
end