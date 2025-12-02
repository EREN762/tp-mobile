import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _auth = AuthService();

  bool isLoading = false;
  bool linkSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String _getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return "L'adresse e-mail n'est pas valide.";
      case 'user-not-found':
        return "Aucun compte n'a été trouvé avec cette adresse e-mail.";
      case 'weak-password':
        return "Le mot de passe est trop faible. Il doit contenir au moins 6 caractères.";
      case 'network-request-failed':
        return "Problème de connexion internet. Veuillez vérifier votre connexion.";
      default:
        return "Une erreur est survenue. Code : $errorCode";
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFFEF5350),
    ).show(context);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    Flushbar(
      message: message,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF4CAF50),
    ).show(context);
  }

  Future<void> _sendResetLink() async {
    if (emailController.text.trim().isEmpty) {
      _showError("Veuillez saisir votre adresse e-mail.");
      return;
    }

    setState(() => isLoading = true);
    try {
      // Envoyer le lien de réinitialisation par email via Firebase
      await _auth.sendPasswordResetEmail(emailController.text.trim());

      setState(() {
        linkSent = true;
        isLoading = false;
      });

      _showSuccess(
        "Un lien de réinitialisation a été envoyé à ${emailController.text.trim()}. Veuillez vérifier votre boîte de réception et suivre les instructions.",
      );
    } on FirebaseAuthException catch (e) {
      _showError(_getFriendlyErrorMessage(e.code));
      setState(() => isLoading = false);
    } catch (e) {
      _showError("Une erreur est survenue : ${e.toString()}");
      setState(() => isLoading = false);
    }
  }

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
                // Bouton retour
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF2D3748),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),

                // Image illustrative - Réinitialisation de mot de passe
                // Center(
                //   child: Container(
                //     height: 200,
                //     width: 200,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(20),
                //       image: const DecorationImage(
                //         image: NetworkImage(
                //           'https://images.unsplash.com/photo-1633265486064-086b219458ec?w=400&h=400&fit=crop',
                //         ),
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 32),

                // Titre
                const Center(
                  child: Text(
                    'Réinitialiser le mot de passe',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    linkSent
                        ? 'Vérifiez votre boîte de réception et suivez le lien pour réinitialiser votre mot de passe.'
                        : 'Saisissez votre adresse e-mail pour recevoir un lien de réinitialisation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Formulaire d'envoi du lien
                if (!linkSent) ...[
                  CustomTextField(
                    label: "Adresse e-mail",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "exemple@email.com",
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF5669FF),
                            ),
                          ),
                        )
                      : CustomButton(
                          text: "Envoyer le lien",
                          onPressed: _sendResetLink,
                        ),
                ] else ...[
                  // Message de confirmation
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF4CAF50),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Lien envoyé !',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Un email a été envoyé. Cliquez sur le lien dans l\'email pour réinitialiser votre mot de passe.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _sendResetLink,
                          child: const Text(
                            "Renvoyer le lien",
                            style: TextStyle(
                              color: Color(0xFF5669FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      child: const Text(
                        "Retour à la connexion",
                        style: TextStyle(
                          color: Color(0xFF5669FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
