#!/usr/bin/env bash

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

godep(){
     go list -f '{{ join .Deps  "\n"}}' .
}
alias depv='dep status -dot | dot -T png | display'
