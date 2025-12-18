# Add to default config location
# source ~/Git/Windows-Config/config.nu

# Nushell Configuration

# Carapace completer with alias support
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
    show_banner: false # Set true to see the elephant :)
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

# Environment - using ~ for portability
$env.Path = ($env.Path
    | split row (char esep)
    | prepend $"($nu.home-path)/AppData/Roaming/carapace/bin"
    | prepend 'C:\Program Files\Git\bin'
    | prepend 'C:\Windows\System32'
)

# Starship config location
$env.STARSHIP_CONFIG = $"($nu.home-path)/Git/Windows-Config/starship.toml"

# Aliases
def gitlog [] { git log --oneline --graph --all }
alias ll = ls -l
alias la = ls -la
alias cls = clear
alias .. = cd ..
