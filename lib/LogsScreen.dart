import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:school_app_flutter/localdatabase/log.dart';
import '../../main.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Log> logs = [];
  List<Log> filteredLogs = [];
  String searchUser = '';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    logs = await isar.logs.where().sortByCreatedAtDesc().findAll();
    for (final log in logs) {
      await log.user.load();
    }
    applyFilters();
  }

  void applyFilters() {
    filteredLogs = logs.where((log) {
      final matchUser = searchUser.isEmpty ||
          (log.user.value?.username.toLowerCase().contains(searchUser.toLowerCase()) ?? false);

      final matchDate = selectedDate == null ||
          DateFormat('yyyy-MM-dd').format(log.createdAt) ==
              DateFormat('yyyy-MM-dd').format(selectedDate!);

      return matchUser && matchDate;
    }).toList();
    setState(() {});
  }

  void resetFilters() {
    searchUser = '';
    selectedDate = null;
    applyFilters();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate = picked;
      applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل العمليات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetFilters,
            tooltip: 'إعادة تعيين الفلاتر',
          )
        ],
      ),
      body: Container(
        color: theme.colorScheme.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'بحث باسم المستخدم',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                      onChanged: (val) {
                        searchUser = val;
                        applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: pickDate,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Chip(
                      label: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate!),
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        selectedDate = null;
                        applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد سجلات',
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: filteredLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        final user = log.user.value;
                        final date = DateFormat('yyyy-MM-dd HH:mm').format(log.createdAt);
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.event_note, color: theme.colorScheme.primary, size: 22),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        log.action,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      date,
                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 18, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'المستخدم: ${user?.username ?? 'غير معروف'}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.table_chart, size: 18, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'الجدول: ${log.tableName ?? '-'}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.description, size: 18, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'الوصف: ${log.description ?? '-'}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
