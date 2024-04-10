setup() {
    git config --global user.name $1
    git config --global user.email $2
    git config --global credential.helper store
}

setup $@  
