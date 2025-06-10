input="/etc/hosts"

start_line=$(( $(grep -n "#SLACK_START" $input | cut -f1 -d:) + 1))

end_line=$(( $(grep -n "#SLACK_END" $input | cut -f1 -d:) - 1))

slack_hosts=$(sed -n "$start_line,$end_line p" $input)
printf "#SLACK_START\n"
while IFS= read -r line
do
    set -- $line
    ip=$1
    host=$2
    dnsIps=$(nslookup $host 8.8.8.8 | grep "Address:" | cut -f2 -d:)
    while read -r nsip; do
        if [[ "$nsip" == *"$ip"* ]]; then
            printf "$ip \t $host"
        else
            set -- $nsip
            printf "$2 \t $host"
        fi
    done <<< $dnsIps
    printf "\n"
done <<< "$slack_hosts"
printf "#SLACK_END\n"
