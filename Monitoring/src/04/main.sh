#!/bin/bash

function fon_1 {
    if [[ $1 == *[1]* ]] 
    then
        var="\033[107m"
    elif [[ $1 == *[2]* ]] 
    then
        var="\033[41m"
    elif [[ $1 == *[3]* ]] 
    then
        var="\033[42m"
    elif [[ $1 == *[4]* ]] 
    then
        var="\033[44m"
    elif [[ $1 == *[5]* ]] 
    then
        var="\033[45m"
    elif [[ $1 == *[6]* ]] 
    then
        var="\033[40m"
    else
        var="\033[45m"
    fi
    echo $var
}

function text_2 {
    if [[ $1 == *[1]* ]] 
    then
        var="\033[97m"
    elif [[ $1 == *[2]* ]] 
    then
        var="\033[31m"
    elif [[ $1 == *[3]* ]]
    then
        var="\033[32m"
    elif [[ $1 == *[4]* ]]
    then
        var="\033[34m"
    elif [[ $1 == *[5]* ]]
    then
        var="\033[35m"
    elif [[ $1 == *[6]* ]]
    then
        var="\033[30m"
    fi
    echo $var
}

function color {
    if [[ $1 == *[1]* ]] 
    then
        var="white"
    elif [[ $1 == *[2]* ]] 
    then
        var="red"
    elif [[ $1 == *[3]* ]]
    then
        var="green"
    elif [[ $1 == *[4]* ]]
    then
        var="blue"
    elif [[ $1 == *[5]* ]]
    then
        var="purple"
    elif [[ $1 == *[6]* ]]
    then
        var="black"
    fi
    echo $var
}

column1_background=$(awk 'BEGIN{FS="="} /column1_background/ {print $2}' color_parametr.conf)
if [ -z $column1_background ]
then 
    column1_background=1;
    flag_a=1
fi
column1_font_color=$(awk 'BEGIN{FS="="} /column1_font_color/ {print $2}' color_parametr.conf)
if [ -z $column1_font_color ]
then 
    column1_font_color=2;
    flag_b=1
fi
column2_background=$(awk 'BEGIN{FS="="} /column2_background/ {print $2}' color_parametr.conf)
if [ -z $column2_background ]
then 
    column2_background=3;
    flag_c=1
fi
column2_font_color=$(awk 'BEGIN{FS="="} /column2_font_color/ {print $2}' color_parametr.conf)
if [ -z $column2_font_color ]
then 
    column2_font_color=4;
    flag_d=1
fi

fon_1=$(fon_1 $column1_background)
text_2=$(text_2 $column1_font_color)
fon_3=$(fon_1 $column2_background)
text_4=$(text_2 $column2_font_color)

if [[ $column1_background == *[0-9]* ]] && [[ $column1_font_color = *[0-9]* ]] && [[ $column2_background == *[0-9]* ]] && [[ $column2_font_color == *[0-9]* ]] && [[ $column1_background != *[a-zA-Z]* ]] && [[ $column1_font_color != *[a-zA-Z]* ]] && [[ $column2_background != *[a-zA-Z]* ]] && [[ $column1_font_color != *[a-zA-Z]* ]]
then
    if [ $column1_background -ne $column1_font_color ] && [ $column2_background -ne $column2_font_color ]
    then
        echo -e $fon_1$text_2"HOSTNAME" ="\033[0m"$fon_3$text_4$(hostname)"\033[0m"
        echo -e $fon_1$text_2"TIMEZONE" ="\033[0m"$fon_3$text_4$(cat /etc/timezone)"\033[0m"
        echo -e $fon_1$text_2"USER" ="\033[0m"$fon_3$text_4$(whoami)"\033[0m"
        echo -e $fon_1$text_2"OS" ="\033[0m"$fon_3$text_4$(uname)"\033[0m"
        echo -e $fon_1$text_2"DATE" ="\033[0m"$fon_3$text_4$(date +"%d %B %Y %T")"\033[0m"
        echo -e $fon_1$text_2"UPTIME" ="\033[0m"$fon_3$text_4$(uptime -p)"\033[0m"
        echo -e $fon_1$text_2"UPTIME_SEC" ="\033[0m"$fon_3$text_4$(cat /proc/uptime)"\033[0m"
        echo -e $fon_1$text_2"IP" ="\033[0m"$fon_3$text_4$(hostname -I)"\033[0m"
        echo -e $fon_1$text_2"MASK" ="\033[0m"$fon_3$text_4$(ifconfig lo | grep netmask | awk '{print $4}')"\033[0m"
        echo -e $fon_1$text_2"GATEWAY" ="\033[0m"$fon_3$text_4$(hostname -i)"\033[0m"
        echo -e $fon_1$text_2"RAM_TOTAL" ="\033[0m"$fon_3$text_4$(free | grep Mem | awk '{printf("%.3f GB", $2 / 1000)}')"\033[0m"
        echo -e $fon_1$text_2"RAM_USED" ="\033[0m"$fon_3$text_4$(free | grep Mem | awk '{printf("%.3f GB", $3 / 1000)}')"\033[0m"
        echo -e $fon_1$text_2"RAM_FREE" ="\033[0m"$fon_3$text_4$(free | grep Mem | awk '{printf("%.3f GB", $4 / 1000)}')"\033[0m"
        echo -e $fon_1$text_2"SPACE_ROOT" ="\033[0m"$fon_3$text_4$(df /root/ | grep /dev/mapper/ | awk '{printf("%.2f Mb", $2 / 1000)}')"\033[0m"
        echo -e $fon_1$text_2"SPACE_ROOT_USED" ="\033[0m"$fon_3$text_4$(df /root/ | grep /dev/mapper/ | awk '{printf("%.2f Mb", $3 / 1000)}')"\033[0m"
        echo -e $fon_1$text_2"SPACE_ROOT_FREE" ="\033[0m"$fon_3$text_4$(df /root/ | grep /dev/mapper/ | awk '{printf("%.2f Mb", $4 / 1000)}')"\033[0m"

        if [[ flag_a -eq 1 ]]
        then
            color_1=default
        else
            color_1=$column1_background
        fi
        if [[ flag_b -eq 1 ]]
        then
            color_2=default
        else
            color_2=$column1_font_color
        fi
        if [[ flag_c -eq 1 ]]
        then
            color_3=default
        else
            color_3=$column2_background
        fi
        if [[ flag_d -eq 1 ]]
        then
            color_4=default
        else
            color_4=$column2_font_color
        fi

        echo
        echo "Column 1 background = $color_1 ($(color $column1_background))"
        echo "Column 1 font color = $color_2 ($(color $column1_font_color))"
        echo "Column 2 background = $color_3 ($(color $column2_background))"
        echo "Column 2 font color = $color_4 ($(color $column2_font_color))"
    else
        echo "Цвета шрифта и фона одного столбца совпадают"
    fi
else
    echo invalid input
fi
