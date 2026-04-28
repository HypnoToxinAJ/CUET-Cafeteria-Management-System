#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

print_border() {
    local width=${1:-54}
    local char=${2:-=}
    printf '+'
    printf '%s' "$(printf '%*s' "$width" '' | tr ' ' "$char")"
    printf '+\n'
}

print_footer() {
    local width=${1:-54}
    local char=${2:-=}
    printf '+'
    printf '%s' "$(printf '%*s' "$width" '' | tr ' ' "$char")"
    printf '+\n'
}

show_banner() {
    clear
    print_border 54
    printf '| %-52s |\n' "CUET CAFETERIA MANAGEMENT SYSTEM"
    printf '| %-52s |\n' "Fresh orders, clean inventory, instant reports"
    print_footer 54
    echo -e "${CYAN}🍽️  Serving smart cafeteria operations with style${RESET}"
    echo
}

show_panel_title() {
    local title="$1"
    local subtitle="$2"
    clear
    print_border 54
    printf '| %-52s |\n' "$title"
    [ -n "$subtitle" ] && printf '| %-52s |\n' "$subtitle"
    print_footer 54
}

show_message() {
    local color="$1"
    local icon="$2"
    local text="$3"
    echo -e "${color}${icon} ${text}${RESET}"
}

mkdir -p data/sales data/logs data/backup data/bills modules

touch data/users.txt
touch data/inventory.txt
touch data/cost_price.txt
touch data/sales/sales_$(date +%F).txt
touch data/logs/log_$(date +%F).txt

# Strip Windows carriage returns from all data/bill files
for f in data/*.txt data/sales/*.txt data/bills/*.txt; do
    [ -f "$f" ] && sed -i 's/\r$//' "$f"
done

source modules/auth.sh
source modules/inventory.sh
source modules/billing.sh
source modules/reports.sh

log_action() {
echo "$(date +"%T") - $1" >> data/logs/log_$(date +%F).txt
}

backup_data() {
backup_dir="data/backup/backup_$(date +%F)"
mkdir -p "$backup_dir"
cp -r data/sales "$backup_dir/"
cp -r data/logs "$backup_dir/"
cp -r data/bills "$backup_dir/"
cp data/inventory.txt "$backup_dir/"
cp data/cost_price.txt "$backup_dir/"
cp data/users.txt "$backup_dir/"
echo -e "${GREEN}Backup Created Successfully at: $backup_dir${RESET}"
log_action "Backup created"
read
}

main_menu() {
while true
do

show_banner

echo "1. 🍔 Billing (Staff)"
echo "2. 📦 Inventory Management (Admin)"
echo "3. 📊 Reports (Admin)"
echo "4. 🧭 Admin Dashboard"
echo "5. 💾 Backup"
echo "6. 🚪 Exit"

read -p "Choice: " ch

case $ch in

1) billing_menu ;;

2)
if [ "$role" = "admin" ]; then
inventory_menu
else
echo -e "${RED}Access Denied: Admin Only${RESET}"
sleep 2
fi
;;

3)
if [ "$role" = "admin" ]; then
reports_menu
else
echo -e "${RED}Access Denied: Admin Only${RESET}"
sleep 2
fi
;;

4)
if [ "$role" = "admin" ]; then
admin_dashboard
else
echo -e "${RED}Access Denied: Admin Only${RESET}"
sleep 2
fi
;;

5)
if [ "$role" = "admin" ]; then
backup_data
else
echo -e "${RED}Access Denied: Admin Only${RESET}"
sleep 2
fi
;;

6) exit ;;

esac

done
}

login
main_menu