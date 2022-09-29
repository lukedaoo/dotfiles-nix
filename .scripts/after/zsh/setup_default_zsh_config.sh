#!/bin/bash

ZSH_FILES=(".zshrc" ".zshrc-config" ".zshrc-env" ".zshrc-deps" ".zshrc-alias" ".zshrc-func")
ZSH_FILES_BK_FOLDER="$HOME/.zsh_bk"
timestamp() {
	date +%s%N | cut -b1-13
}

if [ ! -d $ZSH_FILES_BK_FOLDER ]; then
	mkdir $ZSH_FILES_BK_FOLDER
fi

if [ ! -f "$HOME/.zhistory" ]; then
	touch $HOME/.zhistory
fi

for file in ${ZSH_FILES[@]}; do 

	if [ ! -e $HOME/$file ]; then
		touch $HOME/$file
	else 
		uuid="$(timestamp)"
		bk_file_name="${file}_${uuid}"
		echo "Create backup $file at $ZSH_FILES_BK_FOLDER/$bk_file_name"
		mv "$HOME/$file" "${ZSH_FILES_BK_FOLDER}/${bk_file_name}"
	fi
done

ZSHRC_DEFAULT_CONTENT="
if [ -f ~/.zshrc-config ]; then
    source ~/.zshrc-config
fi

if [ -f ~/.zshrc-env ]; then
    source ~/.zshrc-env
fi

if [ -f ~/.zshrc-deps ]; then
    source ~/.zshrc-deps
fi

if [ -f ~/.zshrc-alias ]; then
    source ~/.zshrc-alias
fi

if [ -f ~/.zshrc-func ]; then
    source ~/.zshrc-func
fi
"

echo "$ZSHRC_DEFAULT_CONTENT" >> ${HOME}/${ZSH_FILES[0]}

ZSHRC_CONFIG_DEFAULT_CONTENT="
autoload -U compinit; compinit
export HISTFILE='$HOME/.zhistory'    
export HISTSIZE=1000                  
export SAVEHIST=1000                   
setopt SHARE_HISTORY
"

echo "$ZSHRC_CONFIG_DEFAULT_CONTENT" >> ${HOME}/${ZSH_FILES[1]}

ZSHRC_ENV_DEFAULT_CONTENT="
export CONFIG_DIR='$HOME/.config'
export OPT_DIR='$HOME/.local/share'
export WALLPAPER_DIR='$HOME/.wallpaper'
export WORKSPACE_DIR='$HOME/Work'
export RUNTIME_LIB='$HOME/.runtime-lib'
export SCRIPT_DIR='$HOME/.scripts'
"
echo "$ZSHRC_ENV_DEFAULT_CONTENT" >> ${HOME}/${ZSH_FILES[2]}

ZSHRC_DEPS_DEFAULT_CONTENT="
"
echo "$ZSHRC_DEPS_DEFAULT_CONTENT" >> ${HOME}/${ZSH_FILES[3]}


ZSHRC_ALIAS_DEFAULT_CONTENT="
### Simple function
cd()  { builtin cd \$@; ls -G; }

w() { cd ~/Work/\$@ }

weather() { curl wttr.in }
###


alias e='exit'

alias clean='reset'
alias rs='clear'

alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../' 
alias .6='cd ../../../../../../'
alias ~='cd ~'

alias dl='cd ~/Downloads'
alias lib='cd ~/.runtime-lib'

alias ls='ls -G'        
alias la='ls -AF'       
alias ll='ls -al'
alias l1='ls -1'
"
echo "$ZSHRC_ALIAS_DEFAULT_CONTENT" >> ${HOME}/${ZSH_FILES[4]}

ZSHRC_FUNC_DEFAULT_CONTENT="
generatePassword() {
    if [ \$1 ] ; then
        openssl rand -base64 \$1
    else 
        openssl rand -base64 8
    fi
}

decodeBase64() {
    echo \$1 | base64 --decode ; echo
}        

encodeBase64() {
    echo \$1 | base64  ; echo
}      

showUsingPort() {
    netstat -nlp 
}

extract () {
    if [ -f \$1 ] ; then
        case \$1 in
            *.tar.bz2)   tar xjf \$1     ;;
            *.tar.gz)    tar xzf \$1     ;;
            *.bz2)       bunzip2 \$1     ;;
            *.rar)       unrar e \$1     ;;
            *.gz)        gunzip \$1     ;;
            *.tar)       tar xf \$1      ;;
            *.tbz2)      tar xjf \$1     ;;
            *.tgz)       tar xzf \$1     ;;
            *.zip)       unzip \$1       ;;
            *.Z)         uncompress \$1  ;;
            *.7z)        7z x \$1        ;;
            *)     echo \"'\$1' cannot be extracted via extract()\" ;
        esac
    else
        echo \"\$1 is not a valid file\"
    fi
}

make_clean_install() {
	sudo make uninstall
	sudo make clean install
}

"
echo "$ZSHRC_FUNC_DEFAULT_CONTENT" >> ${HOME}/${ZSH_FILES[5]}
