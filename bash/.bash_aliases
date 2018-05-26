# grep files in current directory
alias lgrep='ls -al | grep'

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# remember directory
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'


