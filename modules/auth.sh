login() {

show_panel_title "🔐 Login" "Enter your credentials to continue"

read -p "👤 Username: " username
username=${username//$'\r'/}
read -s -p "🔒 Password: " password
password=${password//$'\r'/}
echo

user=$(grep "^$username|$password|" data/users.txt)

if [ -z "$user" ]; then
show_message "\e[31m" "❌" "Invalid credentials"
sleep 2
login
else

role=$(echo "$user" | cut -d"|" -f3 | tr -d '\r')

show_message "\e[32m" "✅" "Login successful ($role)"

echo "$(date +"%T") - $username logged in as $role" >> data/logs/log_$(date +%F).txt

sleep 1
fi
}