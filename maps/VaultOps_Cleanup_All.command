#!/bin/zsh
set -euo pipefail

echo "=== VaultOps Cleanup — All Months (Big Pingaso) ==="

VAULT="${HOME}/Documents/PovertyPimpsVault"
LOGROOT="${VAULT}/VaultOpsLogs"

if [[ ! -d "$LOGROOT" ]]; then
  echo "ERROR: Can't find ${LOGROOT}. Edit VAULT path in this script if needed."
  exit 1
fi

# Month name map
month_name() {
  case "$1" in
    01) echo "01_January" ;;
    02) echo "02_February" ;;
    03) echo "03_March" ;;
    04) echo "04_April" ;;
    05) echo "05_May" ;;
    06) echo "06_June" ;;
    07) echo "07_July" ;;
    08) echo "08_August" ;;
    09) echo "09_September" ;;
    10) echo "10_October" ;;
    11) echo "11_November" ;;
    12) echo "12_December" ;;
  esac
}

# Backup all year folders we touch (shallow backup of top-level files only)
backup_month() {
  local month_dir="$1"
  [[ -d "$month_dir" ]] || return 0
  local stamp; stamp=$(date +"%Y%m%d-%H%M%S")
  local backup="${month_dir}/_backup_${stamp}"
  mkdir -p "$backup"
  find "$month_dir" -maxdepth 1 -type f -print0 | xargs -0 -I{} cp -p {} "$backup" 2>/dev/null || true
  echo "Backup -> $backup"
}

# Preview moves for a given YYYY and MM
preview_moves_for_month() {
  local year="$1"; local mm="$2"
  local mname; mname=$(month_name "$mm")
  local dir="${LOGROOT}/${year}/${mname}"
  [[ -d "$dir" ]] || { echo "  (no folder ${dir}, will create if needed)"; return 0; }
  local found=0
  while IFS= read -r -d '' f; do
    base="$(basename "$f")"
    date_token="$(echo "$base" | grep -Eo "${year}-${mm}-[0-9]{2}" || true)"
    [[ -z "$date_token" ]] && continue
    day="${date_token##*-}"
    echo "  - ${base} -> ${day}_${mname#*_}/"
    found=1
  done < <(find "$dir" -maxdepth 1 -type f -print0)
  [[ "$found" -eq 0 ]] && echo "  (No dated files at top-level in ${mname})"
}

# Perform moves
perform_moves_for_month() {
  local year="$1"; local mm="$2"
  local mname; mname=$(month_name "$mm")
  local dir="${LOGROOT}/${year}/${mname}"
  mkdir -p "$dir"
  while IFS= read -r -d '' f; do
    base="$(basename "$f")"
    date_token="$(echo "$base" | grep -Eo "${year}-${mm}-[0-9]{2}" || true)"
    [[ -z "$date_token" ]] && continue
    day="${date_token##*-}"
    target="${dir}/${day}_${mname#*_}"
    mkdir -p "$target"
    git mv -f "$f" "$target/$base" 2>/dev/null || mv -f "$f" "$target/$base"
  done < <(find "$dir" -maxdepth 1 -type f -print0)
}

# Year range: from 2025 to next year (future-proof)
current_year=$(date +"%Y")
years=(2025 $current_year)
# Deduplicate if same year
years=($(printf "%s\n" "${years[@]}" | awk '!x[$0]++'))

echo "Preview of planned moves:"
for y in "${years[@]}"; do
  for mm in 08 09 10 11 12; do
    mname=$(month_name "$mm")
    echo "• ${y}-${mm} (${mname})"
    preview_moves_for_month "$y" "$mm"
  done
done

echo
read "?Proceed with cleanup across months? (y/N) " ans
if [[ "${ans:l}" != "y" ]]; then
  echo "Cancelled."
  exit 0
fi

# Backups and moves
for y in "${years[@]}"; do
  for mm in 08 09 10 11 12; do
    mname=$(month_name "$mm")
    dir="${LOGROOT}/${y}/${mname}"
    mkdir -p "$dir"
    backup_month "$dir"
    perform_moves_for_month "$y" "$mm"
  done
done

# Seed 2025-08-29 Closing Log if missing
SEED_DIR="${LOGROOT}/2025/08_August/29_August"
mkdir -p "$SEED_DIR"
SEED_FILE="${SEED_DIR}/VaultOps_Closing_Log_2025-08-29.md"
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
if [[ ! -f "$SEED_FILE" && -f "${SCRIPT_DIR}/seed/VaultOps_Closing_Log_2025-08-29.md" ]]; then
  cp -p "${SCRIPT_DIR}/seed/VaultOps_Closing_Log_2025-08-29.md" "$SEED_FILE"
  echo "Seeded: ${SEED_FILE}"
  git add "$SEED_FILE" 2>/dev/null || true
fi

echo
echo "Cleanup complete."
echo "Next:"
echo "  cd ${VAULT}/papiricanpi.github.io && git add -A && git commit -m 'Drop_34I: Hub wired + logs normalized' && git push"
