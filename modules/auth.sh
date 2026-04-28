login() {

clear
echo "Login"

read -p "Username: " username
username=${username//$'\r'/}
read -s -p "Password: " password
password=${password//$'\r'/}
echo

user=$(grep "^$username|$password|" data/users.txt)

if [ -z "$user" ]; then
echo -e "\e[31mInvalid Credentials\e[0m"
sleep 2
login
else

role=$(echo "$user" | cut -d"|" -f3 | tr -d '\r')

echo -e "\e[32mLogin Successful ($role)\e[0m"

echo "$(date +"%T") - $username logged in as $role" >> data/logs/log_$(date +%F).txt

sleep 1
fi
}