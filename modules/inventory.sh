show_inventory() {
clear
printf "%-5s %-15s %-12s %-12s %-10s\n" "ID" "Name" "Price" "Cost" "Stock"
echo "------------------------------------------------------"
while IFS="|" read -r id name price stock
do
cost=$(grep "^$id|" data/cost_price.txt | tr -d '\r' | cut -d"|" -f2)
printf "%-5s %-15s %-12s %-12s %-10s\n" "$id" "$name" "$price" "${cost:-N/A}" "$stock"
done < <(tr -d '\r' < data/inventory.txt)
echo
tr -d '\r' < data/inventory.txt | awk -F"|" '$4<10 {print "\033[31mLow Stock:",$2,"("$4" left)\033[0m"}'
}

add_item() {
clear
echo "Add New Item(s)"
echo

while true
do
echo "--- Current Items ---"
while IFS="|" read -r id name price stock
do
printf "  %s - %s\n" "$id" "$name"
done < <(tr -d '\r' < data/inventory.txt)
echo "---------------------"
echo

read -p "Item ID: " id
read -p "Item Name: " name
read -p "Selling Price: " price
read -p "Cost Price: " cost
read -p "Quantity: " qty
# Ensure file ends with a newline before appending
[ -s data/inventory.txt ] && sed -i -e '$a\' data/inventory.txt
[ -s data/cost_price.txt ] && sed -i -e '$a\' data/cost_price.txt
echo "$id|$name|$price|$qty" >> data/inventory.txt
echo "$id|$cost" >> data/cost_price.txt
echo "$(date +"%T") - Item Added: $name" >> data/logs/log_$(date +%F).txt
echo -e "\e[32mItem '$name' added successfully\e[0m"
echo

read -p "Add another item? (y/n): " again
again=${again//$'\r'/}
if [ "$again" != "y" ] && [ "$again" != "Y" ]; then
break
fi
echo
done
read
}


edit_item(){
clear
echo "--- Current Inventory ---"
printf "%-5s %-15s %-12s %-12s %-10s\n" "ID" "Name" "Price" "Cost" "Stock"
echo "------------------------------------------------------"
while IFS="|" read -r id name price stock
do
cost=$(grep "^$id|" data/cost_price.txt | tr -d '\r' | cut -d"|" -f2)
printf "%-5s %-15s %-12s %-12s %-10s\n" "$id" "$name" "$price" "${cost:-N/A}" "$stock"
done < <(tr -d '\r' < data/inventory.txt)
echo "------------------------------------------------------"
echo

read -p "Enter Item ID to edit: " id
id=${id//$'\r'/}
item=$(grep "^$id|" data/inventory.txt | tr -d '\r')
if [ -z "$item" ]; then
echo "Item not found"
read
return
fi
read -p "New Name: " name
read -p "New Price: " price
read -p "New Quantity: " qty
awk -F"|" -v id="$id" -v n="$name" -v p="$price" -v q="$qty" '
BEGIN{OFS="|"}
$1==id {$2=n;$3=p;$4=q}
{print}
' data/inventory.txt > temp && mv temp data/inventory.txt
echo "Item Updated Successfully"
read
}


delete_item() {
clear
echo "--- Current Inventory ---"
printf "%-5s %-15s %-12s %-12s %-10s\n" "ID" "Name" "Price" "Cost" "Stock"
echo "------------------------------------------------------"
while IFS="|" read -r id name price stock
do
cost=$(grep "^$id|" data/cost_price.txt | tr -d '\r' | cut -d"|" -f2)
printf "%-5s %-15s %-12s %-12s %-10s\n" "$id" "$name" "$price" "${cost:-N/A}" "$stock"
done < <(tr -d '\r' < data/inventory.txt)
echo "------------------------------------------------------"
echo

read -p "Enter ID to delete: " id
id=${id//$'\r'/}
item=$(grep "^$id|" data/inventory.txt | tr -d '\r')
if [ -z "$item" ]; then
echo "Item not found"
read
return
fi
item_name=$(echo "$item" | cut -d"|" -f2)
echo -e "\e[33mYou are about to delete: $item_name (ID: $id)\e[0m"
read -p "Are you sure? (y/n): " confirm
confirm=${confirm//$'\r'/}
if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
grep -v "^$id|" data/inventory.txt > temp && mv temp data/inventory.txt
grep -v "^$id|" data/cost_price.txt > temp && mv temp data/cost_price.txt
echo -e "\e[32mItem '$item_name' deleted successfully\e[0m"
else
echo "Deletion cancelled"
fi
read
}

inventory_menu() {
while true
do
clear
echo "Inventory Management"
echo "1. Show Inventory"
echo "2. Add Item"
echo "3. Edit Item"
echo "4. Delete Item"
echo "5. Back"
read ch
case $ch in
1) show_inventory; read ;;
2) add_item ;;
3) edit_item ;;
4) delete_item ;;
5) break ;;
esac
done
}