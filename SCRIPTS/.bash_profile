# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

export GOROOT=/usr/local/go
export GOPATH=$HOME/go

PATH=$PATH:$HOME/bin:$GOROOT/bin:$GOPATH/bin
export PATH

export EDITOR=nano

