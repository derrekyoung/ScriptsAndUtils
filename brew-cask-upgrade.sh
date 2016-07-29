#!/bin/bash

################################################################################
#   Does a mass upgrade of your Homebrew apps and allows you to select which
#   Cask apps to upgrade.
#
#   Author: Derrek Young, derrekyoung.com
#   Requirements:
#       Homebrew http://brew.sh/
#       Cask https://caskroom.github.io/
#
################################################################################

# Upgrade all the Homebrew apps
brew-upgrade-main() {
    # Upgrade the Homebrew apps
    brew update && brew cleanup && brew list | xargs brew upgrade

    echo "Brew upgrade finished."
}

# Get info for a single cask
cask-info() {
    echo -e "Installed versions of $1: "; ls /usr/local/Caskroom/$1

    info=$(brew cask info $1)
    IFS=$'\n' lines=($info)

    echo "Available cask info for ${lines[1]}, ${lines[0]}"
}

# Get info for all casks
cask-lookup() {
    for c in $(brew cask list); do
        brew cask info $c
    done
}

# List info for every Cask installed. (This is kind of noisy.)
cask-list() {
    for c in $(brew cask list); do
        echo -e "Installed versions of $c: "
        ls /usr/local/Caskroom/$c

        info=$(brew cask info $c)
        IFS=$'\n' lines=($info)

        echo "Available cask info for ${lines[1]}, ${lines[0]}"
        echo " "
    done
}

# Menu to selectively upgrade available casks
cask-upgrade-menu() {
    local caskItem="$1"

    echo "Install update for $caskItem?"
    select yn in Update Skip ; do
        case $yn in
            Update)
                echo "Updating $caskItem..."

                echo "Uninstalling $caskItem"
                brew cask uninstall --force "$caskItem"

                echo "Re-installing $caskItem"
                brew cask install "$caskItem"

                echo -e "$caskItem finished. \n"

                break
                ;;
            Skip)
                echo -e "Skipping $caskItem... (╯°□°)╯︵ ┻━┻ \n"
                break
                ;;
            *)
                echo "Please choose 1 or 2"
                ;;
        esac
    done
}

# Selectively upgrade casks
cask-upgrade-main() {
    brew update && brew cask cleanup

    var=$( cask-lookup  | grep -B 3 'Not installed' | sed -e '/^http/d;/^Not/d;/:/!d'  | cut -d ":" -f1)

    if [ -n "$var" ]; then
        echo -e "All available updates:"
        echo -e "$var \n"

        for caskItem in $var; do
            cask-info "$caskItem"

            cask-upgrade-menu "$caskItem"
        done
    else
      echo -e "All casks are up to date  ¯\_(ツ)_/¯ \n"
    fi

    echo "Cask upgrade finished."
}

brew-upgrade-main

cask-upgrade-main
