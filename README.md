# AutoParts Hub (Mobile)

**AutoParts Hub**, Flutter ile geliştirilmiş bir mobil e-ticaret uygulamasıdır. Kullanıcılar araçlarına uygun yedek parçaları arayıp filtreleyebilir, ürün detaylarını inceleyebilir, sepete ekleyip sipariş verebilir. Satıcı rolündeki kullanıcılar ise ürün yönetimi, sipariş yönetimi ve satış istatistiklerini görüntüleyebilir.

> Mobil uygulama, **ASP.NET Core tabanlı REST API** ile haberleşir (web uygulaması ile ortak backend).

---

## İçindekiler
- [Öne Çıkanlar](#öne-çıkanlar)
- [Ekran Görüntüleri](#ekran-görüntüleri)
- [Özellikler](#özellikler)
- [Teknoloji](#teknoloji)
- [Mimari](#mimari)
- [Kurulum](#kurulum)
- [Yapılandırma](#yapılandırma)
- [Roller ve Kısıtlar](#roller-ve-kısıtlar)

---

## Öne Çıkanlar
- Flutter + Material Design 3 ile modern UI
- JWT tabanlı kimlik doğrulama ve oturum yönetimi
- Gelişmiş arama/filtreleme (kategori, marka, fiyat, stok, araç filtresi, sıralama)
- Ürün detayında galeri, soru-cevap, değerlendirmeler
- Sepet ve checkout akışı
- Satıcı paneli: dashboard + grafikler (fl_chart), ürün yönetimi, sipariş yönetimi
- Araçlar: Marka → Model → Yıl hiyerarşik seçim

---

## Ekran Görüntüleri

> Görseller: `docs/screenshots/` klasöründedir.

### 1) Açılış & Kimlik Doğrulama
| Splash | Kayıt Ol | Hesap (Guest) |
|---|---|---|
| ![Splash](docs/screenshots/mobil1.webp) | ![Register](docs/screenshots/mobil9.webp) | ![Account Guest](docs/screenshots/mobil8.webp) |

### 2) Ana Sayfa & Parça Keşfi
| Ana Sayfa | Parça Kataloğu / Liste | Filtreler |
|---|---|---|
| ![Home](docs/screenshots/mobil2.webp) | ![Parts List](docs/screenshots/mobil7.webp) | ![Filters](docs/screenshots/mobil3.webp) |

### 3) Ürün Detayı & Etkileşim
| Ürün Detayı | Soru Sor (Modal) |
|---|---|
| ![Part Detail](docs/screenshots/mobil13.webp) | ![Ask Question](docs/screenshots/mobil14.webp) |

### 4) Araçlar (Vehicles)
| Marka Listesi | Model Listesi | Yıl Seçimi |
|---|---|---|
| ![Brands](docs/screenshots/mobil4.webp) | ![Models](docs/screenshots/mobil5.webp) | ![Years](docs/screenshots/mobil6.webp) |

> Not: Repoda `mobil6 (1).webp` de var. İstersen onu da ekleyebilirsin:
> `docs/screenshots/mobil6%20(1).webp`

### 5) Sepet & Ödeme
| Sepet | Ödeme (Checkout) |
|---|---|
| ![Cart](docs/screenshots/mobil16.webp) | ![Checkout](docs/screenshots/mobil17.webp) |

### 6) Hesap & Profil
| Hesap (User) | Profil Düzenle | Satıcı Başvurusu |
|---|---|---|
| ![Account User](docs/screenshots/mobil10.webp) | ![Edit Profile](docs/screenshots/mobil11.webp) | ![Seller Application](docs/screenshots/mobil12.webp) |

### 7) Siparişler
| Kullanıcı Siparişleri | Satıcı Siparişleri | Durum Seç |
|---|---|---|
| ![User Orders](docs/screenshots/mobil18%20(2).webp) | ![Seller Orders](docs/screenshots/24.webp) | ![Status Select](docs/screenshots/25.webp) |

### 8) Satıcı Paneli & Ürün Yönetimi
| Satıcı Paneli (Dashboard + Grafikler) | Ürünlerim | Yeni Ürün |
|---|---|---|
| ![Seller Dashboard](docs/screenshots/mobil20.webp) | ![Seller Products](docs/screenshots/mobil21.webp) | ![Create Product](docs/screenshots/23.webp) |

| Ürün Düzenle |
|---|
| ![Edit Product](docs/screenshots/mobil22.webp) |

### 9) Satıcı Rolü (Hesap Ekranı)
| Hesap (Satıcı) |
|---|
| ![Account Seller](docs/screenshots/mobil18.webp) |

> Not: Repoda `mobil18 (1).webp` de var. Eğer farklıysa şu şekilde ekleyebilirsin:
> `docs/screenshots/mobil18%20(1).webp`

---

## Özellikler

### Kullanıcı
- Ürün arama, listeleme, filtreleme
- Ürün detayı: galeri, açıklama, uyumlu araçlar, soru/cevap, değerlendirmeler
- Sepet: adet yönetimi, toplam tutar
- Ödeme/checkout: müşteri bilgileri ile sipariş oluşturma
- Profil: görüntüleme ve güncelleme
- Siparişlerim: sipariş durumu takibi

### Satıcı
- Satıcı paneli: satış grafikleri ve özet istatistikler
- Ürün yönetimi: ürün ekle/düzenle, ana görsel + galeri görselleri, uyumlu araç seçimi
- Sipariş yönetimi: sipariş durumunu güncelleme (Beklemede / Hazırlanıyor / Kargoya Verildi / Tamamlandı / İptal)

---

## Teknoloji
- Flutter (Dart)
- Provider (state management)
- http (REST client)
- image_picker (görsel seçimi)
- fl_chart (grafikler)
- Google Fonts (Inter)
- Material Design 3

---

## Mimari (Özet)
```txt
lib/
  main.dart
  config/app_config.dart
  models/
  services/
  state/
  screens/
  widgets/
