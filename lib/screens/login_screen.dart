import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_login_button.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importez FirebaseAuth pour les exceptions
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "../utils/notification_helper.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  bool isLoading = false;

  // Fonction pour traduire les codes d'erreur Firebase en messages amicaux
  String _getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'web-context-canceled':
        return "La connexion a été annulée par l'utilisateur. Veuillez réessayer.";
      case 'invalid-email':
        return "L'adresse e-mail n'est pas valide ou est mal formatée.";
      case 'user-not-found':
        return "Aucun compte n'a été trouvé avec cette adresse e-mail.";
      case 'wrong-password':
        return "Mot de passe incorrect. Veuillez vérifier votre mot de passe.";
      case 'user-disabled':
        return "Ce compte a été désactivé.";
      case 'email-already-in-use': // Pour l'inscription, mais utile en cas d'erreur inattendue ici
        return "Cette adresse e-mail est déjà utilisée par un autre compte.";
      case 'operation-not-allowed':
        return "La méthode de connexion est désactivée. Veuillez contacter le support.";
      case 'too-many-requests':
        return "Trop de tentatives de connexion. Veuillez réessayer plus tard.";
      case 'invalid-credential':
        return "Les informations d'identification Google fournies sont invalides ou ont expiré.";
      case 'account-exists-with-different-credential':
        return "Un compte existe déjà avec cette adresse e-mail mais avec un autre fournisseur de connexion. Essayez de vous connecter avec cet autre fournisseur.";
      case 'network-request-failed':
        return "Problème de connexion internet. Veuillez vérifier votre connexion.";
      default:
        return "Une erreur inattendue est survenue. Code : $errorCode";
    }
  }



  Future<void> _login() async {
    setState(() => isLoading = true);
    try {
      // 1. Validation côté client pour les champs vides
      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
          NotificationHelper.showError("Veuillez remplir tous les champs obligatoires (Email et Mot de passe).");
        return; // Arrête l'exécution si les champs sont vides
      }

      final user = await _auth.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        // Cette branche ne devrait être atteinte que si AuthService retourne null
        // sans jeter d'exception, ce qui est moins probable avec les rethrow.
        NotificationHelper.showError("La connexion a échoué pour une raison inconnue.");
      }
    } on FirebaseAuthException catch (e) {
      // Intercepte spécifiquement les erreurs de Firebase Auth
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    
    } on Exception catch (e) {
      // Intercepte toute autre exception inattendue
      NotificationHelper.showError("Une erreur inattendue est survenue : ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final user = await _auth.signInWithGoogle();
      if (user != null) {
        if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        // L'utilisateur a annulé la connexion Google
        NotificationHelper.showError("La connexion Google a été annulée ou n'a pas pu être finalisée.");

      }
    } on FirebaseAuthException catch (e) {
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    } on Exception catch (e) {

      NotificationHelper.showError(
        "Une erreur inattendue est survenue lors de la connexion Google : ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginWithTwitter() async {
    setState(() => isLoading = true);
    try {
      final user = await _auth.signInWithTwitter();
      if (user != null) {
        if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        NotificationHelper.showError("La connexion Twitter a échoué pour une raison inconnue.");
      }
    } on FirebaseAuthException catch (e) {
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    } on Exception catch (e) {
      NotificationHelper.showError(
        "Une erreur inattendue est survenue lors de la connexion Twitter : ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loginWithFacebook() async {
    setState(() => isLoading = true);
    try {
      final user = await _auth.signInWithFacebook();
      if (user != null) {
        if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        NotificationHelper.showError("La connexion Facebook a échoué pour une raison inconnue.");
      }
    } on FirebaseAuthException catch (e) {
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    } on Exception catch (e) {
      NotificationHelper.showError(
        "Une erreur inattendue est survenue lors de la connexion Facebook : ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Les méthodes pour Facebook et d'autres pourraient être similaires...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image illustrative en haut
                // Center(
                //   child: Container(
                //     height: 220,
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(24),
                //       gradient: const LinearGradient(
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //         colors: [Color(0xFF5669FF), Color(0xFF7B8FF7)],
                //       ),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Color(0xFF5669FF).withOpacity(0.3),
                //           blurRadius: 20,
                //           offset: const Offset(0, 10),
                //         ),
                //       ],
                //     ),
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(24),
                //       child: Stack(
                //         children: [
                //           // Image de fond - Connexion/Sécurité
                //           // Positioned.fill(
                //           //   child: Image.network(
                //           //     'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800&h=600&fit=crop',
                //           //     fit: BoxFit.cover,
                //           //     color: Colors.black.withOpacity(0.15),
                //           //     colorBlendMode: BlendMode.darken,
                //           //   ),
                //           // ),
                //           // Overlay avec texte
                //           // const Center(
                //           //   child: Column(
                //           //     mainAxisAlignment: MainAxisAlignment.center,
                //           //     children: [
                //           //       Icon(
                //           //         Icons.lock_outline_rounded,
                //           //         size: 48,
                //           //         color: Colors.white,
                //           //       ),
                //           //       SizedBox(height: 12),
                //           //       Text(
                //           //         'Bienvenue !',
                //           //         style: TextStyle(
                //           //           fontSize: 24,
                //           //           fontWeight: FontWeight.bold,
                //           //           color: Colors.white,
                //           //         ),
                //           //       ),
                //           //     ],
                //           //   ),
                //           // ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 40),

                // Titre
                const Center(
                  child: Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Connectez-vous pour continuer',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Champs de saisie
                CustomTextField(
                  label: "Email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: "exemple@email.com",
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Mot de passe",
                  controller: passwordController,
                  obscureText: true,
                  hintText: "Entrez votre mot de passe",
                ),
                const SizedBox(height: 12),

                // Lien "Mot de passe oublié"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.pushNamed(context, "/forgot-password");
                      }
                    },
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(
                        color: Color(0xFF5669FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton de connexion
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF5669FF),
                          ),
                        ),
                      )
                    : CustomButton(text: "Se connecter", onPressed: _login),
                const SizedBox(height: 32),

                // Divider avec "OU"
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OU",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Boutons de connexion sociale
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculer la taille des boutons selon la largeur disponible
                    final double availableWidth = constraints.maxWidth;
                    final double buttonSize = availableWidth < 360
                        ? 50.0
                        : 56.0;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SocialLoginButton(
                          icon: FaIcon(
                            FontAwesomeIcons.xTwitter,
                            color: Colors.white,
                            size: buttonSize * 0.36,
                          ),
                          backgroundColor: Colors.black,
                          onPressed: _loginWithTwitter,
                          size: buttonSize,
                        ),
                        SocialLoginButton(
                          icon: FaIcon(
                            FontAwesomeIcons.facebookF,
                            color: Colors.white,
                            size: buttonSize * 0.36,
                          ),
                          backgroundColor: const Color(0xFF1877F2),
                          onPressed: _loginWithFacebook,
                          size: buttonSize,
                        ),
                        SocialLoginButton(
                          icon: Image.asset(
                            "assets/icons/Google__G__logo.svg.png",
                            width: buttonSize * 0.36,
                            height: buttonSize * 0.36,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: _loginWithGoogle,
                          size: buttonSize,
                        ),
                        SocialLoginButton(
                          icon: FaIcon(
                            FontAwesomeIcons.apple,
                            color: Colors.black,
                            size: buttonSize * 0.36,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: _loginWithGoogle,
                          size: buttonSize,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Lien vers l'inscription
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Vous n'avez pas de compte ? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              "/register",
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: Color(0xFF5669FF),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
