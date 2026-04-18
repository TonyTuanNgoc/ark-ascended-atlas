# ARK: Survival Ascended Atlas

## Quick deployment (GitHub + Firebase)

### 1) Init Git + push lên GitHub

```bash
cd "/Users/admin/ARK Ascended"
git init
git add .
git commit -m "chore: init ark ascended atlas"
git branch -M main   # hoặc -M master nếu repo của bạn dùng master
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

### 2) Firebase Hosting deploy tự động qua GitHub Actions

1. Vào Firebase Console → Project Settings → Service Accounts.
2. Tạo private key JSON, lưu file.
3. Trong GitHub repo: Settings → Secrets and variables → Actions.
4. Tạo secret:
   - `FIREBASE_SERVICE_ACCOUNT` = nội dung đầy đủ JSON vừa download
   - `FIREBASE_PROJECT_ID` = projectId trên Firebase
5. Mở file `.firebaserc` và thay `YOUR_FIREBASE_PROJECT_ID` bằng `projectId`.

Sau đó:

- Push vào `main`/`master` sẽ auto deploy production.
- Mở PR vào `main`/`master` sẽ tự tạo preview channel trên Firebase cho PR đó.

### 2b) Chạy nhanh tự động hóa toàn bộ

```bash
cd "/Users/admin/ARK Ascended"
chmod +x scripts/link-and-deploy.sh
./scripts/link-and-deploy.sh
```

Script sẽ:
- thêm remote GitHub
- đẩy mã lên `main`
- cập nhật `/.firebaserc` theo project id bạn nhập

Nếu muốn dùng biến môi trường không phải nhập tay:

```bash
REPO_URL=https://github.com/<your-username>/<your-repo>.git \
FIREBASE_PROJECT_ID=<your-firebase-project-id> \
./scripts/link-and-deploy.sh
```

### 2c) Tạo repo GitHub từ terminal bằng token (nếu chưa có sẵn repo)

```bash
cd "/Users/admin/ARK Ascended"
chmod +x scripts/create-github-repo.sh

GITHUB_TOKEN=<your_github_personal_access_token> \
GITHUB_OWNER=<your-username> \
REPO_NAME=ark-ascended-atlas \
./scripts/create-github-repo.sh
```

Token cần quyền `repo` (Full control of private repositories).

### 3) Deploy thủ công (optional)

```bash
npm install -g firebase-tools
firebase login
firebase use <your-project-id>
firebase deploy
```

### 4) Lưu ý dữ liệu ảnh upload

Ảnh upload URL / local upload hiện đang lưu trong `localStorage` của trình duyệt. Đây là nội dung dùng cục bộ trên máy mở trang, không phải dữ liệu toàn cục trên Firebase.
Nếu muốn share ảnh giữa các thiết bị, mình sẽ chuyển qua Firebase Storage/Firestore/Data layer ở lần update tiếp theo.
