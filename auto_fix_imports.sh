#!/usr/bin/env bash
# auto_fix_imports.sh
# Automatically fixes import paths for Next.js App Router migration
# Safe, backup-enabled, and structure-aware.

set -euo pipefail

ROOT_DIR="$(pwd)"
BACKUP_DIR="$ROOT_DIR/import_fixes_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔧 Starting import path migration..."
echo "📂 Backups stored in: $BACKUP_DIR"

# === Function: Calculate relative prefix based on file location ===
get_relative_prefix() {
  local file="$1"
  local file_dir
  file_dir=$(dirname "$file")

  # Count depth relative to root
  local depth="${file_dir//$ROOT_DIR/}"
  local count=$(grep -o "/" <<< "$depth" | wc -l | tr -d ' ')
  local prefix=""

  # Adjust prefix (../ for each directory level under root)
  for ((i=0; i<count; i++)); do prefix+="../"; done
  echo "$prefix"
}

# === Function: Process each file ===
process_file() {
  local file="$1"
  echo "⚙️  Processing $file"

  cp "$file" "$BACKUP_DIR/$(basename "$file")"

  local prefix
  prefix=$(get_relative_prefix "$file")

  awk -v rel="$prefix" '
    # Convert @/ imports to correct relative paths
    /from *'\''@\/api\// { gsub(/from '\''@\/api\//, "from '\''" rel "src/api/"); }
    /from *'\''@\/components\// { gsub(/from '\''@\/components\//, "from '\''" rel "src/components/"); }
    /from *'\''@\/lib\// { gsub(/from '\''@\/lib\//, "from '\''" rel "src/lib/"); }
    /from *'\''@\/hooks\// { gsub(/from '\''@\/hooks\//, "from '\''" rel "src/hooks/"); }

    # Fix relative component paths that are too shallow
    /from *'\''\.\.\/components\// { gsub(/\.\.\/components\//, rel "src/components/"); }

    # Fix other broken relative paths (ui, utils, etc.)
    /from *'\''\.\.\/ui\// { gsub(/\.\.\/ui\//, rel "src/components/ui/"); }
    /from *'\''\.\.\/utils\// { gsub(/\.\.\/utils\//, rel "src/utils/"); }

    # Replace react-router-dom with Next.js equivalents
    /from *'\''react-router-dom'\''/ {
      if ($0 ~ /Link/) {
        gsub(/react-router-dom/, "next/link");
      } else {
        gsub(/react-router-dom/, "next/navigation");
      }
    }

    # Also handle router hooks from react-router-dom
    /useNavigate/ { gsub(/useNavigate/, "useRouter"); }
    /useLocation/ { gsub(/useLocation/, "usePathname"); }

    { print }
  ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# === Traverse all JS/TS files ===
find "$ROOT_DIR" \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.next/*" \
  | while read -r f; do
      process_file "$f"
    done

echo "✅ Import paths fixed successfully!"
echo "🗃 Backups available in: $BACKUP_DIR"
