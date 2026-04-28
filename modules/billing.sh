billing_menu() {

show_panel_title "🧾 Billing Counter" "Pick items, confirm quantities, and generate an invoice"

bill_id=$(date +%s)
bill_file="data/bills/bill_$bill_id.txt"

total_bill=0

printf "%-8s %-18s %-10s %-10s\n" "ID" "Item" "Price" "Stock"
echo "----------------------------------------------"

while IFS="|" read -r id name price stock
do
printf "%-8s %-18s %-10s %-10s\n" "$id" "$name" "$price" "$stock"
done < <(tr -d '\r' < data/inventory.txt)

echo "----------------------------------------------"
echo "Enter Item ID and Quantity (0 to finish)"
echo

while true
do

read -p "🆔 Item ID: " id
id=${id//$'\r'/}

if [ "$id" == "0" ]; then
break
fi

read -p "📦 Quantity: " qty
qty=${qty//$'\r'/}

item=$(grep "^$id|" data/inventory.txt)

if [ -z "$item" ]; then
show_message "\e[31m" "❌" "Invalid item ID"
continue
fi

item=$(echo "$item" | tr -d '\r')
name=$(echo "$item" | cut -d"|" -f2)
price=$(echo "$item" | cut -d"|" -f3)
stock=$(echo "$item" | cut -d"|" -f4)

if [ "$qty" -gt "$stock" ]; then
show_message "\e[33m" "⚠️" "Not enough stock for $name"
continue
fi

item_total=$((price * qty))
total_bill=$((total_bill + item_total))

printf "%-10s %-10s %-10s %-10s\n" "$name" "$qty" "$price" "$item_total" >> "$bill_file"

new_stock=$((stock - qty))

awk -F"|" -v id="$id" -v ns="$new_stock" 'BEGIN{OFS="|"} $1==id{$4=ns} {print}' data/inventory.txt > temp && mv temp data/inventory.txt

echo "$bill_id|$id|$qty|$item_total" >> data/sales/sales_$(date +%F).txt

show_message "\e[32m" "✅" "$name added to the bill"

done

generate_invoice "$bill_file" "$total_bill" "$bill_id"

echo "$(date +"%T") - Bill Generated: $bill_id - $total_bill" >> data/logs/log_$(date +%F).txt

read
}


generate_invoice() {

bill_file=$1
total=$2
bill_id=$3

invoice_file="data/bills/invoice_$bill_id.txt"

clear

# Build invoice content
{
echo "╔══════════════════════════════════════╗"
echo "║        CUET Cafeteria Invoice        ║"
echo "╚══════════════════════════════════════╝"
echo "Bill ID : $bill_id"
echo "Date    : $(date)"
echo "--------------------------------------"
printf "%-10s %-10s %-10s %-10s\n" "Item" "Qty" "Price" "Total"
echo "--------------------------------------"
cat "$bill_file"
echo "--------------------------------------"
echo "TOTAL AMOUNT: $total Taka"
echo "--------------------------------------"
echo "Thank you for visiting CUET Cafeteria 🍽️"
echo "╚══════════════════════════════════════╝"
} | tee "$invoice_file"

echo
show_message "\e[32m" "✅" "Invoice saved at: $invoice_file"

}