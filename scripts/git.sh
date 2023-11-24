#!/bin/bash

check_git_installed (){
    if ! git --version > /dev/null 2>&1; then
        echo "ERROR: git is not installed"
        echo "SOLUTION: please install git and try again!"
        exit 1
    fi
}

git_clone_public_project (){
    repo_url=$1
    if [ -z "$repo_url" ]; then
        echo "ERROR: No repository URL provided"
        exit 1
    fi
    echo "INFO: Cloning $repo_url"
    git clone "$repo_url"
    echo "OK: $repo_url cloned."
}

git_clone_private_project (){
    repo_url=$1
    if [ -z "$repo_url" ]; then
        echo "ERROR: No repository URL provided"
        exit 1
    fi

    if [ -z "$GIT_USER" ] || [ -z "$GIT_PASS" ]; then
        echo "ERROR: GIT_USER or GIT_PASS is not set"
        exit 1
    fi

    echo "INFO: Cloning $repo_url"
    git clone https://"$GIT_USER":"$GIT_PASS"@"$repo_url"
    echo "OK: $repo_url cloned."
}

git_checkout_branch() {
    branch=$1
    folder=${2:-$(pwd)}

    if [ -z "$branch" ]; then
        echo "ERROR: Please provide a branch name"
        exit 1
    fi

    echo "INFO: Checking out to branch $branch in $folder..."
    if [ -d "$folder/.git" ]; then
        (
            cd "$folder" || exit 1
            git fetch && git pull --all
            exists=$(git ls-remote --heads origin "refs/heads/$branch" | wc -l)
            
            if [ "$exists" -eq 0 ]; then
                echo "ERROR: Branch $branch does not exist in $folder"
                echo "SOLUTION: Check the branch name and try again"
                exit 1
            else
                git checkout "$branch"
                echo "OK: Branch $branch checked out in $folder"
            fi
        )

    else
        echo "ERROR: $folder is not a git repository"
        echo "SOLUTION: Please check that the folder includes git historial and try again"
        exit 1
    fi
}

