terraform apply -auto-approve
terraform refresh
echo " " > hosts

ip_block=$(terraform output public_ip | grep '[0-9]'| tr -d '"' | tr -d ',') 



# Extract individual IPs from the block (assuming each IP is on a separate line)
# and store them in an array
readarray -t ips <<< "$ip_block"

# Write to file
url="http://localhost:3100/loki/api/v1/push"

# Replace "localhost" with "172.20.20.100"

ip=${ips[0]}
new_url=$(echo "$url" | sed "s/localhost/$ip/g")

# Use sed to replace the last line in the YAML file
sed -i '9 s|.*|  - url: '"$new_url"'|' config.yml

echo "[loki]" > hosts
echo "${ips[0]}" >> hosts  # Append the first IP
echo "[promtail]" >> hosts
for ((i = 1; i < ${#ips[@]}; i++)); do
    echo "${ips[i]}" >> hosts  # Append the remaining IPs
done

ansible-playbook -i hosts playbook.yml
