#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-}"
FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID:-}"

if [ -z "$REPO_URL" ]; then
  read -r -p "Nhập GitHub repo URL (https://github.com/username/repo.git): " REPO_URL
fi

if [ -z "$FIREBASE_PROJECT_ID" ]; then
  read -r -p "Nhập Firebase project id: " FIREBASE_PROJECT_ID
fi

git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

git switch -C main
git push -u origin main

FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  node -e "const fs=require('fs'); const p='.firebaserc'; const c=JSON.parse(fs.readFileSync(p,'utf8')); c.projects.default = process.env.FIREBASE_PROJECT_ID; fs.writeFileSync(p, JSON.stringify(c, null, 2) + '\\n');"

git add .firebaserc
git commit -m "chore: set firebase project id" || true
git push

echo ""
echo "Đã liên kết GitHub và cập nhật .firebaserc."
echo "Bước tiếp theo ở GitHub: thêm Secrets:"
echo "  - FIREBASE_SERVICE_ACCOUNT (JSON key)"
echo "  - FIREBASE_PROJECT_ID = $FIREBASE_PROJECT_ID"
echo "Sau khi thêm secret, push vào main/master sẽ tự deploy hosting; PR sẽ tạo preview."
