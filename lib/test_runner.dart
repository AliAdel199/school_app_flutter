import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tests/system_validator.dart';

void main() {
  runApp(SystemTestApp());
}

class SystemTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SystemTestPage(),
    );
  }
}

class SystemTestPage extends StatefulWidget {
  @override
  _SystemTestPageState createState() => _SystemTestPageState();
}

class _SystemTestPageState extends State<SystemTestPage> {
  bool _isRunning = false;
  String _results = '';
  Map<String, dynamic>? _testData;

  Future<void> _runSystemTest() async {
    setState(() {
      _isRunning = true;
      _results = 'Running system validation...';
    });

    try {
      final results = await SystemValidator.validateCompleteSystem();
      final report = SystemValidator.generateReport(results);
      
      setState(() {
        _testData = results;
        _results = report;
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _results = 'Error running system test: $e';
        _isRunning = false;
      });
    }
  }

  void _copyResults() {
    if (_results.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _results));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Results copied to clipboard'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('System Validation Test'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            if (_testData != null) ...[
              Card(
                color: _getStatusColor(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Test Results Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('Total', _testData!['summary']['total']),
                          _buildSummaryItem('Passed', _testData!['summary']['passed']),
                          _buildSummaryItem('Failed', _testData!['summary']['failed']),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : _runSystemTest,
                    child: _isRunning 
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Running...'),
                          ],
                        )
                      : Text('Run System Test'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _results.isNotEmpty ? _copyResults : null,
                  child: Icon(Icons.copy),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Results Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    _results.isEmpty ? 'Click "Run System Test" to start validation' : _results,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_testData == null) return Colors.grey;
    
    final failed = _testData!['summary']['failed'];
    final total = _testData!['summary']['total'];
    
    if (failed == 0) return Colors.green;
    if (failed < total / 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSummaryItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
