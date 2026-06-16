# WSL Nushell Configuration
# Copy to ~/.config/nushell/config.nu

# Carapace completer with alias support (if carapace is installed)
let carapace_completer = {|spans|
    let expanded_alias = (scope aliases | where name == $spans.0 | get -o 0 | get -o expansion)

    let spans = (if $expanded_alias != null {
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else {
        $spans
    })

    carapace $spans.0 nushell ...$spans | from json
}

# Starship prompt
$env.PROMPT_COMMAND = { || starship prompt }
$env.PROMPT_COMMAND_RIGHT = { || starship prompt --right }
$env.PROMPT_INDICATOR = ""

# Main config
$env.config = {
    show_banner: false
    edit_mode: "emacs"
    use_ansi_coloring: true

    history: {
        file_format: "plaintext"
        sync_on_enter: true
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
        external: {
            enable: true
            max_results: 100
            completer: $carapace_completer
        }
    }

    keybindings: []
}

# Environment - Linux paths
$env.PATH = ($env.PATH
    | split row (char esep)
    | prepend '/usr/local/bin'
    | prepend $'($env.HOME)/.local/bin'
    | prepend $'($env.HOME)/.cargo/bin'
)

# Starship config - use the Windows config via WSL mount
$env.STARSHIP_CONFIG = '/mnt/c/Users/bensh/Git/Windows-Config/starship.toml'

# Aliases
def gitlog [] { git log --oneline --graph --all }
alias ll = ls -l
alias la = ls -la
alias cls = clear
alias .. = cd ..

# XTDB Docker Dev Aliases
def xtdb-reset [] {
    docker rm -f xtdb | ignore
    docker run -d --name xtdb -p 5434:5432 -p 8080:8080 ghcr.io/xtdb/xtdb
    print "XTDB container reset and booting up on port 5434"
}
alias xtdb-con = psql -h localhost -p 5434 -U xtdb
alias xtdb-log = docker logs xtdb
