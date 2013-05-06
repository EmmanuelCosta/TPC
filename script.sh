#!/bin/sh



make

cat "./source" |./projet > "progVM"

./vm686 "progVM"
