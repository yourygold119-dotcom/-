name: Build APK

on:
  push:
    branches: [main, master]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      # يولّد مجلد android تلقائياً (المشروع يحتوي lib و pubspec فقط)
      - name: Generate Android platform
        run: flutter create --platforms=android --org com.yuraa --project-name yuraa_app .

      # يضيف الصلاحيات ويرفع minSdk ويضبط اسم التطبيق تلقائياً
      - name: Patch manifest and gradle
        run: |
          python3 - <<'PY'
          import re, glob
          p = 'android/app/src/main/AndroidManifest.xml'
          s = open(p, encoding='utf-8').read()
          perms = ''.join(
              f'    <uses-permission android:name="android.permission.{x}"/>\n'
              for x in ['INTERNET', 'CAMERA', 'RECORD_AUDIO']
              if f'android.permission.{x}"' not in s)
          s = s.replace('<application', perms + '    <application', 1)
          s = re.sub(r'android:label="[^"]*"', 'android:label="يوراء"', s, count=1)
          open(p, 'w', encoding='utf-8').write(s)
          for g in glob.glob('android/app/build.gradle*'):
              t = open(g, encoding='utf-8').read()
              t = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24', t)
              t = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 24', t)
              open(g, 'w', encoding='utf-8').write(t)
          PY

      - run: flutter pub get

      - name: Build release APK
        run: flutter build apk --release

      - name: Rename APK
        run: cp build/app/outputs/flutter-apk/app-release.apk yuraa.apk

      - uses: actions/upload-artifact@v4
        with:
          name: yuraa-apk
          path: yuraa.apk

      # رابط تحميل مباشر يعمل من الموبايل
      - name: Publish release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: build-${{ github.run_number }}
          name: Yuraa APK #${{ github.run_number }}
          files: yuraa.apk
