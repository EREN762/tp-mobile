import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});


    @override
    Widget build(BuildContext context) {
      final AuthService auth = AuthService();
      return Scaffold(
          appBar: AppBar(title: const Text('Nos produits')),
          body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text('Connexion réussie ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ElevatedButton(
          onPressed: () async {

    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
    },
child: const Text('Se déconnecter'),
)
],
),
),
);
}
}