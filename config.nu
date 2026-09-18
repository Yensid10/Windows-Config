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
    | prepend ($nu.home-dir | path join '.local' 'bin')  # Claude Code native install (claude.exe)
    | prepend $"($nu.home-dir)/AppData/Roaming/carapace/bin"
    | prepend 'C:\Program Files\Git\bin'
    | prepend 'C:\Windows\System32'
    | uniq
)

# Starship config location
$env.STARSHIP_CONFIG = $"($nu.home-dir)/Git/Windows-Config/starship.toml"

# Aliases
def gitlog [] { git log --oneline --graph --all }
alias ll = ls -l
alias la = ls -la
alias lsa = ls **/*
alias cls = clear
alias .. = cd ..
# sudo elevates so machine-scope packages (PowerShell, etc.) actually install.
# Discord is pinned + self-updates; Slack self-updates — both handled outside winget.
def winget-upgrade [] {
    sudo winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
    # yt-dlp self-updates from GitHub; winget's manifest lags behind YouTube breakage.
    # Also pinned in winget (winget pin add yt-dlp.yt-dlp) because -U rewrites the exe
    # winget hash-tracks, which otherwise fails with "Portable package has been modified".
    yt-dlp -U
}

# Pull every URL out of a string, even ones pasted back-to-back with no separator.
# Used by the yt-dwnld family.
def split-urls [text: string] {
    $text
    | str replace --all --regex 'https?://' "\n${0}"
    | lines
    | str trim
    | where {|l| $l =~ '^https?://' }
}

# Every batch-folder root the downloaders use. Running one from inside any of these
# (or a subfolder) adds to that folder instead of starting a new batch.
def yt-roots [] {
    [
        ($nu.home-dir | path join 'Music' 'YT SC Download')
        ($nu.home-dir | path join 'Music' 'YT Music Download')
    ]
}

# Where this run saves: the folder you're standing in if it's already a batch folder,
# otherwise a fresh timestamped one under `root`.
def yt-dest [root: string] {
    let cwd = ($env.PWD | path expand)
    let inside = (yt-roots | any {|r|
        (try { ($cwd | str lowercase) | path relative-to ($r | str lowercase) } catch { null }) | is-not-empty
    })
    if $inside {
        print $"Adding to the folder you're in: ($cwd)"
        $cwd
    } else {
        $root | path join (date now | format date '%Y-%m-%d %H-%M')
    }
}

# Shared engine behind yt-dwnld and yt-dwnld-mp3.
#   root - batch-folder root to use when not already inside one
#   fmt  - the yt-dlp flags that decide the output format
#   raw  - URLs from the caller; empty means prompt mode
def yt-dwnld-run [root: string, fmt: list<string>, raw: list<string>] {
    let dest = (yt-dest $root)
    let template = ($dest | path join '%(title)s.%(ext)s')

    # Argument mode: one sequential yt-dlp run with live progress.
    let urls = (split-urls ($raw | str join "\n"))
    if not ($urls | is-empty) {
        print $"Downloading ($urls | length) URLs into ($dest)"
        yt-dlp ...$fmt -o $template ...$urls
        return
    }

    # Prompt mode: each pasted URL becomes a background job that reports back when done.
    print $"Saving into ($dest)"
    print "Paste a URL and press Enter to start downloading it. Type exit when you're done."
    mut started = 0
    loop {
        let line = (input "> " | str trim)
        if ($line | is-empty) { continue }
        if (($line | str lowercase) in ['exit' 'quit' 'q']) { break }
        let batch = (split-urls $line)
        if ($batch | is-empty) {
            print "  That doesn't look like a URL. Paste one, or type exit."
            continue
        }
        for url in $batch {
            job spawn {
                let r = (yt-dlp ...$fmt -o $template --print after_move:filepath $url | complete)
                if $r.exit_code == 0 {
                    print $"\r  done: ($r.stdout | str trim | path basename)\n> "
                } else {
                    print $"\r  FAILED ($url)\n($r.stderr | str trim)\n> "
                }
                {url: $url, ok: ($r.exit_code == 0)} | job send 0
            }
            $started += 1
        }
    }

    # Wait for every job to report (or vanish), then summarise.
    mut done = []
    while ($done | length) < $started {
        let msg = (try { job recv --timeout 500ms } catch { null })
        if $msg != null {
            $done = ($done | append $msg)
        } else if (job list | is-empty) {
            break
        } else {
            print -n $"\rWaiting for ($started - ($done | length)) downloads to finish..."
        }
    }
    let failed = ($done | where not ok)
    print $"\rFinished: (($done | length) - ($failed | length)) of ($started) saved to ($dest)"
    if ($dest | path exists) { start $dest }
    if ($failed | is-empty) {
        exit
    }
    print "Leaving the shell open so you can see the errors above. Failed:"
    for u in ($failed | get url) { print $"  ($u)" }
}

# Batch-download YouTube audio as WAV (lossless intermediate for Premiere).
# Usage:  yt-dwnld <url> <url> ...   downloads them all, one after another
#         yt-dwnld                   prompt mode: paste a URL, press Enter, and it starts
#                                    downloading in the background while you go find the
#                                    next one. Type `exit` when done: waits for anything
#                                    still downloading, opens the batch folder in Explorer,
#                                    then closes the shell (stays open if anything failed).
# Each run gets its own timestamped batch folder under Music\YT SC Download.
# Run it from inside one of those folders (cd there first) to add downloads to it instead.
def yt-dwnld [...urls: string] {
    yt-dwnld-run ($nu.home-dir | path join 'Music' 'YT SC Download') [
        '-x' '--audio-format' 'wav'
    ] $urls
}

# Same as yt-dwnld, but saves tagged M4A (AAC) ready to drop into Apple Music.
# M4A rather than true MP3: YouTube already serves AAC, so the audio is copied out
# untouched with no re-encode, and unlike WAV/FLAC it carries artwork and tags that
# Music.app and iCloud sync keep. Title, artist, album and square cover art come
# from YouTube, so you only tidy up what you care about.
# Saves under Music\YT Music Download; same folder rules as yt-dwnld.
def yt-dwnld-mp3 [...urls: string] {
    yt-dwnld-run ($nu.home-dir | path join 'Music' 'YT Music Download') [
        '-f' 'bestaudio[ext=m4a]/bestaudio'
        '-x' '--audio-format' 'm4a' '--audio-quality' '0'
        '--embed-metadata' '--embed-thumbnail'
        '--convert-thumbnails' 'jpg'
        '--ppa' 'ThumbnailsConvertor:-vf crop=ih:ih'
    ] $urls
}

# Some XTDB Docker Dev Aliases
def xtdb-reset [] {
    # Silently remove if exists (ignore errors if not running)
    docker rm -f xtdb | ignore
    docker run -d --name xtdb -p 5434:5432 -p 8080:8080 ghcr.io/xtdb/xtdb
    print "XTDB container reset and booting up on port 5434"
}
alias xtdb-con = psql -h localhost -p 5434 -U xtdb
alias xtdb-log = docker logs xtdb

def kanban [] {
    cd ~/Git/YensBan
    npm run dev
}

def kanban-s [] {
    cd ~/Git/YensBan
    npm run share
}