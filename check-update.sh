#!/bin/env bash

token="5aea793d49d273a8a8e4abc344b4afecb84d2901"

check () {
    counter=0
    for folder in "$@"; do
        echo "Checking $folder"
        eval $(egrep "url=\"https://github.com|pkgname=|pkgver=" ./$folder/PKGBUILD)
        repo=$(echo $url | sed 's|https://github.com/||g')
        newest_tag=$(curl -sL "https://api.github.com/repos/$repo/tags?access_token=$token" | jq ".[0]")
        github_tag=$(echo $newest_tag | jq .name | tr -d '"v')

        if [[ $github_tag == $pkgver ]]; then
            echo "$pkgname is up to date"
            echo
        else
            (( counter++ ))
            tarball_url=$(echo $newest_tag | jq .tarball_url | tr -d '"')
            echo "$pkgname is out of date"
            echo "New release is $github_tag and tarball url is $tarball_url"
            echo
        fi
    done
    return $counter
}

check "jid-bin" "libcork" "libcstl" "dingtalk-electron" "clash-bin"

