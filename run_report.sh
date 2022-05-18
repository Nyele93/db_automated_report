#!/bin/bash
#set +x
declare -r intro_info="Starting automated Performance Audit(v1.0) $(date +'%d/%m/%Y %H:%M:%S')"
declare -a details_arr
declare -A full_details
declare -i inst_nos
#declare array to hold instance details: 
declare hosts_array=()
declare -r custom_host_file="custom_deployment_hosts"
declare -r custom_dns_file="custom_dns_file"
declare -r inv_group_name="dbservers"
#echo "enter username";  read uname
#read -p "which program?" prog 
read -s -p "Enter Password: " password
echo
echo $intro_info
echo "-----------------------------------------------------------"

while getopts u:p: option; do
        case $option in 
                u) mariadb_user=$OPTARG;;
                p) mariadb_password=$OPTARG;;
                ?) echo "unknown flag"
        esac
done
#echo "user: $mariadb_user / password: $mariadb_password"
printTableformat(){
    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
        then 
            local -r numberOfLines="$(wc -l <<< "${data}")"
            if [[ "${numberOfLines}" -gt '0' ]]
            then
                local table=''
                local i=1

                for ((i=1; i <= "${numberOfLines}"; i++))
                do
                  local line=''
                  line="$(sed "${i}q;d" <<< "${data}")"

                  local numberOfColumns='0'
                  numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                  #Add Line Delimiter
                  if [[ "${i}" -eq '1' ]]; then
                      table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                  fi
                  #Add Header or Body
                  table="${table}\n"
                  local j=1
                  for((j = 1; j <= "${numberOfColumns}"; j = j+1 ))
                  do
                     table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                  done
                  table="${table}#|\n"
                  #Add line Delimiter
                  if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                  then
                      	table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                  fi
                done
                if [[ "$(isEmptyString "${table}")" = 'false' ]]
                then
                    echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ","-", $0)}1'
                fi
            fi
    fi
}

function removeEmptyLines(){
   local -r  content="${1}"

   echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){
  local -r string="${1}"
  local -r numberToRepeat="${2}"
  
  if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
  then
      local -r result="$(printf "%${numberToRepeat}s")"
      echo -e "${result// /${string}}"
  fi
}

function isEmptyString(){
   local -r string="${1}"
   if [[ "$(trimString "${string}")" = '' ]]
   then
       echo 'true' && return 0
   fi

   echo 'false' && return 1
}

function trimString(){
  local -r string="${1}"
  sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

touch server_details
cat > server_details <<-EOF
S/N,ALIAS,HOST,SSH_USER,SSH_PASSWORD
EOF

touch host_vars.yml
cat > host_vars.yml <<-EOF
---
EOF

begin_report_dynamic(){
read -p "Enter Number of Nodes:" no_instances
if [[ $no_instances -gt 0 ]]; then 
   #echo $?
   #call next program
   for ((i=1; i<=$no_instances; i++))
   do
     	echo
	echo "configure instance: $i"
        #instance_details[alias]
        read -p "alias($i): " alias
        read -p "host($i):  " host
        read -p "ssh_user:  " ssh_user
        unset ssh_password
        unset charcount
        unset inst_no
        inst_no=$i
        charcount=0
        prompt="ssh_password: "
        while IFS= read -s -r -n 1 -p "$prompt" ssh_pwd
        do
	        #take and mask password with * characters
                if [[ $ssh_pwd == $'\0' ]]
                then
                   break
                fi
             #handle Backspaces
                if [[ $ssh_pwd == $'\177' ]]; then
                    if [[ $charcount -gt 0 ]]; then
                        charcount=$((charcount-1))
                        prompt=$'\b \b'
                        ssh_password="${ssh_password%?}"
                    else
                        prompt=''
                    fi
                else
                    charcount=$((charcount+1))
                    prompt='*'
                    ssh_password+="$ssh_pwd"
                fi
        done
  echo "$host"

  hosts_array[$((i-1))]="$host"
declare redacted_pwd=${ssh_password//[a-z0-9]/x}
#line should execute only if using dynamic hosts
cat >> server_details <<-EOF
$inst_no,$alias,$host,$ssh_user,$redacted_pwd
EOF
  done
echo
echo ${hosts_array[@]:0:$i} | sed -e "s/ /,/g"
   printTableformat ',' "$(cat server_details)"
   echo
   read -p "Proceed with running reports on the above servers[Y/N]: "  conf_pr
   if [[ $conf_pr = "y" || $conf_pr = "yes" ]]; then
        echo "Auto Deploying Script.";
   elif [[ $conf_pr = "n" || $conf_pr = "no" ]]; then
   echo "Terminating Program... Bye..."
   fi

else
  echo "[Error] : Please enter a number greater than 0"
fi
}

begin_report_hostFile(){
 echo "choice 2"
}

echo "Choose Option to build target inventory"

select task in  "dynamic" "use_inventory" "quit"
do
  	case $task in 
                dynamic) echo "Selected Option: dynamic"; begin_report_dynamic;;
                use_inventory) echo "Selected Option: read from inventory file"; begin_report_hostFile;;
                quit) break;;
                *) echo "Invalid option";;
        esac
	break
done
