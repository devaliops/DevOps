#! /bin/bash
# ------------------- CONSTANT VALUES ------------------------
# number_of_folders=$1
characters_for_folders=$1
characters_for_files=$2
size=$3
min_free_space=1
max_acceptable_file_size=100
max_subfolders=100
max_number_of_repetiton=30
max_len_of_absolute_way=255
# max_number_of_files_in_folder=10
start_folder="/"
# ------------------------------------------------------------
# ---------------- PARAMETERS FOR GENERATION -----------------
get_parameters() {
    data=$(date +"%d%m%y")
    len=${#characters_for_folders}
    counter=0
    free_space=$(df -hBG / | tail -n 1 | awk '{print $4}' | rev | cut -c 2- | rev)
}
# ------------------------------------------------------------

# ------------------ CHECKS ON INPUT -------------------------
check_input() {
 if [ -z "$characters_for_folders" ];
    then echo "Empty list of characters for folder names" && exit 1
    fi

    if [ -z "$characters_for_files" ];
    then echo "Empty list of characters for file names" && exit 1
    fi

    if [ -z "$file_str" ];
    then echo "Empty list of characters for file names" && exit 1
    fi

    if [ -z "$ext_str" ];
    then echo "Empty list of characters for file extension" && exit 1
    fi

    if [ ${#characters_for_folders} -gt 7 ];
    then echo "Too much symbols for name of folders" && exit 1
    fi

    if [ ${#file_str} -gt 7 ]
    then echo "Too much symbols for name of files" && exit 1
    fi

    if [ ${#ext_str} -gt 3 ]
    then echo "Too much symbols for extension of files" && exit 1
    fi

    if [ -z "$size" ];
    then echo "Enter the size as 5th argument." && exit 1
    fi

    size_in_number=$(echo $size | rev | cut -c 3- | rev)
    if [ $size_in_number -gt $max_acceptable_file_size ];
    then 
    echo "The size enormous. Max size of generated file is 100Mb." && exit 1
    fi

    digits_regex='^[0-9]+$'
    if ! [[ $size_in_number =~ $digits_regex ]];
    then 
    echo "The size (3d parameter) unappropriate. It must be non-negative number." &&  exit 1
    fi

    size_extension=$(echo $size | rev | cut -c -2 | rev)
    if [ "$size_extension" != "Mb" ];
    then 
    echo "Please enter the size ended on 'Mb', e.g. 10Mb." && exit 1
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
    local folder="$1"
    file_counter=0
    file_name="${folder}${characters_for_files}_${data}.$ext_str"
    if [ ! -f $file_name ]; then 
        # dd if=/dev/zero of=$file_name  bs="${size_in_number}M"  count=1 
        sudo fallocate -l $size $file_name && file_counter=1 &&
        echo "$file_name $data $size" >> "access.log"
    fi
    get_match_str_for_files
    tail_len=$((8+${#ext_str}))
    local max_attempts=10
    local attempt=0
    while [[ $free_space > $min_free_space && $attempt < $max_attempts ]];
    do
        slider=0
        attempt=$(($attempt+1))
        while [[ $slider < $char_len ]];
        do
            for char_str in $(find $folder -type f -name $match_str);
            do
                # number_of_files=$(($RANDOM%$max_number_of_files_in_folder))
                number_of_files=$RANDOM
                if [ $file_counter -lt $number_of_files ];
                then  
                    preambule_len=$((${#char_str}-$char_len-$tail_len))
                    tail_=$(($char_len-$slider))
                    file_name="${char_str:0:$((slider+1+preambule_len))}${char_str:$((slider+preambule_len)):$tail_}_${data}.$ext_str"                  
                    if [ ! -f $file_name ]; then 
                        sudo touch $file_name && sudo chmod 777 $file_name
                        sudo fallocate -l $size $file_name &&
                        file_counter=$(($file_counter+1)) &&
                        echo "$file_name $data $size" >> "access.log"
                        free_space=$(df -hBG / | tail -n 1 | awk '{print $4}' | rev | cut -c 2- | rev)
                        echo "FREE SPACE: $free_space"
                    fi
                fi
            done;
            slider=$(($slider+1))
        done
        match_str="?$match_str"
        char_len=$(($char_len+1))
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
generate_subfolder_name() {
    cur_subfolder_name=""
    number_of_repeted_symbols=$(($RANDOM%${#characters_for_folders}))
    str_repeated_slider=0 && rest_symbols=${#characters_for_folders}
    max_aceptable_subfolder_len=$(($max_len_of_absolute_way-${#folder_name}-1))
    while [ $str_repeated_slider -lt ${#characters_for_folders} ]
    do
        repeatiton_choice=$(($RANDOM%2))
        rest_len_for_subfolder=$(($max_aceptable_subfolder_len-$rest_symbols))
        if [ $repeatiton_choice -eq 1 ] && [ $str_repeated_slider -lt $number_of_repeted_symbols ] && [ ${#cur_subfolder_name} -lt $rest_len_for_subfolder ]; 
        then number_of_repetiton=$(($RANDOM%$max_number_of_repetiton+1))
        else number_of_repetiton=1
        fi
        repeated_symbol="${characters_for_folders:str_repeated_slider:1}" && char_repeated_slider=0
        while [ $char_repeated_slider -lt $number_of_repetiton ]
        do cur_subfolder_name="$cur_subfolder_name$repeated_symbol" && char_repeated_slider=$(($char_repeated_slider+1))
        done
        str_repeated_slider=$(($str_repeated_slider+1))
        rest_symbols=$(($rest_symbols-1))
    done
    cur_subfolder_name="${cur_subfolder_name}_$data/"
}
generate_folder() {
    folder_name=$start_folder
    subfolder_number=$(($RANDOM%$max_subfolders+1))
    subfolder_counter=0
    max_acceptable_folder_len=$((($max_len_of_absolute_way-${#start_folder}-${#data}-${#file_str}-${#ext_str}-1) / 2))
    while [ $subfolder_counter -lt $subfolder_number ] && [ ${#folder_name} -lt $max_acceptable_folder_len ]
    do
        generate_subfolder_name
        folder_name="$folder_name$cur_subfolder_name"
        if [ $subfolder_counter -eq 0 ];
        then
            if [ "$folder_name" = "/sbin/" ] || [ "$folder_name" = "/bin/" ];
                then folder_name="${folder_name:0:2}${folder_name:1:$((${#folder_name}-1))}"
            fi
        fi
        if [ ! -d $folder_name ]; then
            echo "$folder_name $data" >> "access.log"
        fi
        subfolder_counter=$(($subfolder_counter+1))
    done
} 
main_process() {
    free_space=$(df -h / | tail -n 1 | awk '{print $4}')
    echo "Free space is $free_space at the start."
    get_parameters
    get_characters_for_files
    check_input
    check_str_len
    sudo rm -f "access.log" && sudo touch "access.log" && sudo chmod 777 "access.log"
    characters_for_files=$file_str
    len=${#characters_for_folders}
    counter=0
    while [[ $free_space > $min_free_space ]];
    do
        i=0
        generate_folder
        if [ ! -d $folder_name ]; then
            sudo mkdir -p "$folder_name" && sudo chmod 777 $folder_name && counter=$(($counter+1)) &&
            echo "$folder_name $data" >> "access.log" && file_generator "$folder_name"
        fi
    done
    free_space=$(df -h / | tail -n 1 | awk '{print $4}')
    echo "Free space is $free_space at the end."
}

sudo touch output.txt; sudo chmod 777 output.txt
main_process 2> output.txt