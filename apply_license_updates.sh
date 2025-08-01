#!/bin/bash

# سكريبت لتطبيق تحديثات جداول الترخيص

echo "🔄 بدء تطبيق تحديثات جداول الترخيص..."

# 1. تشغيل build_runner
echo "📦 تشغيل build_runner..."
dart run build_runner build --delete-conflicting-outputs

# 2. التحقق من بناء التطبيق
echo "🏗️ التحقق من بناء التطبيق..."
flutter analyze --no-fatal-infos

# 3. عرض رسالة للمطور
echo ""
echo "✅ تم الانتهاء من التحديثات المحلية!"
echo ""
echo "📋 الخطوات المطلوبة في Supabase:"
echo "1. فتح Supabase Dashboard"
echo "2. الانتقال إلى SQL Editor"  
echo "3. نسخ محتوى ملف license_tables_setup.sql"
echo "4. تشغيل الأوامر SQL"
echo ""
echo "🚀 بعد تطبيق أوامر SQL، يمكنك تشغيل التطبيق:"
echo "flutter run"
echo ""
echo "📖 للمزيد من التفاصيل، راجع: LICENSE_TABLES_UPDATE_GUIDE.md"
