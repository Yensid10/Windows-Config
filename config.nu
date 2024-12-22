# "C:\Users\BCS\Documents\nu\config.nu"

# Set up Nushell configuration
$env.config = {
    show_banner: false,          # Disable the Nushell startup banner
    edit_mode: "emacs",          # Keybinding mode: emacs or vi
    float_precision: 3,          # Set floating-point precision
    use_ansi_coloring: true,     # Enable colored output
    history: {
        file_format: "plaintext", # Store history as plain text
        sync_on_enter: true       # Write to history immediately
    }
}

# Set Environment Variables
$env.PATH = ($env.PATH | split row ";" | prepend 'C:\Program Files\Git\bin' | prepend 'C:\Windows\System32')

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

# Keybindings (Windows compatible)
$env.keybindings = [
    { name: "clear_line", modifier: "control", keycode: "k", mode: "insert", event: { edit: { clear_line: true } } }
]

# Starship prompt integration
#let-env PROMPT_COMMAND = { || starship prompt }
