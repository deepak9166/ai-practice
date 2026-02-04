import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meditrack/enum/social_user_type.dart';

import '../../firebase_options.dart';

class GoogleAuthService implements SocialAuthService {
  late final GoogleSignIn _googleSignIn;

  GoogleAuthService() {
    _googleSignIn = GoogleSignIn.instance;

    _googleSignIn.initialize(
      clientId: DefaultFirebaseOptions.currentPlatform.androidClientId,
      serverClientId:
          '1030670644569-ml0krniglck17mpmqgumthcvebtupkd4.apps.googleusercontent.com',
    );
  }

  @override
  SocialProvider get provider => SocialProvider.google;

  @override
  Future<SocialUser?> signIn() async {
    final account = await _googleSignIn.authenticate();

    final auth = account.authentication;

    return SocialUser(
      id: account.id,
      email: account.email,
      name: account.displayName ?? '',
      photoUrl: account.photoUrl ?? '',
      accessToken: auth.idToken ?? '',
      idToken: auth.idToken ?? '',
      provider: provider,
    );
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();
}

class FacebookAuthService implements SocialAuthService {
  @override
  Future<SocialUser> signIn() async {
    // final result = await FacebookAuth.instance.login();
    // final result = await FacebookAuth.instance.login();

    // if (result.status != LoginStatus.success) {
    //   throw Exception('Facebook login failed');
    // }

    // final credential = FacebookAuthProvider.credential(
    //   result.accessToken!.token,
    // );

    // var userObject = await FirebaseAuth.instance.signInWithCredential(
    //   credential,
    // );

    // var account = userObject.user;
    // var idToken = (await userObject.user?.getIdToken()) ?? '';

    // return SocialUser(
    //   id: account?.uid ?? '',
    //   email: account?.email ?? '',
    //   name: account?.displayName ?? '',
    //   photoUrl: account?.photoURL ?? '',
    //   accessToken: userObject.credential?.accessToken ?? '',
    //   idToken: idToken,
    //   provider: provider,
    // );
    throw "Not Implemented FB SignIN";
  }

  @override
  Future<void> signOut() async {
    // await FacebookAuth.instance.logOut();
    throw "Not Implemented SignOut";
  }

  @override
  SocialProvider get provider => SocialProvider.facebook;
}

class SocialUser {
  final String id;
  final String email;
  final String name;
  final String photoUrl;
  final String accessToken;
  final String idToken;
  final SocialProvider provider;

  SocialUser({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.accessToken,
    required this.idToken,
    required this.provider,
  });
}

abstract class SocialAuthService {
  SocialProvider get provider;

  Future<SocialUser?> signIn();

  Future<void> signOut();
}
