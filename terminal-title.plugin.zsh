emulate -L zsh
setopt warn_create_global no_auto_pushd

# Display $1 in terminal title.
function set-term-title() {
    if [[ -t 1 ]]; then
        print -rn -- $'\e]0;'${(V)1}$'\a'
    elif [[ -w $TTY ]]; then
        print -rn -- $'\e]0;'${(V)1}$'\a' >$TTY
    fi
}

function get-git-toplevel-basename-or-pwd(){
    which git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null && \
      basename $(git rev-parse --show-toplevel) || echo ${(V%):-"%~"}
}

# When a command is running, display it in the terminal title.
function set-term-title-preexec() {
    if (( P9K_SSH )); then
        set-term-title ${(V%):-"%n@%m: $(get-git-toplevel-basename-or-pwd) ❯ "}$1
    else
        set-term-title ${(V%):-"$(get-git-toplevel-basename-or-pwd) ❯ "}$1
    fi
}

# When no command is running, display the current directory in the terminal title.
function set-term-title-precmd() {
    if (( P9K_SSH )); then
        set-term-title ${(V%):-"%n@%m: $(get-git-toplevel-basename-or-pwd)"}
    else
        set-term-title ${(V%):-"$(get-git-toplevel-basename-or-pwd)"}
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec set-term-title-preexec
add-zsh-hook precmd set-term-title-precmd
