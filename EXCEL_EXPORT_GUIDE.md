# دليل تصدير الدرجات إلى Excel 📊

تم إضافة ميزة تصدير الدرجات إلى ملفات Excel في التطبيق لتسهيل إدارة وتحليل البيانات.

## الميزات الجديدة 🎯

### 1. تصدير شامل للدرجات (من شاشة إدارة المواد والدرجات)
- **الموقع**: شاشة إدارة المواد والدرجات → زر التصدير في شريط الأدوات
- **الرمز**: 📥 (أيقونة التحميل)
- **الوظيفة**: تصدير جميع الدرجات أو الدرجات المفلترة

#### المحتويات المُصدرة:
- اسم الطالب
- الصف الدراسي
- المادة
- الدرجة المحصلة
- الدرجة الكاملة للمادة
- النسبة المئوية
- نوع التقييم (نصف سنة، نهائي، شفوي، عملي، مشاركة)
- السنة الدراسية
- تاريخ إدخال الدرجة

#### الإحصائيات التلقائية:
- إجمالي الدرجات المسجلة
- عدد الطلاب
- عدد المواد
- تاريخ التصدير

### 2. تصدير درجات طالب واحد (من شاشة تقرير درجات الطالب)
- **الموقع**: شاشة تقرير درجات الطالب → زر التصدير في شريط الأدوات
- **الرمز**: 📥 (أيقونة التحميل)
- **الوظيفة**: تصدير درجات طالب محدد مع إحصائيات مفصلة

### 3. تصدير درجات صف كامل (من شاشة تقرير درجات الصف) 🆕
- **الموقع**: شاشة تقرير درجات الصف → زر التصدير في شريط الأدوات
- **الرمز**: 📥 (أيقونة التحميل)
- **الوظيفة**: تصدير جميع طلاب الصف مع درجاتهم في كل المواد

#### المحتويات المُصدرة:
**معلومات الطالب:**
- الاسم الكامل
- الصف الدراسي
- السنة الدراسية
- نوع التقييم
- تاريخ التقرير

**جدول الدرجات:**
- المادة
- الدرجة المحصلة
- الدرجة الكاملة
- النسبة المئوية
- الحالة (نجح/راسب)

**الإحصائيات النهائية:**
- إجمالي الدرجات
- إجمالي الدرجات الكاملة
- المعدل العام
- الحالة العامة
- عدد المواد المجتازة
- عدد المواد الراسبة
- إجمالي المواد

#### المحتويات المُصدرة (تقرير الصف الكامل):
**معلومات الصف:**
- اسم الصف
- نوع التقييم
- السنة الدراسية
- عدد الطلاب والمواد
- تاريخ التقرير

**جدول الدرجات الشامل:**
- اسم الطالب
- درجات جميع المواد
- المعدل العام للطالب
- حالة الطالب (ناجح/راسب/مكمل)

**إحصائيات الصف:**
- متوسط الصف العام
- عدد الطلاب الناجحين/المكملين/الراسبين
- معدل النجاح في الصف

## كيفية الاستخدام 📖

### التصدير الشامل:
1. انتقل إلى شاشة "إدارة المواد والدرجات"
2. اختر المرشحات المطلوبة (اختياري):
   - الصف الدراسي
   - المادة المحددة
   - نوع التقييم
   - السنة الدراسية
3. اضغط على زر التصدير 📥 في شريط الأدوات
4. انتظر رسالة التأكيد
5. ستجد الملف في مجلد المستندات

### تصدير درجات طالب واحد:
1. انتقل إلى شاشة "تقرير درجات الطالب"
2. اختر الطالب المطلوب
3. حدد نوع التقييم والسنة الدراسية
4. اضغط على زر التصدير 📥 في شريط الأدوات
5. انتظر رسالة التأكيد
6. ستجد الملف في مجلد المستندات

### تصدير درجات صف كامل: 🆕
1. انتقل إلى شاشة "تقرير درجات الصف"
2. اختر الصف المطلوب
3. حدد نوع التقييم والسنة الدراسية
4. اضغط على زر التصدير 📥 في شريط الأدوات (Excel)
5. أو اضغط على زر الطباعة 🖨️ لتقرير PDF
6. انتظر رسالة التأكيد
7. ستجد الملف في مجلد المستندات

## مواقع الملفات 📁

الملفات المُصدرة تُحفظ في:
```
المستندات/
├── درجات_الطلاب_[timestamp].xlsx (للتصدير الشامل)
├── درجات_[اسم_الطالب]_[timestamp].xlsx (لطالب واحد)
└── درجات_صف_[اسم_الصف]_[timestamp].xlsx (لصف كامل)
```

## تنسيق الملفات 🎨

### Excel Formatting:
- **رؤوس الأعمدة**: نص عريض ومتوسط
- **بيانات الطلاب**: تنسيق واضح ومنظم
- **الإحصائيات**: نص عريض مميز
- **عرض الأعمدة**: محدد تلقائياً لسهولة القراءة

### معايير النجاح:
- **نجح**: النسبة المئوية ≥ 50%
- **راسب**: النسبة المئوية < 50%

## الفوائد 💡

1. **سهولة التحليل**: استخدام Excel لتحليل البيانات
2. **المشاركة**: إرسال التقارير للإدارة أو الأولياء
3. **الأرشفة**: حفظ سجلات الدرجات لفترات طويلة
4. **المرونة**: تخصيص التقارير حسب الحاجة
5. **التوافق**: يعمل مع جميع برامج جداول البيانات

## ملاحظات مهمة ⚠️

- تأكد من وجود مساحة كافية في الذاكرة
- الملفات تُحفظ في مجلد المستندات تلقائياً
- اسم الملف يحتوي على timestamp لتجنب التكرار
- يمكن فتح الملفات بـ Excel أو Google Sheets أو LibreOffice

## الدعم التقني 🛠️

في حالة مواجهة أي مشاكل:
1. تأكد من وجود مساحة كافية في الذاكرة
2. أعد تشغيل التطبيق
3. تحقق من صلاحيات الكتابة في مجلد المستندات

---

**تم تطوير هذه الميزة لتحسين تجربة إدارة الدرجات وتسهيل عملية التقارير.**
