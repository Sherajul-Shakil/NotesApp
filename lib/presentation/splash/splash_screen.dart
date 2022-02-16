import 'package:auto_route/auto_route.dart';
import 'package:notes_firebase_ddd/application/auth/auth_bloc.dart';
import 'package:notes_firebase_ddd/presentation/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_firebase_ddd/presentation/sign_in/sign_in_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //BlocListener run after build has finished
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          authenticated: (_) {
            print("authenticated");
            //context.router.replace(const NotesOverviewPageRoute());
          },
          unAuthenticated: (_) =>
              context.router.replace(const SignInPageRoute()),
        );
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
