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

# Will exclude these apps from updating. Modify these to suite your needs. Use the exact brew/cask name and separate names with a pipe |
BREW_EXCLUDES="${1:-}"
CASK_EXCLUDES="${2:-}"

cleanup-all() {
    echo -e "Cleaning up..."
    brew update && brew cleanup && brew cask cleanup
    echo -e "Clean finished.\n\n"
}

# Upgrade all the Homebrew apps
brew-upgrade() {
    echo -e "Updating Brew apps... \n"

    var=$(brew list)

    if [ -n "$var" ]; then
        for item in $var; do
            [[ $item =~ ^($BREW_EXCLUDES)$ ]] && echo "Automatically excluding $item" && continue

            echo "Upgrading $item"
            brew upgrade $item
        done
    else
      echo -e "All Brew cellars are up to date \n"
    fi

    echo -e "Brew upgrade finished.\n\n"
}

# Selectively upgrade casks
cask-upgrade() {
    echo -e "Updating Cask apps... \n"

    echo -e "Checking all cask versions \n"
    printf '=%.0s' {1..82}
    printf '\n'
    printf "%-40s | %-20s | %-5s\n" "CASK NAME" "LATEST VERSION" "LATEST INSTALLED"
    printf '=%.0s' {1..82}
    printf '\n'

    for c in $(brew cask list); do
        CASK_INFO=$(brew cask info $c)

        CASK_NAME=$(echo "$c" | cut -d ":" -f1 | xargs)
        NEW_VERSION=$(echo "$CASK_INFO" | grep -e "$CASK_NAME: .*" | cut -d ":" -f2 | sed 's/ *//' )
        CURRENT_VERSION_INSTALLED=$(echo "$CASK_INFO" | grep -q ".*/Caskroom/$CASK_NAME/$NEW_VERSION.*" 2>&1 && echo true || if [[ ${CASK_EXCLUDES} != *"$CASK_NAME"* ]]; then echo "install"; else echo "excluded"; fi )

        printf "%-40s | %-20s | %-20s\n" "$CASK_NAME" "$NEW_VERSION" "$CURRENT_VERSION_INSTALLED"

        if [[ "$CURRENT_VERSION_INSTALLED" == "install" ]]; then
            brew cask install "$CASK_NAME" --force
            # echo ""
        fi

        NEW_VERSION=""
        CURRENT_VERSION=""
        CASK_INFO=""
    done


    echo -e "Cask upgrade finished.\n"
}

cleanup-all

brew-upgrade

cask-upgrade
