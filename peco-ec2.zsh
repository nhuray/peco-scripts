# peco-ec2
# Search EC2 instances with peco when pressing ctrl+e.
# Get peco from: https://github.com/peco/peco
#
if which peco &> /dev/null; then

  # Search EC2 instances
 function search_ec2_instances() {
  local jq_query='.Reservations[] | .Instances[] | select(.State.Name != "terminated") | select(has("PublicIpAddress")) | [.InstanceId,.PublicIpAddress,.PrivateIpAddress,.State.Name,(.Tags[] | select(.Key == "Name") | .Value // "")] | join("\t")'
  aws ec2 describe-instances | jq -r $jq_query | sort -u -k5 | peco --prompt 'ec2>'
 }

 # SSH on EC2 instances
 function ssh_on_ec2_instances() {
   local ssh_user=$2
   local ssh_key=$1
   local ip_addresses

   # Default user
   if [ -z ${ssh_user:+x} ]; then ssh_user="ec2-user"; fi
   # Default key
   if [ -z ${ssh_key:+y} ]; then ssh_key="~/.ssh/my_key.pem"; fi

   ip_addresses=$(search_ec2_instances | awk '{ print $2 }' | tr '\n' ' ')

   if [ -n $ip_addresses ]; then
       # echo "ssh  -i ${ssh_key} ${ssh_user}@${ip_addresses}"
       #sh -c "ssh  -i $ssh_key ${ssh_user}@${ip_addresses}"
       sh -c "tmux-cssh -u $ssh_user -i $ssh_key $ip_addresses"
   fi

   zle -N ssh_on_ec2_instances
   bindkey '^S' ssh_on_ec2_instances
}
fi
