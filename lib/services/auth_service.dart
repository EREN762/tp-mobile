import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // clientId: kIsWeb
    //     ? '897047251286-blohj6d6cbj6670fiu44dvoegecdom4r.apps.googleusercontent.com'
    //     : null,
  );

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instance de Firestore
  final FacebookAuth _facebookAuth =
      FacebookAuth.instance; // Instance de FacebookAuth

  // Méthode pour obtenir l'utilisateur actuellement connecté
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Méthode d'inscription avec email, mot de passe et nom
  Future<User?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Mettre à jour le nom d'affichage de l'utilisateur Firebase Auth
        await user.updateDisplayName(name);
        // Recharger l'utilisateur pour que le displayName soit mis à jour localement
        await user.reload();
        user = _auth.currentUser; // Récupérer l'utilisateur mis à jour

        // Enregistrer le nom de l'utilisateur dans la collection 'users' de Firestore
        await _firestore.collection('users').doc(user!.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(), // Ajoute un horodatage
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques d'authentification
      print('Erreur d\'inscription : ${e.message}');
      rethrow; // Renvoyer l'exception pour une gestion ultérieure
    } catch (e) {
      // Gérer toute autre erreur inattendue
      print('Une erreur inattendue est survenue lors de l\'inscription : $e');
      rethrow;
    }
  }

  // Méthode de connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion : ${e.message}');
      rethrow;
    } catch (e) {
      print('Une erreur inattendue est survenue lors de la connexion : $e');
      rethrow;
    }
  }

  // Méthode de connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtenir les détails d'authentification de la requête
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) {
        // L'utilisateur a annulé la connexion Google
        print('Connexion Google annulée par l\'utilisateur.');
        return null;
      }

      // Créer un nouveau credential Firebase avec le token Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // S'authentifier auprès de Firebase avec le credential Google
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Vérifier si c'est une nouvelle inscription Google pour ajouter à Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name':
                user.displayName ??
                'Google User', // Utiliser le nom Google ou un par défaut
            'email': user.email ?? 'No Email',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion Google : ${e.message}');
      rethrow;
    } catch (e) {
      print(
        'Une erreur inattendue est survenue lors de la connexion Google : $e',
      );
      rethrow;
    }
  }

  //MÉTHODE : Connexion avec Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth
          .login(); // Lance le processus de connexion Facebook

      if (result.status == LoginStatus.success) {
        // Si la connexion Facebook est réussie, obtenez les tokens
        final AccessToken accessToken = result
            .accessToken!; // On utilise '!' car le success garantit sa présence

        // Créez un credential Firebase avec les tokens Facebook
        // La propriété 'token' de l'objet AccessToken contient la chaîne du token
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token,
        );

        // S'authentifier auprès de Firebase avec le credential Facebook
        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        User? user = userCredential.user;

        if (user != null) {
          // Vérifier si c'est une nouvelle inscription Facebook pour ajouter à Firestore
          final userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (!userDoc.exists) {
            await _firestore.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'name':
                  user.displayName ??
                  'Facebook User', // Utiliser le nom Facebook ou un par défaut
              'email': user.email ?? 'No Email',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
        return user;
      } else if (result.status == LoginStatus.cancelled) {
        print('Connexion Facebook annulée par l\'utilisateur.');
        return null;
      } else {
        // En cas d'échec de la connexion Facebook (ex: LoginStatus.failed)
        print('Erreur de connexion Facebook : ${result.message}');
        throw Exception(result.message ?? "La connexion Facebook a échoué.");
      }
    } on FirebaseAuthException catch (e) {
      print(
        'Erreur de connexion Facebook (FirebaseAuthException) : ${e.message}',
      );
      rethrow;
    } catch (e) {
      print(
        'Une erreur inattendue est survenue lors de la connexion Facebook (AuthService) : $e',
      );
      rethrow;
    }
  }

  // NOUVELLE MÉTHODE : Connexion avec X (Twitter)
  Future<User?> signInWithTwitter() async {
    try {
      // 1. Crée une instance du fournisseur d'authentification Twitter.
      // Pas besoin de package Flutter tiers pour cela, c'est géré par firebase_auth.
      final TwitterAuthProvider twitterProvider = TwitterAuthProvider();

      // 2. Tente de se connecter avec le fournisseur Twitter.
      // Cela ouvrira une fenêtre ou un onglet de navigateur pour l'authentification Twitter.
      final UserCredential userCredential = await _auth.signInWithProvider(
        twitterProvider,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Vérifier si c'est une nouvelle inscription Twitter pour ajouter à Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name':
                user.displayName ??
                'Twitter User', // Utiliser le nom Twitter ou un par défaut
            'email':
                user.email ??
                'No Email', // L'email ne sera pas toujours disponible avec Twitter (dépend des permissions)
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques à Firebase Authentication (ex: utilisateur annule)
      print(
        'Erreur de connexion Twitter (FirebaseAuthException) : ${e.code} - ${e.message}',
      );
      if (e.code == 'account-exists-with-different-credential') {
        // Gérer le cas où l'e-mail est déjà utilisé par un autre fournisseur
        // Vous pouvez demander à l'utilisateur de se connecter avec l'autre méthode
        // Ou lier les comptes si c'est géré par votre application.
        print('L\'e-mail est déjà utilisé par un autre compte.');
      } else if (e.code == 'popup-closed-by-user') {
        print('L\'utilisateur a fermé la fenêtre de connexion.');
        return null; // Retourne null si l'utilisateur annule explicitement
      }
      rethrow; // Renvoyer l'exception pour une gestion au niveau de l'UI
    } catch (e) {
      // Gérer toute autre erreur inattendue
      print(
        'Une erreur inattendue est survenue lors de la connexion Twitter (AuthService) : $e',
      );
      rethrow;
    }
  }

  // Méthode de déconnexion
  Future<void> signOut() async {
    try {
      await _googleSignIn
          .signOut(); // Déconnexion de Google si l'utilisateur était connecté via Google
      await _facebookAuth
          .logOut(); // Déconnexion de Facebook si l'utilisateur était connecté via Facebook
      await _auth.signOut(); // Déconnexion de Firebase Auth
      print('Utilisateur déconnecté.');
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
  }

  // Stream pour écouter les changements d'état de l'authentification
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Méthode pour envoyer un email de réinitialisation de mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Email de réinitialisation envoyé à $email');
    } on FirebaseAuthException catch (e) {
      print(
        'Erreur lors de l\'envoi de l\'email de réinitialisation : ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('Une erreur inattendue est survenue : $e');
      rethrow;
    }
  }

  // Méthode pour vérifier le code de réinitialisation (Firebase gère cela via le lien dans l'email)
  // Pour un code à 6 chiffres personnalisé, il faudrait utiliser un service backend
  // Ici, on utilise la méthode Firebase standard qui envoie un lien par email
  // L'utilisateur clique sur le lien et peut réinitialiser son mot de passe

  // Méthode pour confirmer la réinitialisation du mot de passe avec le code
  // Note: Firebase Auth utilise des liens de réinitialisation, pas des codes à 6 chiffres
  // Pour implémenter un code à 6 chiffres, il faudrait utiliser Firebase Functions
  // ou un service backend. Pour l'instant, on utilise la méthode standard Firebase.

  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      print('Mot de passe réinitialisé avec succès');
    } on FirebaseAuthException catch (e) {
      print(
        'Erreur lors de la réinitialisation du mot de passe : ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('Une erreur inattendue est survenue : $e');
      rethrow;
    }
  }
}
