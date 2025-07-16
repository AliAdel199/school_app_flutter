import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class WhatsAppService {
  static const String schoolPhoneNumber = "+9647XXXXXXXXX"; // رقم هاتف المدرسة
  
  // إرسال تفاصيل الدفعة عبر الواتساب
  static Future<void> sendPaymentDetails({
    required String schoolPhoneNumber,
    required String parentPhone,
    required String studentName,
    required double amount,
    required String paymentType,
    required DateTime paymentDate,
  }) async {
    final message = """
مرحباً،

تم تسديد دفعة جديدة للطالب: $studentName

تفاصيل الدفعة:
- نوع الدفعة: $paymentType
- المبلغ: ${amount.toStringAsFixed(0)} دينار
- تاريخ الدفعة: ${paymentDate.day}/${paymentDate.month}/${paymentDate.year}

شكراً لكم
إدارة المدرسة
    """;
    
    await _sendWhatsAppMessage(parentPhone, message);
  }
  
  // إرسال النتائج عبر الواتساب
  static Future<void> sendStudentResults({
    required String parentPhone,
    required String studentName,
    required Map<String, dynamic> results,
  }) async {
    // إنشاء ملف PDF للنتائج
    final pdfFile = await _generateResultsPDF(studentName, results);
    
    final message = """
مرحباً،

نتائج الطالب: $studentName

يرجى الاطلاع على الملف المرفق للنتائج التفصيلية.

مع تحيات إدارة المدرسة
    """;
    
    // مشاركة PDF مع رسالة الواتساب
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: message,
    );
  }
  
// إرسال رسالة واتساب مع معالجة مشكلة الأرقام غير المحفوظة
  static Future<void> _sendWhatsAppMessage(String phoneNumber, String message) async {
    // تنظيف رقم الهاتف
    String cleanPhoneNumber = _cleanPhoneNumber(phoneNumber);
    
    // محاولة عدة طرق لفتح الواتساب
    List<String> whatsappUrls = [
      // الطريقة الأولى: استخدام wa.me
      "https://wa.me/$cleanPhoneNumber?text=${Uri.encodeComponent(message)}",
      // الطريقة الثانية: استخدام api.whatsapp.com
      "https://api.whatsapp.com/send?phone=$cleanPhoneNumber&text=${Uri.encodeComponent(message)}",
      // الطريقة الثالثة: استخدام Intent للأندرويد
      "whatsapp://send?phone=$cleanPhoneNumber&text=${Uri.encodeComponent(message)}",
    ];
    
    bool success = false;
    
    for (String url in whatsappUrls) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          success = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }
    
    if (!success) {
      // إذا فشلت كل الطرق، نحاول فتح الواتساب ونسخ الرسالة للحافظة
      await _fallbackWhatsAppOpen(cleanPhoneNumber, message);
    }
  }
  // تنظيف رقم الهاتف
  static String _cleanPhoneNumber(String phoneNumber) {
    // إزالة كل ما ليس رقم أو علامة +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // إذا لم يبدأ بـ + نضيف كود العراق
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('07')) {
        // رقم عراقي محلي
        cleaned = '+964${cleaned.substring(1)}';
      } else if (cleaned.startsWith('7')) {
        // رقم عراقي بدون 0
        cleaned = '+964$cleaned';
      } else if (!cleaned.startsWith('964')) {
        // رقم بدون كود الدولة
        cleaned = '+964$cleaned';
      } else {
        // رقم يحتوي على كود الدولة بدون +
        cleaned = '+$cleaned';
      }
    }
    
    return cleaned;
  }
  
    // طريقة بديلة لفتح الواتساب
  static Future<void> _fallbackWhatsAppOpen(String phoneNumber, String message) async {
    try {
      // محاولة فتح الواتساب فقط
      const whatsappScheme = "whatsapp://";
      if (await canLaunchUrl(Uri.parse(whatsappScheme))) {
        await launchUrl(Uri.parse(whatsappScheme), mode: LaunchMode.externalApplication);
        
        // نسخ الرسالة والرقم للحافظة
        await _copyToClipboard(phoneNumber, message);
      } else {
        // فتح متجر التطبيقات لتحميل الواتساب
        await _openAppStore();
      }
    } catch (e) {
      throw 'لا يمكن فتح الواتساب. تأكد من تثبيت التطبيق أولاً';
    }
  }
  
  // نسخ الرسالة والرقم للحافظة
  static Future<void> _copyToClipboard(String phoneNumber, String message) async {
    final textToCopy = """
الرقم: $phoneNumber

الرسالة:
$message
    """;
    
    // هنا يمكنك استخدام حزمة clipboard أو إظهار dialog مع النص
    print("نسخ للحافظة: $textToCopy");
  }
  
  // فتح متجر التطبيقات
  static Future<void> _openAppStore() async {
    final url = Platform.isAndroid 
        ? "https://play.google.com/store/apps/details?id=com.whatsapp"
        : "https://apps.apple.com/app/whatsapp-messenger/id310633997";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  
  // إنشاء PDF للنتائج
  static Future<File> _generateResultsPDF(String studentName, Map<String, dynamic> results) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('نتائج الطالب', style: pw.TextStyle(fontSize: 24)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('اسم الطالب: $studentName', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Text('الدرجات:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...results.entries.map((entry) => 
                pw.Text('${entry.key}: ${entry.value}', style: pw.TextStyle(fontSize: 14))
              ).toList(),
              pw.SizedBox(height: 30),
              pw.Text('تاريخ الإصدار: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
            ],
          );
        },
      ),
    );
    
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/student_results_$studentName.pdf");
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
}