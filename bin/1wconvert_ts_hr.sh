#!/bin/bash

perl -e 'while($a=<STDIN>){$a=~s/\d+(\.\d+)?/localtime $&/e; print $a}' 
