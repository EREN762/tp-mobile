import 'package:flutter/material.dart';
import "../widgets/custom_button.dart";
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import '../services/auth_service.dart';
import "../utils/notification_helper.dart";
import 'package:firebase_auth/firebase_auth.dart'; // Importez FirebaseAuth pour les exceptions
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  bool isLoading = false;
  bool showForm = false;

  // Fonction pour traduire les codes d'erreur Firebase en messages amicaux
  String _getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'web-context-canceled':
        return "La connexion a été annulée par l'utilisateur. Veuillez réessayer.";
      case 'invalid-email':
        return "L'adresse e-mail n'est pas valide ou est mal formatée.";
      case 'weak-password':
        return "Le mot de passe est trop faible. Il doit contenir au moins 6 caractères.";
      case 'email-already-in-use':
        return "Un compte existe déjà avec cette adresse e-mail. Veuillez vous connecter ou utiliser une autre adresse.";
      case 'operation-not-allowed':
        return "L'inscription avec email/mot de passe est désactivée. Veuillez contacter le support.";
      case 'network-request-failed':
        return "Problème de connexion internet. Veuillez vérifier votre connexion.";
      case 'popup-closed-by-user': // Ajout pour gérer l'annulation des popups OAuth
        return "Connexion annulée par l'utilisateur.";
      case 'web-context-already-presented': // Ajout pour gérer l'erreur de contexte web
        return "Une opération de connexion est déjà en cours. Veuillez patienter ou réessayer.";
      case 'web-internal-error': // Ajout pour gérer l'erreur interne du web
        return "Erreur interne lors de la connexion via le navigateur. Veuillez réessayer.";
      default:
        return "Une erreur inattendue est survenue lors de l'inscription. Code : $errorCode";
    }
  }

 



  Future<void> _register() async {
    setState(() => isLoading = true);
    try {
      // --- 1. Validation des champs vides ---
      if (nameController.text.trim().isEmpty ||
          emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty) {
        NotificationHelper.showError(
          "Veuillez remplir tous les champs (Nom, Email, Mot de passe).",
        );
        return; // Arrête l'exécution si des champs sont vides
      }

      // --- 2. Appel au service d'authentification ---
      final user = await _auth.registerWithEmailAndPassword(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // --- 3. Vérification du succès et affichage du message ---
      if (user != null) {
        NotificationHelper.showSuccess("Compte créé avec succès !");
        // Ancien code de redirection commenté :
        // await Future.delayed(const Duration(seconds: 2));
        // if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        NotificationHelper.showError("L'inscription a échoué pour une raison inconnue.");
      }
    } on FirebaseAuthException catch (e) {
      // --- 4. Gestion des erreurs spécifiques de Firebase Auth ---
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    } on Exception catch (e) {
      // --- 5. Gestion des autres exceptions inattendues ---
      NotificationHelper.showError("Une erreur inattendue est survenue : ${e.toString()}");
    } finally {
      // --- 6. Réinitialisation du statut de chargement ---
      setState(() => isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final user = await _auth.signInWithGoogle();
      if (user != null) {
        NotificationHelper.showSuccess("Inscription via Google avec succès !");
        // Ancien code de redirection commenté :
        // if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        NotificationHelper.showError(
          "La connexion Google a été annulée ou n'a pas pu être finalisée.",
        );
      }
    } on FirebaseAuthException catch (e) {
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    } on Exception catch (e) {
      NotificationHelper.showError(
        "Une erreur est survenue lors de l'inscription Google : ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _signUpWithTwitter() async {
    setState(() => isLoading = true);
    try {
      final user = await _auth.signInWithTwitter();
      if (user != null) {
        NotificationHelper.showSuccess("Inscription via X avec succès !");
        // Ancien code de redirection commenté :
        // if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        NotificationHelper.showError("La connexion X a échoué ou a été annulée.");
      }
    } on FirebaseAuthException catch (e) {
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    } on Exception catch (e) {
      NotificationHelper.showError(
        "Une erreur est survenue lors de l'inscription Twitter : ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _signUpWithFacebook() async {
    setState(() => isLoading = true);
    try {
      final user = await _auth.signInWithFacebook();
      if (user != null) {
        NotificationHelper.showSuccess("Inscription via Facebook avec succès !");
        // Ancien code de redirection commenté :
        // if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        NotificationHelper.showError("La connexion Facebook a échoué ou a été annulée.");
      }
    } on FirebaseAuthException catch (e) {
      NotificationHelper.showError(_getFriendlyErrorMessage(e.code));
    } on Exception catch (e) {
      NotificationHelper.showError(
        "Une erreur est survenue lors de l'inscription Facebook : ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _signUpWithApple() async {
    // Si _signUpWithApple appelle _signUpWithGoogle, la gestion des messages
    // et l'absence de redirection seront déjà appliquées par _signUpWithGoogle.
    // Si vous implémentez un vrai signInWithApple, assurez-vous de ne pas rediriger.
    await _signUpWithGoogle(); // Conserve l'appel pour l'exemple
  }

  void _handleRegisterButton() {
    if (!showForm) {
      setState(() => showForm = true);
      return;
    }
    _register();
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
                //         colors: [Color(0xFF7B8FF7), Color(0xFF5669FF)],
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
                //           // Image de fond - Inscription/Création de compte
                //           Positioned.fill(
                //             child: Image.network(
                //               'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop',
                //               fit: BoxFit.cover,
                //               color: Colors.black.withOpacity(0.15),
                //               colorBlendMode: BlendMode.darken,
                //             ),
                //           ),
                //           // Overlay avec texte
                //           const Center(
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Icon(
                //                   Icons.person_add_outlined,
                //                   size: 48,
                //                   color: Colors.white,
                //                 ),
                //                 SizedBox(height: 12),
                //                 Text(
                //                   'Rejoignez-nous !',
                //                   style: TextStyle(
                //                     fontSize: 24,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.white,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 40),

                // Titre
                const Center(
                  child: Text(
                    "Créer un compte",
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
                    showForm
                        ? 'Remplissez les informations ci-dessous'
                        : 'Choisissez votre méthode d\'inscription',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                if (showForm) ...[
                  // Formulaire d'inscription
                  CustomTextField(
                    label: "Nom complet",
                    controller: nameController,
                    hintText: "Votre nom",
                  ),
                  const SizedBox(height: 20),
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
                    hintText: "Au moins 6 caractères",
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
                          text: "Créer un compte",
                          onPressed: _handleRegisterButton,
                        ),
                ] else ...[
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
                            onPressed: _signUpWithTwitter,
                            size: buttonSize,
                          ),
                          SocialLoginButton(
                            icon: FaIcon(
                              FontAwesomeIcons.facebookF,
                              color: Colors.white,
                              size: buttonSize * 0.36,
                            ),
                            backgroundColor: const Color(0xFF1877F2),
                            onPressed: _signUpWithFacebook,
                            size: buttonSize,
                          ),
                          SocialLoginButton(
                            icon: Image.asset(
                              "assets/icons/Google__G__logo.svg.png",
                              width: buttonSize * 0.36,
                              height: buttonSize * 0.36,
                            ),
                            backgroundColor: Colors.white,
                            onPressed: _signUpWithGoogle,
                            size: buttonSize,
                          ),
                          SocialLoginButton(
                            icon: FaIcon(
                              FontAwesomeIcons.apple,
                              color: Colors.black,
                              size: buttonSize * 0.36,
                            ),
                            backgroundColor: Colors.white,
                            onPressed: _signUpWithApple,
                            size: buttonSize,
                          ),
                        ],
                      );
                    },
                  ),
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

                  // Bouton pour afficher le formulaire
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF5669FF),
                            ),
                          ),
                        )
                      : CustomButton(
                          text: "Créer un compte",
                          onPressed: _handleRegisterButton,
                        ),
                ],
                const SizedBox(height: 24),

                // Lien vers la connexion
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Vous avez déjà un compte ? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, "/login");
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Se connecter",
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
