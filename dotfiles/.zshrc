# Created by rcrumana for 5.9
PS1='%n@%m:%c$ '
export PATH="$HOME/.cargo/bin:$PATH" 
alias osu-lazer='DRI_PRIME=1 osu-lazer'

eval $(ssh-agent)
ssh-add ~/.ssh/github
clear
sleep 0.1
fastfetch
