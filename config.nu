# Set up Nushell configuration
let carapace_completer = {|spans| carapace $spans.0 nushell}

# Define a simpler prompt format first to debug
def create_left_prompt [] {
    let dir = (pwd | str replace $nu.home-path "~")
    $"(ansi green_bold)($dir)(ansi reset)"
}

$env.PROMPT_COMMAND = { create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

$env.config = {
    show_banner: true
    edit_mode: "emacs"
    float_precision: 3
    use_ansi_coloring: true
    history: {
        file_format: "plaintext"
        sync_on_enter: true
    }
    completions: {
        external: {
            enable: true
            completer: $carapace_completer
        }
    }
    keybindings: []
}

# Set Environment Variables
$env.Path = ($env.Path
    | split row (char esep)
    | prepend "C:/Users/bensh/AppData/Roaming/carapace/bin"
    | prepend 'C:\Program Files\Git\bin'
    | prepend 'C:\Windows\System32'
)

# Carapace Setup
# def --env get-env [name] { $env | get $name }
# def --env set-env [name, value] { load-env { $name: $value } }
# def --env unset-env [name] { hide-env $name }

let carapace_completer = {|spans|
    # if the current command is an alias, get it's expansion
    let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

    # overwrite
    let spans = (if $expanded_alias != null  {
        # put the first word of the expanded alias first in the span
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else {
        $spans
    })

    carapace $spans.0 nushell ...$spans
    | from json
}

# Aliases for Convenience
def gitlog [] { git log --oneline --graph --all }
alias ll = ls -lh   # List with human-readable sizes
alias cls = run-external clear
#alias vim = nvim    # Map vim to neovim if installed
alias .. = cd ..    # Move up a directory

# Custom Commands
def greet [name: string] {
    print $"Hello, (ansi green_bold)($name)(ansi reset)! Welcome to Nushell."
}


# Starship prompt integration
#let-env PROMPT_COMMAND = { || starship prompt }