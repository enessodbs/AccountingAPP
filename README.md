# AccountingApp

Kapsamlı bir **muhasebe ve personel yönetim sistemi**. .NET Web API backend ve Flutter Web frontend ile geliştirilmiştir.

## 🏗️ Proje Yapısı

```
AccountingApp/
├── AccountingApp.API/          # .NET Web API (Ana backend)
├── AccountingApp.Application/  # Uygulama katmanı
├── AccountingApp.Domain/       # Domain entities & enums
├── AccountingApp.Infrastructure/ # Persistence (EF Core)
└── accounting_app_ui/          # Flutter Web frontend
```

## ✨ Özellikler

- **Kimlik Doğrulama**: JWT tabanlı auth, rol bazlı erişim (Admin / İK / Muhasebe / Satış / SatışYönetici / Pazarlama)
- **Personel Yönetimi**: Çalışan CRUD, departman ve pozisyon yönetimi
- **Fatura Yönetimi**: Satış/Alış faturaları, fatura kalemleri
- **Stok Takibi**: Ürün yönetimi, stok hareketleri, barkod/QR desteği
- **Finansal İşlemler**: Tahsilat/Ödeme kayıtları, çoklu döviz desteği
- **CRM — Lead Yönetimi**: Potansiyel müşteri kaydı, durum takibi, lead dönüştürme (müşteriye/fırsata)
- **CRM — Aktivite Geçmişi**: Telefon, e-posta, toplantı, not gibi etkileşimlerin kaydı ve timeline görünümü
- **CRM — Görev Yönetimi**: Kullanıcılara görev atama, öncelik/durum takibi, gecikme uyarıları
- **CRM — Fırsat/Pipeline**: Satış fırsatları, pipeline aşamaları, ağırlıklı gelir hesaplama
- **Dashboard**: Özet raporlar ve istatistikler
- **Çoklu Dil**: Türkçe / İngilizce desteği
- **Karanlık Mod**: Tema değiştirme

## 🛠️ Teknolojiler

| Katman | Teknoloji |
|--------|-----------|
| Backend | .NET 10, ASP.NET Core Web API |
| ORM | Entity Framework Core 10 |
| Veritabanı | SQL Server |
| Auth | JWT Bearer, BCrypt |
| Frontend | Flutter Web (Dart) |
| Mapping | AutoMapper |

## 🚀 Kurulum

### Gereksinimler

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x+)
- [SQL Server](https://www.microsoft.com/sql-server)

### Backend

1. **Yapılandırma**: `AccountingApp.API/appsettings.Development.json` oluşturun:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=YOUR_SERVER;Database=AccountingAppDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True;"
     },
     "JwtSettings": {
       "Secret": "EN_AZ_32_KARAKTER_UZUNLUGUNDA_GUCLU_BIR_ANAHTAR"
     }
   }
   ```

2. **Veritabanı Migration**:
   ```bash
   cd AccountingApp.API
   dotnet ef database update
   ```

3. **Çalıştırma**:
   ```bash
   dotnet run --project AccountingApp.API
   ```
   API varsayılan olarak `http://localhost:5188` adresinde çalışır.

### Frontend

1. **Bağımlılıkları yükleme**:
   ```bash
   cd accounting_app_ui
   flutter pub get
   ```

2. **Çalıştırma**:
   ```bash
   flutter run -d chrome
   ```

3. **Custom API URL** (opsiyonel):
   ```bash
   flutter run -d chrome --dart-define=API_BASE_URL=http://your-server/api
   ```

## 🔑 Varsayılan Kullanıcılar

> ⚠️ **Uyarı**: Production ortamında bu şifreleri mutlaka değiştirin!

| Kullanıcı | Rol | Bilgi |
|-----------|-----|-------|
| `admin` | Admin | Tam yetki |
| `ik_user` | İK | İnsan kaynakları modülü |
| `muhasebe_user` | Muhasebe | Finans modülü |
| `satis_user` | Satış | CRM satış modülü |

Varsayılan şifreler için `ModelBuilderExtensions.cs` seed data'sını inceleyiniz.

## 📁 API Endpoints

| Endpoint | Açıklama |
|----------|----------|
| `POST /api/auth/login` | Kullanıcı girişi |
| `GET /api/employees` | Personel listesi |
| `GET /api/invoices` | Fatura listesi |
| `GET /api/products` | Ürün listesi |
| `GET /api/transactions` | İşlem listesi |
| `GET /api/dashboard` | Dashboard verileri |
| `GET /api/departments` | Departman listesi |
| `GET /api/categories` | Kategori listesi |
| `GET /api/currencies` | Döviz listesi |
| `GET /api/businesscontacts` | İş ilişkileri |
| `GET /api/stockmovements` | Stok hareketleri |
| `GET /api/reports` | Raporlar |
| **CRM Endpoints** | |
| `GET /api/leads` | Lead listesi (rol bazlı filtreleme) |
| `POST /api/leads` | Yeni lead oluştur |
| `PUT /api/leads/{id}/status` | Lead durumunu değiştir |
| `POST /api/leads/{id}/convert` | Lead'i müşteriye dönüştür |
| `GET /api/leads/stats` | Lead istatistikleri |
| `GET /api/activities` | Aktivite listesi |
| `GET /api/activities/timeline` | Timeline görünümü |
| `GET /api/crmtasks` | Görev listesi |
| `GET /api/crmtasks/my` | Bana atanmış görevler |
| `GET /api/crmtasks/stats` | Görev istatistikleri |

## 🔒 Güvenlik Notları

- `appsettings.json` yalnızca placeholder değerler içerir
- Gerçek connection string ve JWT secret `appsettings.Development.json`'da tutulur (`.gitignore` ile korunur)
- Flutter API URL'i build-time `--dart-define` ile konfigüre edilir
- Parolalar BCrypt ile hash'lenerek saklanır
- Production ortamında environment variables veya Azure Key Vault kullanmanız önerilir
