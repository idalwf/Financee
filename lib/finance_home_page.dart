import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

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
            'date': DateTime.now(),
          });
        } else if (type == 'Ambil') {
          if (_balance >= amount) {
            _balance -= amount;
            _transactionHistory.add({
              'type': 'Ambil',
              'amount': amount,
              'description': description,
              'date': DateTime.now(),
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
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(username: widget.username, balance: _balance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat datang, ${widget.username}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.brightness_3 : Icons.brightness_6),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildWalletPage() : _buildHistoryPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Dompet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildWalletPage() {
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
            decoration: const InputDecoration(
              labelText: 'Jumlah Uang',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Keterangan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _addTransaction('Nabung'),
                child: const Text('Nabung'),
              ),
              ElevatedButton(
                onPressed: () => _addTransaction('Ambil'),
                child: const Text('Ambil'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPage() {
    return ListView.builder(
      itemCount: _transactionHistory.length,
      itemBuilder: (context, index) {
        final transaction = _transactionHistory[index];
        return ListTile(
          title: Text('${transaction['type']} - ${transaction['description']}'),
          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(transaction['date'])),
          trailing: Text('IDR ${NumberFormat('#,##0').format(transaction['amount'])}'),
        );
      },
    );
  }
}

