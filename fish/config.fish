# ~/.config/fish/config.fish
set fish_greeting ""

if status is-interactive
    function fish_prompt
        # Get current directory and parent
        set -l current_dir (basename $PWD)
        set -l parent_dir (basename (dirname $PWD))
        
        # Format the path display
        set_color green
        # If we're in home directory, just show ~
        if test "$PWD" = "$HOME"
            echo -n "~"
        else
            # If parent is home, show ~/current
            if test (dirname $PWD) = "$HOME"
                echo -n "~/$current_dir"
            else
                # Show parent/current
                echo -n "$parent_dir/$current_dir"
            end
        end
        
        # Git branch display
        if command -v git >/dev/null
            set -l git_branch (git branch 2>/dev/null | sed -n '/\* /s///p')
            if test -n "$git_branch"
                set_color yellow
                echo -n " ($git_branch)"
            end
        end
        
        set_color green
        echo -n ' > '
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
alias ls='exa --tree --level=2'
