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
