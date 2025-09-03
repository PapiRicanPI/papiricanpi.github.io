#!/bin/zsh
set -euo pipefail

VAULT="${HOME}/Documents/PovertyPimpsVault"
SCRIPTS="${VAULT}/Scripts"

# Ensure Scripts dir
mkdir -p "$SCRIPTS"

menu() {
  echo ""
  echo "===== TRUTHBOT ZERO — HUB BRIDGE ====="
  echo "1) 🟢 Open Vault"
  echo "2) 🔴 Close Vault"
  echo "3) 🔵 Sync (dry run)"
  echo "4) 🟣 Deploy"
  echo "5) 🧹 Clean Logs (Big Pingaso)"
  echo "6) 🟡 Exit"
  echo "======================================"
  read "?Choose: " choice
  case "$choice" in
    1) run_script "Open_Vault.command" ;;
    2) run_script "Close_Vault.command" ;;
    3) run_script "Sync_DryRun.command" ;;
    4) run_script "Deploy.command" ;;
    5) run_script "VaultOps_Cleanup_All.command" ;;
    6) echo "Bye." ; exit 0 ;;
    *) echo "Invalid.";;
  esac
}

run_script() {
  local name="$1"
  local path="${SCRIPTS}/${name}"
  if [[ ! -x "$path" ]]; then
    echo "Script missing: $name"
    echo "Creating a stub so you can fill it later."
    cat > "$path" <<'SH'
#!/bin/zsh
echo "[STUB] Replace this with your real script logic."
SH
    chmod +x "$path"
  fi
  echo ""
  echo ">>> Running ${name} ..."
  "$path" || true
  echo "<<< Done."
  read -k1 "?Press any key to return to menu..."
}

while true; do
  clear
  menu
done
