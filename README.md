# CUET Cafeteria Management System

A Bash-based terminal application for managing cafeteria operations at CUET. The project covers staff billing, admin-only inventory management, sales reports, backups, and daily operational logging, all from a simple menu-driven interface.

## Features

- Role-based login for `admin` and `staff`
- Billing workflow for staff with live stock deduction
- Inventory management for admins
- Daily profit and admin dashboard reports
- Automatic log creation for key actions
- Backup generation for sales, bills, logs, inventory, cost, and user data
- Clean terminal UI with framed sections and status messages

## Project Structure

```text
main.sh
modules/
  auth.sh
  billing.sh
  inventory.sh
  reports.sh
data/
  users.txt
  inventory.txt
  cost_price.txt
  sales/
  logs/
  bills/
  backup/
```

## Requirements

- Bash shell
- Core Unix utilities: `grep`, `awk`, `sed`, `cut`, `tee`, `cp`
- On Windows, use **Git Bash** or **WSL** to run the project

## How to Run

1. Open a terminal in the project root.
2. Start the application with:

```bash
bash main.sh
```

3. Log in with a valid user from `data/users.txt`.

The application will create the required `data/` folders and daily log/sales files automatically if they do not exist.

## First-Time Setup

If you want to reset or prepare the project manually, make sure these files exist in `data/`:

- `users.txt`
- `inventory.txt`
- `cost_price.txt`

The app will populate the daily output folders as needed:

- `data/sales/`
- `data/logs/`
- `data/bills/`
- `data/backup/`

## Main Menu

After login, the app provides these options:

- Billing for staff users
- Inventory management for admins
- Daily profit reports for admins
- Admin dashboard summary
- Backup creation
- Exit

## Role Permissions

- `staff`: billing only
- `admin`: billing, inventory management, reports, admin dashboard, and backups

## Data and Output Files

The project stores its working data in plain text files:

- `data/users.txt` stores login accounts and roles
- `data/inventory.txt` stores item ID, name, price, and stock
- `data/cost_price.txt` stores item cost values
- `data/sales/` stores daily sales transactions
- `data/logs/` stores activity logs
- `data/bills/` stores generated bills and invoices
- `data/backup/` stores dated backups created from the app

## Backup Behavior

The backup feature creates a dated folder such as:

```text
data/backup/backup_YYYY-MM-DD/
```

It copies:

- sales data
- log files
- bill and invoice files
- inventory and cost files
- user data

## Notes

- The project is designed for terminal use, not a web browser.
- If you edit the data files manually, keep the `|` separated format intact.
- The app strips Windows carriage returns from its text files on startup to stay compatible across platforms.

## Suggested Improvement Areas

- Add input validation for numeric fields
- Store data in a database for larger deployments
- Add searchable item lookup during billing
- Add profit summaries by week and month
