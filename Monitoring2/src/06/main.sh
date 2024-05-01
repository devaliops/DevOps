#!/bin/bash

if [ $# != 0 ]; then
    echo "Параметров не должно быть"
else
    sudo goaccess $(pwd)/../04/log/*.log --log-format=COMBINED -o report.html
	sudo xdg-open report.html
fi