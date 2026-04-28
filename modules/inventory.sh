show_inventory() {
show_panel_title "📦 Inventory Overview" "Current stock, prices, and low-stock alerts"
printf "%-5s %-15s %-12s %-12s %-10s\n" "ID" "Name" "Price" "Cost" "Stock"
echo "------------------------------------------------------"
while IFS="|" read -r id name price stock
do
cost=$(grep "^$id|" data/cost_price.txt | tr -d '\r' | cut -d"|" -f2)
printf "%-5s %-15s %-12s %-12s %-10s\n" "$id" "$name" "$price" "${cost:-N/A}" "$stock"
done < <(tr -d '\r' < data/inventory.txt)
echo
tr -d '\r' < data/inventory.txt | awk -F"|" '$4<10 {print "\033[31m⚠️  Low Stock:",$2,"("$4" left)\033[0m"}'
read
}

add_item() {
show_panel_title "➕ Add New Item(s)" "Grow the cafeteria menu step by step"
echo

while true
do
echo "┌──────────────────── Current Items ────────────────────┐"
while IFS="|" read -r id name price stock
do
printf "  %s - %s\n" "$id" "$name"
done < <(tr -d '\r' < data/inventory.txt)
echo "└───────────────────────────────────────────────────────┘"
echo

read -p "🆔 Item ID: " id
read -p "🍴 Item Name: " name
read -p "💰 Selling Price: " price
read -p "🏷️ Cost Price: " cost
read -p "📦 Quantity: " qty
# Ensure file ends with a newline before appending
[ -s data/inventory.txt ] && sed -i -e '$a\' data/inventory.txt
[ -s data/cost_price.txt ] && sed -i -e '$a\' data/cost_price.txt
echo "$id|$name|$price|$qty" >> data/inventory.txt
echo "$id|$cost" >> data/cost_price.txt
echo "$(date +"%T") - Item Added: $name" >> data/logs/log_$(date +%F).txt
show_message "\e[32m" "✅" "Item '$name' added successfully"
echo

read -p "➕ Add another item? (y/n): " again
again=${again//$'\r'/}
if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
break
fi
echo
done
read
}


edit_item(){
show_panel_title "✏️ Edit Item" "Update existing stock records"
printf "%-5s %-15s %-12s %-12s %-10s\n" "ID" "Name" "Price" "Cost" "Stock"
echo "------------------------------------------------------"
while IFS="|" read -r id name price stock
do
cost=$(grep "^$id|" data/cost_price.txt | tr -d '\r' | cut -d"|" -f2)
printf "%-5s %-15s %-12s %-12s %-10s\n" "$id" "$name" "$price" "${cost:-N/A}" "$stock"
done < <(tr -d '\r' < data/inventory.txt)
echo "------------------------------------------------------"
echo

read -p "🆔 Enter Item ID to edit: " id
id=${id//$'\r'/}
item=$(grep "^$id|" data/inventory.txt | tr -d '\r')
if [ -z "$item" ]; then
show_message "\e[31m" "❌" "Item not found"
read
return
fi
read -p "📝 New Name: " name
read -p "💰 New Price: " price
read -p "📦 New Quantity: " qty
awk -F"|" -v id="$id" -v n="$name" -v p="$price" -v q="$qty" '
BEGIN{OFS="|"}
$1==id {$2=n;$3=p;$4=q}
{print}
' data/inventory.txt > temp && mv temp data/inventory.txt
show_message "\e[32m" "✅" "Item updated successfully"
read
}


delete_item() {
show_panel_title "🗑️ Delete Item" "Remove unwanted stock safely"
printf "%-5s %-15s %-12s %-12s %-10s\n" "ID" "Name" "Price" "Cost" "Stock"
echo "------------------------------------------------------"
while IFS="|" read -r id name price stock
do
cost=$(grep "^$id|" data/cost_price.txt | tr -d '\r' | cut -d"|" -f2)
printf "%-5s %-15s %-12s %-12s %-10s\n" "$id" "$name" "$price" "${cost:-N/A}" "$stock"
done < <(tr -d '\r' < data/inventory.txt)
echo "------------------------------------------------------"
echo

read -p "🆔 Enter ID to delete: " id
id=${id//$'\r'/}
item=$(grep "^$id|" data/inventory.txt | tr -d '\r')
if [ -z "$item" ]; then
show_message "\e[31m" "❌" "Item not found"
read
return
fi
item_name=$(echo "$item" | cut -d"|" -f2)
show_message "\e[33m" "⚠️" "You are about to delete: $item_name (ID: $id)"
read -p "Are you sure? (y/n): " confirm
confirm=${confirm//$'\r'/}
if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
grep -v "^$id|" data/inventory.txt > temp && mv temp data/inventory.txt
grep -v "^$id|" data/cost_price.txt > temp && mv temp data/cost_price.txt
show_message "\e[32m" "✅" "Item '$item_name' deleted successfully"
else
show_message "\e[33m" "ℹ️" "Deletion cancelled"
fi
read
}

inventory_menu() {
while true
do
show_panel_title "📦 Inventory Management" "Choose an action for stock control"
echo "1. 👀 Show Inventory"
echo "2. ➕ Add Item"
echo "3. ✏️ Edit Item"
echo "4. 🗑️ Delete Item"
echo "5. ↩️ Back"
read -p "Choice: " ch
case $ch in
1) show_inventory ;;
2) add_item ;;
3) edit_item ;;
4) delete_item ;;
5) break ;;
esac
done
}