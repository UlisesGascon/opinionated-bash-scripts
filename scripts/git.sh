#!/bin/bash

check_git_installed (){
    if ! git --version > /dev/null 2>&1; then
        echo "ERROR: git is not installed"
        echo "SOLUTION: please install git and try again!"
        return 1
    fi
}

git_clone_public_project (){
    repo_url=$1
    echo "INFO: Cloning $repo_url"
    git clone $repo_url
    echo "OK: $repo_url cloned."
}

git_clone_private_project (){
    repo_url=$1
    echo "INFO: Cloning $repo_url"
    git clone https://$GIT_USER:$GIT_PASS@$repo_url
    echo "OK: $repo_url cloned."
}

git_checkout_branch() {
    folder=$1
    branch=$2
    
    echo "INFO: Checking out to branch $branch in $folder..."

    if [ -d "$folder/.git" ]; then
        cd $folder
        git fetch && git pull --all
        if git show-ref --verify --quiet refs/heads/$branch; then
            git checkout $branch
            echo "OK: Branch $branch checked out in $folder"
        else
            echo "ERROR: Branch $branch does not exist in $folder"
            echo "SOLUTION: Check the branch name and try again"
            return 1
        fi
        cd ..
    else
        echo "ERROR: $folder is not a git repository"
        echo "SOLUTION: Please check that the folder includes git historial and try again"
        return 1
    fi
}

