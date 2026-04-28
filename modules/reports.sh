admin_dashboard(){

clear

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

echo "================================"
echo "         ADMIN DASHBOARD        "
echo "================================"

echo "Total Orders : $orders"
echo "Total Sales  : $sales Taka"
echo "Daily Profit : $profit Taka"

echo
read
}



daily_profit_report() {

clear

sales_file="data/sales/sales_$(date +%F).txt"

if [ ! -f "$sales_file" ]; then
echo "No sales today."
read
return
fi

echo "=============================================="
echo "        CUET CAFETERIA DAILY PROFIT REPORT    "
echo "=============================================="

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
clear

echo "================================"
echo "          REPORT MENU           "
echo "================================"

echo "1. Daily Profit Report"
echo "2. Back"

read -p "Choice: " ch

case $ch in
1) daily_profit_report ;;
2) break ;;
esac

done

}