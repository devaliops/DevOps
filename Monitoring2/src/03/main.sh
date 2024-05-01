#!/bin/bash
choice=$1
location="/"

if [ $choice -eq 1 ];
then access_log=$2
fi

if [ $choice -eq 2 ];
then 
    start_date=$2 && start_minute=$3 && end_date=$4 && end_minute=$5
    start_time="$start_date $start_minute"
    end_time="$end_date $end_minute"
fi

error_log() {
    echo "Incorrect input. You can choose:"
    echo "1 - clean system by log file. And enter path to log file as the 2nd parameter."
    echo "2 - clean system by creation date and time. Example: bash main.sh 2 'YYYY-MM-DD HH:MM' (like '2023-04-16 13:13')"
    echo "3 - clean system by name mask. And enter name mask ()."
}

check_input() {
    if [ -z $choice ];
    then error_log && exit 1
    fi

    check='^[123]$'
    if ! [[ $choice =~ $check ]];
    then 
        error_log && exit 1
    fi

}

main_process() {
    check_input
    # 4 и более символов - буквы A-Za-z, далее _, затем дата корректного формата:
    check_folder='(/[A-Za-z]{4,}_(0[1-9]|[12][0-9]|3[01])(0[1-9]|1[0-2])2[23]){1,}'

    if [ $choice -eq 1 ];
    then
        while read y
        do
        element_for_deletion=$(echo "$y" | awk '{print $1}')
        echo "Folder/file $element_for_deletion will be deleted."
        sudo rm -rf "$element_for_deletion"
        done < $access_log
    fi

    if [ $choice -eq 2 ];
    then
        regex_date_format="202[23]-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):([0-5][0-9])"
        if [[ $start_time =~ $regex_date_format ]] && [[ $end_time =~ $regex_date_format ]];
        then
            data_for_deletion=$(find $location -newermt "$start_time" ! -newermt "$end_time" | grep -E $check_folder)
            for element_for_deletion in $data_for_deletion;
            do
                echo "Folder/file $element_for_deletion will be deleted."
                rm -rf "$element_for_deletion"
            done
        else
            echo "Incorrect date/time format. Please, try again in format 'YYYY-MM-DD HH:MM' 'YYYY-MM-DD HH:MM'"
        fi    
    fi

    if [ $choice -eq 3 ];
    then
        data_for_deletion=$(find $location -type d | grep -E $check_folder)
        for element_for_deletion in $data_for_deletion;
        do
            echo "Folder/file $element_for_deletion will be deleted."
            sudo rm -rf $element_for_deletion 
        done
    fi
}

sudo touch output.txt; sudo chmod 777 output.txt
main_process 2> output.txt