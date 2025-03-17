import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FinanceHomePage extends StatefulWidget {
  final String username;

  FinanceHomePage({required this.username});

  @override
  _FinanceHomePageState createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactionHistory = [];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _addTransaction(String type) {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    String description = _descriptionController.text;
    if (amount > 0) {
      setState(() {
        if (type == 'Nabung') {
          _balance += amount;
          _transactionHistory.add({
            'type': 'Nabung',
            'amount': amount,
            'description': description,
            'date': DateTime.now().toIso8601String(), // Simpan sebagai String
          });
        } else if (type == 'Ambil') {
          if (_balance >= amount) {
            _balance -= amount;
            _transactionHistory.add({
              'type': 'Ambil',
              'amount': amount,
              'description': description,
              'date': DateTime.now().toIso8601String(), // Simpan sebagai String
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saldo tidak cukup')),
            );
          }
        }
      });
      _amountController.clear();
      _descriptionController.clear();
      _saveData();
    }
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', _balance);
    await prefs.setStringList('transactionHistory', _transactionHistory.map((transaction) => jsonEncode(transaction)).toList());
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = prefs.getDouble('balance') ?? 0.0;
      _transactionHistory = (prefs.getStringList('transactionHistory') ?? []).map((transaction) {
        Map<String, dynamic> decoded = jsonDecode(transaction);
        return {
          'type': decoded['type'],
          'amount': decoded['amount'],
          'description': decoded['description'],
          'date': decoded['date'], // Simpan tetap sebagai String
        };
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat datang, ${widget.username}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(isDarkMode ? Icons.brightness_3 : Icons.brightness_6, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildWalletPage(isDarkMode) : _selectedIndex == 1 ? _buildHistoryPage(isDarkMode) : ProfilePage(username: widget.username, balance: _balance),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet, color: isDarkMode ? Colors.white : Colors.black),
            label: 'Dompet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: isDarkMode ? Colors.white : Colors.black),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildWalletPage(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Saldo Anda:',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'IDR ${NumberFormat('#,##0').format(_balance)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Jumlah Uang',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              prefixIcon: Icon(Icons.attach_money, color: isDarkMode ? Colors.white : Colors.black),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Keterangan',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              prefixIcon: Icon(Icons.description, color: isDarkMode ? Colors.white : Colors.black),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _addTransaction('Nabung'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Remove background color
                  shadowColor: Colors.transparent, // Remove shadow
                ),
                child: Text(
                  'Nabung',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () => _addTransaction('Ambil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Remove background color
                  shadowColor: Colors.transparent, // Remove shadow
                ),
                child: Text(
                  'Ambil',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPage(bool isDarkMode) {
    return ListView.builder(
      itemCount: _transactionHistory.length,
      itemBuilder: (context, index) {
        final transaction = _transactionHistory[index];
        return ListTile(
          leading: transaction['type'] == 'Nabung' ? Icon(Icons.arrow_downward, color: Colors.green) : Icon(Icons.arrow_upward, color: Colors.red),
          title: Text('${transaction['type']} - ${transaction['description']}'),
          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(transaction['date']))),
          trailing: Text('IDR ${NumberFormat('#,##0').format(transaction['amount'])}'),
        );
      },
    );
  }
}