if status is-interactive
    # Commands to run in interactive sessions can go here
end

function starship_transient_prompt_func
    starship module character
end

function starship_transient_rprompt_func
    starship module time
end

starship init fish | source
enable_transience

zoxide init fish | source

alias icat="kitten icat"

direnv hook fish | source
source /home/ska/.local/bin/env.fish

# opencode
fish_add_path /home/ska/.opencode/bin

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"
