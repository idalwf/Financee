import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final double balance;

  ProfilePage({required this.username, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Username: $username',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Tabungan:',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'IDR ${NumberFormat('#,##0').format(balance)}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
