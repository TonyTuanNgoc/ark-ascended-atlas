#!/usr/bin/env bash
set -euo pipefail

OWNER="${GITHUB_OWNER:-}"
REPO_NAME="${REPO_NAME:-}"
VISIBILITY="${REPO_VISIBILITY:-public}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

if [ -z "$OWNER" ]; then
  read -r -p "Nhập GitHub username/organization: " OWNER
fi

if [ -z "$REPO_NAME" ]; then
  read -r -p "Nhập tên repository (ví dụ ark-ascended-atlas): " REPO_NAME
fi

if [ -z "$GITHUB_TOKEN" ]; then
  read -r -p "Nhập GitHub Personal Access Token (repo scope): " -s GITHUB_TOKEN
  echo
fi

if [ "$VISIBILITY" != "public" ] && [ "$VISIBILITY" != "private" ]; then
  echo "VISIBILITY phải là public hoặc private (mặc định public)."
  exit 1
fi

REPO_PAYLOAD=$(cat <<JSON
{
  "name": "$REPO_NAME",
  "private": $([ "$VISIBILITY" = "private" ] && echo true || echo false)
}
JSON
)

API_URL="https://api.github.com/user/repos"
RESPONSE=$(mktemp)

STATUS_CODE=$(curl -sS -o "$RESPONSE" -w "%{http_code}" \
  -X POST "$API_URL" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "$REPO_PAYLOAD")

if [ "$STATUS_CODE" -ne 201 ] && [ "$STATUS_CODE" -ne 422 ]; then
  echo "Tạo repo thất bại (HTTP $STATUS_CODE)." 
  echo "Response:" 
  cat "$RESPONSE"
  rm -f "$RESPONSE"
  exit 1
fi

if [ "$STATUS_CODE" -eq 422 ]; then
  echo "Repo có thể đã tồn tại rồi. Tiếp tục gắn remote và đẩy code."
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "https://github.com/$OWNER/$REPO_NAME.git"
else
  git remote add origin "https://github.com/$OWNER/$REPO_NAME.git"
fi

git push -u origin main

echo "Repo đã sẵn sàng: https://github.com/$OWNER/$REPO_NAME"
rm -f "$RESPONSE"
