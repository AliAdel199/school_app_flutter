import 'package:flutter/material.dart';

class ProgramInfo {
  static void showProgramInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.school, color: Colors.indigo, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'نظام إدارة المدارس الذكي',
                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.indigo, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'نظام شامل لإدارة المدارس والطلاب',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  '✨ المميزات الرئيسية:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                SizedBox(height: 8),
                _buildFeatureItem('👥 إدارة بيانات الطلاب والموظفين'),
                _buildFeatureItem('💰 متابعة المدفوعات والرسوم'),
                _buildFeatureItem('📊 إنشاء التقارير التفصيلية'),
                _buildFeatureItem('🎯 نظام خصومات ذكي'),
                _buildFeatureItem('📋 تقارير حالة الطلاب'),
                _buildFeatureItem('💳 إدارة الأقساط والدفعات'),
                _buildFeatureItem('🏫 إدارة الصفوف والسنوات الدراسية'),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.withAlpha(50), Colors.blue.withAlpha(30)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.withAlpha(100)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.copyright, color: Colors.indigo, size: 24),
                      SizedBox(height: 8),
                      Text(
                        '© ${DateTime.now().year} جميع الحقوق محفوظة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Smart School Management System',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo.withAlpha(180),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'الإصدار 1.0',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close),
              label: Text('إغلاق'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo,
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // دالة لإنشاء زر معلومات البرنامج
  static Widget buildInfoButton(BuildContext context, {String? tooltip}) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: () => showProgramInfo(context),
      tooltip: tooltip ?? 'معلومات عن البرنامج',
    );
  }

  // دالة لإنشاء footer مع حقوق البرنامج
  static Widget buildCopyrightFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '© ${DateTime.now().year} نظام إدارة المدارس الذكي - جميع الحقوق محفوظة',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
