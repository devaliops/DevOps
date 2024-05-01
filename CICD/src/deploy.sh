#! /bin/bash

scp cat/s21_cat ws3@192.168.100.11:~/
scp grep/s21_grep ws3@192.168.100.11:~/
ssh ws3@192.168.100.11 "echo '1' | sudo -S mv s21_cat s21_grep /usr/local/bin"
