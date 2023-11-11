# pambe_ac_ifa

Projek untuk mata kuliah "Pengembangan Aplikasi Mobil Back-End" dari Universitas Mikroskil yang dikerjakan oleh:

- Davin Tristan Ieson (211111012)
- Fikri Dwi Ramadhandi (211112189)
- William Antoline (211110319)

## Getting Started

Pertama-tama, anda perlu Flutter dan Android SDK. Silahkan lakukan instalasi melalui link berikut: https://docs.flutter.dev/get-started/install. Anda juga perlu Andorid SDK untuk mengembangkan aplikasi android. Jika anda masih pemula disarankan menggunakan Android Studio agar lebih mudah mengelola SDK dan emulator android: https://developer.android.com/studio/

Jika anda sudah clone repository ini, silahkan jalankan `flutter pub get` lewat terminal anda untuk menginstalasi package yang digunakan. Jika anda pengguna Windows, mohon aktivasikan For developers > Developer Mode karena pengembangan aplikasi dengan plugin perlu symlink support.

Selanjutnya, anda perlu membuat projek Firebase dari https://console.firebase.google.com, atau jika anda merupakan dosen Universitas Mikroskil boleh minta akses dari salah satu anggota kami. Untuk mengintegrasikan firebase ke flutter, silahkan ikuti instruksi di sini: https://firebase.google.com/docs/flutter/setup?platform=android. Jika anda sudah sukses melakukan login ke Flutter dan sudah membuat projek Firebase, seharusnya projek akan muncul saat anda menjalankan `flutterfire configure`. Jika semua sukses maka seharusnya muncul lib/firebase_options.dart.

Anda dapat menjalankan aplikasi dengan `flutter run`. Pastikan emulator anda (https://developer.android.com/studio/run/emulator) atau perangkat android dengan USB debugging (https://developer.android.com/studio/run/device) telah terdeteksi oleh Flutter. Anda dapat mengecek perangkat yang terdeteksi Flutter dengan menjalankan `flutter devices`.

Jika anda ingin membangun file .apk. Silahkan jalankan `./scripts/build-apk.bash` melalui Bash shell (Git Bash juga bekerja).
