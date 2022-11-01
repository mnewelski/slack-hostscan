input="/etc/hosts"

# locate line "#SLACK_START"
start_line=$(( $(grep -n "#SLACK_START" $input | cut -f1 -d:) + 1))

# locate line "#SLACK_END"
end_line=$(( $(grep -n "#SLACK_END" $input | cut -f1 -d:) - 1))

# store filtered list of hosts (between $start_line and $end_line)
slack_hosts=$(sed -n "$start_line,$end_line p" $input)
printf "#SLACK_START\n"
while IFS= read -r line
do
    set -- $line
    ip=$1
    host=$2
    printf "$ip \t $host"
    dnsIps=$(nslookup $host 8.8.8.8 | grep "Address:" | cut -f2 -d:)
    while read -r nsip; do
        if [[ "$nsip" == *"$ip"* ]]; then
            printf " \xE2\x9C\x94"
        else
            set -- $nsip
            printf " \xE2\x9D\x8C "
        fi
    done <<< $dnsIps
    printf "\n"
done <<< "$slack_hosts"
printf "#SLACK_END\n"
