import 'package:auto_route/annotations.dart';
import 'package:notes_firebase_ddd/presentation/sign_in/sign_in_page.dart';
import 'package:notes_firebase_ddd/presentation/splash/splash_screen.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute<dynamic>(page: SplashPage, initial: true),
    AutoRoute<dynamic>(page: SignInPage),
    // AutoRoute<dynamic>(page: NotesOverviewPage),
    // AutoRoute<dynamic>(
    //   page: NoteFormPage,
    //   fullscreenDialog: true,
    // ),
  ],
)
class $AppRouter {}
