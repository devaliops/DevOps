#! /bin/bash
# ------------------- CONSTANT VALUES ------------------------
location="$1"
number_of_folders=$2
characters_for_folders=$3
number_of_files=$4
characters_for_files=$5
size=$6
min_free_space=1
max_acceptable_file_size=100
# ------------------------------------------------------------
# ---------------- PARAMETERS FOR GENERATION -----------------
get_parameters() {
    data=$(date +"%d%m%y")
    len=${#characters_for_folders}
    counter=0
    free_space=$(df -h / | tail -n 1 | awk '{print $4}' | rev | cut -c 3- | rev)
}
# ------------------------------------------------------------

# ------------------ CHECKS ON INPUT -------------------------
check_input() {
 if [ -z "$characters_for_folders" ];
    then echo "Empty list of characters for folder names" && exit 0
    fi

    if [ -z "$characters_for_files" ];
    then echo "Empty list of characters for file names" && exit 0
    fi

    if [ -z "$file_str" ];
    then echo "Empty list of characters for file names" && exit 0
    fi

    if [ -z "$ext_str" ];
    then echo "Empty list of characters for file extension" && exit 0
    fi

    if [ $number_of_folders -le 0 ];
    then echo "Enter posiive number for number of folders" && exit 0
    fi

    if [ $number_of_files -le 0 ];
    then echo "Enter a positive number for number of files" && exit 0
    fi

    if [ ${#characters_for_folders} -gt 7 ];
    then echo "Too much symbols for name of folders" && exit 0
    fi

    if [ ${#file_str} -gt 7 ]
    then echo "Too much symbols for name of files" && exit 0
    fi

    if [ ${#ext_str} -gt 3 ]
    then echo "Too much symbols for extension of files" && exit 0
    fi

    if [ "${location:0:1}" != "/" ];
    then echo "Specify an absolute path, not a relative one." && exit 0
    fi

    if [ -z "$size" ];
    then echo "Enter the size as 6th argument." && exit 0
    fi

    if [ $size -gt $max_acceptable_file_size ];
    then 
    echo "The size enormous. It will be used 100kb as the size of generated files." && size=100
    fi

    if [ $size -le 0 ];
    then 
    echo "The size unappropriate." &&  exit 0
    fi
}
check_str_len() {
    if [ ${#characters_for_folders} -lt 4 ];
    then
        if [ ${#characters_for_folders} -eq 1 ]
        then a="$characters_for_folders" && characters_for_folders="$a$a$a$a"
        fi 
        if [ ${#characters_for_folders} -eq 2 ]
        then a="${characters_for_folders:0:1}" && characters_for_folders="$a$characters_for_folders"
             a="${characters_for_folders:2:1}" && characters_for_folders="$characters_for_folders$a"
        fi 
        if [ ${#characters_for_folders} -eq 3 ]
        then a=${characters_for_folders:0:1} && characters_for_folders="$a$characters_for_folders"
        fi 
    fi
    if [ ${#file_str} -lt 4 ];
    then
        if [ ${#characters_for_folders} -eq 1 ]
        then a="$file_str" && file_str="$a$a$a$a"
        fi 
        if [ ${#file_str} -eq 2 ]
        then a="${file_str:0:1}" && file_str="$a$file_str"
             a="${file_str:2:1}" && file_str="$file_str$a"
        fi 
        if [ ${#file_str} -eq 3 ]
        then a=${file_str:0:1} && file_str="$a$file_str"
        fi 
    fi
}
# ------------------------------------------------------------

# --------------------- FILE GENERATOR -----------------------

get_match_str_for_files() {
    match_str="_$data.$ext_str"
    j=0
    while [ $j -lt ${#characters_for_files} ]
    do
        match_str="?$match_str" && j=$(($j+1))
    done
}
file_generator() {
    data=$(date +"%d%m%y")
    char_len=${#characters_for_files}
    char_location="$1"
    file_counter=0
    file_name="${char_location}/${characters_for_files}_${data}.$ext_str"
    if [ ! -f $file_name ]; then 
        sudo touch $file_name && sudo chmod 777 $file_name
        dd if=/dev/zero of=$file_name  bs="${size}K"  count=1 && file_counter=1 &&
        echo "$file_name $data $size" >> "access.log"
    fi
    get_match_str_for_files
    tail_len=$((8+${#ext_str}))
    while [[ $file_counter < $number_of_files && $free_space > $min_free_space ]];
    do
        slider=0
        while [ $slider -lt $char_len ] && [ $file_counter -lt $number_of_files ]
        do
            for char_str in $(find $char_location -type f -name $match_str);
            do
                if [ $file_counter -lt $number_of_files ];
                then            
                    preambule_len=$((${#char_str}-$char_len-$tail_len))
                    tail_=$(($char_len-$slider))
                    file_name="${char_str:0:$((slider+1+preambule_len))}${char_str:$((slider+preambule_len)):$tail_}_${data}.$ext_str"                  
                    if [ ! -f $file_name ]; then 
                        sudo touch $file_name && sudo chmod 777 $file_name
                        dd if=/dev/zero of=$file_name  bs="${size}K"  count=1 && file_counter=$(($file_counter+1)) &&
                        echo "$file_name $data $size" >> "access.log"
                    fi
                fi
            done;
            slider=$(($slider+1))
        done
        match_str="?$match_str"
        char_len=$(($char_len+1))
        free_space=$(df -h / | tail -n 1 | awk '{print $4}' | rev | cut -c 3- | rev)
    done
}
# ------------------------------------------------------------

# ------ MAIN FUNCTION OF FILES AND FOLDERS GENERATION -------

# FOLDERS GENERATION

get_match_str_for_folders() {
    j=0
    folder_match_str="_$data"
    while [ $j -lt ${#characters_for_folders} ]
    do
    folder_match_str="?$folder_match_str" && j=$(($j+1))
    done
}
get_characters_for_files() {
    character_str_slider=0
    sep="." && ext_str="" && file_str="" && sep_point=${#characters_for_files}
    while [ $character_str_slider -lt ${#characters_for_files} ]
    do 
        symbol="${characters_for_files:character_str_slider:1}"
        if [ "$symbol" = "$sep" ]; then sep_point=$character_str_slider
        fi
        if [ $character_str_slider -gt $sep_point ]; then ext_str="${ext_str}$symbol" 
        fi
        if [ $character_str_slider -lt $sep_point ]; then file_str="${file_str}$symbol" 
        fi
        character_str_slider=$(($character_str_slider+1))
    done
}
main_process() {
    get_parameters
    get_characters_for_files
    check_input
    check_str_len
    sudo rm -f "access.log" && sudo touch "access.log" && sudo chmod 777 access.log
    characters_for_files=$file_str
    len=${#characters_for_folders}
    folder_name="$location/${characters_for_folders}_$data"
    if [ ! -d $folder_name ]; then
        sudo mkdir -p "$folder_name" && sudo chmod 777 $folder_name && counter=1
        echo "$folder_name $data" >> "access.log"
    fi
    file_generator "$folder_name"
    get_match_str_for_folders
    while [[ $counter < $number_of_folders && $free_space > $min_free_space ]];
    do
        i=0
        while [[ $i < $len && $counter < $number_of_folders ]];
        do
            for str in $(find $location -type d -name $folder_match_str);
            do
                if [[ $counter < $number_of_folders && $free_space > $min_free_space ]];
                then            
                    preambule_len=$((${#str}-$len-7))
                    tail_len=$(($len-$i))
                    folder_name="${str:0:$((i+1+preambule_len))}${str:$((i+preambule_len)):$tail_len}_$data"
                    if [ ! -d $folder_name ]; then
                        sudo mkdir -p $folder_name && sudo chmod 777 $folder_name && counter=$(($counter+1)) &&
                        echo "$folder_name $data" >> "access.log" && file_generator "$folder_name"
                    fi
                    free_space=$(df -h / | tail -n 1 | awk '{print $4}' | rev | cut -c 3- | rev)
                fi
            done; i=$(($i+1))
        done
        folder_match_str="?$folder_match_str" && len=$(($len+1))
    done
}

sudo touch output.txt; sudo chmod 777 output.txt
main_process 2> output.txt