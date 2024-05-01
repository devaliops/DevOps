#! /bin/bush

generation_ip(){
    local ip_gen="$(shuf -i 1-255 -n 1).$(shuf -i 1-255 -n 1).$(shuf -i 1-255 -n 1).$(shuf -i 1-255 -n 1)"
    echo "$ip_gen"
}

generation_methods(){
    method=("GET" "POST" "PUT" "PATCH" "DELETE")
    local selected_method=$(shuf -e "${method[@]}" -n 1)
    echo "$selected_method"
}

generation_code(){
    code=("200" "201" "400" "401" "403" "404" "500" "501" "502" "503")
    local selected_code=$(shuf -e "${code[@]}" -n 1)
    echo "$selected_code"
}

# RESPONSES
# 200: OK
# 201: Created
# 400: Bad Request
# 401: Unauthorized
# 403: Forbidden
# 404: Not Found
# 500: Internal Server Error
# 501: Not Implemented
# 502: Bad Gateway
# 503: Service Unavailable

generation_agent(){
    agent=("Mozilla" "Google Chrome" "Opera" "Safari" "Internet Explorer" "Microsoft Edge" "Crawler and bot" "Library and net tool")
    local selected_agent=$(shuf -e "${agent[@]}" -n 1)
    echo "$selected_agent"
}

generation_url(){
    url=("/pathto/resource" "/school21/repo" "/school21/readme" "/ru/site.html" "/us/page.php" "/vk.com/profile" "/homepage/page" "website/loginpage" "docs.google/file")
    local selected_url=$(shuf -e "${url[@]}" -n 1)
    echo "$selected_url"
}

for i in {1..5}; do
    log_file="nginx_log_day_${i}.log"
    mkdir -p "log/"
    touch "log/$log_file"
    num=$(shuf -i 100-1000 -n 1)

    for((j = 0; j < num; j++)); do
        date="$(date -d "today -${i} days" "+%d/%b/%Y:%H:%M:%S %z")" 
        echo "$(generation_ip) - - [$date] \"$(generation_methods) $(generation_url) HTTP/1.1\" $(generation_code) 0 \"-\" \"$(generation_agent)\"" >> "log/$log_file"
    done
done

