#!/bin/bash

################################################################################
#  Does a mass upgrade of your Homebrew apps and allows you to interactively
#  select which Cask apps to upgrade.
#
#  ./brew-cask-upgrade.sh "<BREW_EXCLUDES>" "<CASK_EXCLUDES>"
#
#  Requirements:
#       Homebrew http://brew.sh/
#       Cask https://caskroom.github.io/
#
################################################################################


# Will exclude these apps from updating. Pass in params to fit your needs. Use the exact brew/cask name and separate names with a pipe |
BREW_EXCLUDES="${1:-}"
CASK_EXCLUDES="${2:-}"

cleanup-all() {
    echo -e "Cleaning up..."
    brew update && brew cleanup && brew cask cleanup
    echo -e "Clean finished.\n\n"
}

# Upgrade all the Homebrew apps
brew-upgrade() {
    log-info "Updating Brew apps..."

    printf '=%.0s' {1..82}
    printf '\n'
    printf "%-40s | %-20s | %-5s\n" "BREW NAME" "LATEST VERSION" "LATEST INSTALLED"
    printf '=%.0s' {1..82}
    printf '\n'


    for item in $(brew list); do
        local BREW_INFO=$(brew info $item)
        local BREW_NAME="$item"
        local NEW_VERSION=$(echo "$BREW_INFO" | grep -e "$BREW_NAME: .*" | cut -d" " -f3 | sed 's/,//g')
        local IS_CURRENT_VERSION_INSTALLED=$(echo "$BREW_INFO" | grep -q ".*/Cellar/$BREW_NAME/$NEW_VERSION.*" 2>&1 && echo true )

        printf "%-40s | %-20s | %-20s\n" "$BREW_NAME" "$NEW_VERSION" "$IS_CURRENT_VERSION_INSTALLED"

        # Install if not up-to-date and not excluded
        if [[ "$CURRENT_VERSION_INSTALLED" == false ]] && [[ ${BREW_EXCLUDES} != *"$BREW_NAME"* ]]; then
            brew upgrade $item
        fi

        BREW_INFO=""
        NEW_VERSION=""
        IS_CURRENT_VERSION_INSTALLED=""
    done

    log-info "Brew upgrades finished.\n"
}

# Selectively upgrade casks
cask-upgrade() {
    log-info "Updating Cask apps..."

    printf '=%.0s' {1..82}
    printf '\n'
    printf "%-40s | %-20s | %-5s\n" "CASK NAME" "LATEST VERSION" "LATEST INSTALLED"
    printf '=%.0s' {1..82}
    printf '\n'

    for c in $(brew cask list); do
        local CASK_INFO=$(brew cask info $c)
        local CASK_NAME=$(echo "$c" | cut -d ":" -f1 | xargs)
        local NEW_VERSION=$(echo "$CASK_INFO" | grep -e "$CASK_NAME: .*" | cut -d ":" -f2 | sed 's/ *//' )
        local IS_CURRENT_VERSION_INSTALLED=$(echo "$CASK_INFO" | grep -q ".*/Caskroom/$CASK_NAME/$NEW_VERSION.*" 2>&1 && echo true )

        printf "%-40s | %-20s | %-20s\n" "$CASK_NAME" "$NEW_VERSION" "$IS_CURRENT_VERSION_INSTALLED"

        # Install if not up-to-date and not excluded
        if [[ "$IS_CURRENT_VERSION_INSTALLED" == false ]] && [[ ${CASK_EXCLUDES} != *"$CASK_NAME"* ]]; then
            brew cask install "$CASK_NAME" --force
        fi

        CASK_INFO=""
        NEW_VERSION=""
        IS_CURRENT_VERSION_INSTALLED=""
    done


    log-info "Cask upgrades finished.\n"
}

log-info() {
    echo -e "INFO:  $1"
}

cleanup-all

brew-upgrade

cask-upgrade
