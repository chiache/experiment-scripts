#!/bin/bash

gdb -iex "set auto-load safe-path $PWD" $@
