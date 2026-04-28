admin_dashboard(){

show_panel_title "🧭 Admin Dashboard" "Daily overview of orders, sales, and profit"

sales_file="data/sales/sales_$(date +%F).txt"

orders=$(wc -l < "$sales_file")

sales=$(awk -F"|" '{sum+=$4} END{print sum}' "$sales_file")

profit=$(awk -F"|" -v inv="data/inventory.txt" -v cost="data/cost_price.txt" '
BEGIN{
    while((getline < inv)>0){split($0,a,"|"); sp[a[1]]=a[3]}
    while((getline < cost)>0){split($0,b,"|"); cp[b[1]]=b[2]}
}
{sum += (sp[$2] - cp[$2]) * $3}
END{print sum+0}
' "$sales_file")

echo "📦 Total Orders : $orders"
echo "💰 Total Sales  : $sales Taka"
echo "📈 Daily Profit : $profit Taka"

echo
read
}



daily_profit_report() {

show_panel_title "📊 Daily Profit Report" "See item-level profit for today"

sales_file="data/sales/sales_$(date +%F).txt"

if [ ! -f "$sales_file" ]; then
show_message "\e[33m" "ℹ️" "No sales today."
read
return
fi

printf "%-15s %-10s %-12s %-10s\n" "Item" "Sold" "Profit/Item" "Profit"
echo "------------------------------------------------"

awk -F"|" -v inv="data/inventory.txt" -v cost="data/cost_price.txt" '

BEGIN{

while((getline < inv)>0){
split($0,a,"|")
price[a[1]]=a[3]
name[a[1]]=a[2]
}

while((getline < cost)>0){
split($0,b,"|")
costp[b[1]]=b[2]
}

}

{
qty[$2]+=$3
}

END{

total_profit=0

for(i in qty){

profit_per_item = price[i] - costp[i]
profit = profit_per_item * qty[i]
total_profit += profit

printf "%-15s %-10s %-12s %-10s\n",name[i],qty[i],profit_per_item,profit
}

print "------------------------------------------------"
print "Total Profit Today:", total_profit,"Taka"

}
' $sales_file

echo
read
}

reports_menu(){

while true
do
show_panel_title "📑 Reports Menu" "Choose a report to inspect performance"

echo "1. 📊 Daily Profit Report"
echo "2. ↩️ Back"

read -p "Choice: " ch

case $ch in
1) daily_profit_report ;;
2) break ;;
esac

done

}