import 'package:flutter/material.dart';
import 'screen/Homepage/accueil_page.dart';
import 'screen/omboard/onboarding_screen.dart';
import 'screen/splash/splash_screen.dart';
import 'screen/authentification/login_page.dart';
import 'screen/authentification/register_page.dart';
import 'screen/authentification/editPass.dart';
import 'screen/Info/filière_Page.dart';
import 'screen/Info/objectif_page.dart';
import 'screen/Info/list_filière.dart';
import 'screenAdmin/AdAccueil_Page.dart';
import 'package:education/screen/ScreenMod%C3%A9rateur/accueilMod%C3%A9rateur.dart';
import 'package:education/models/user.dart';
import 'package:education/screenAdmin/Add_filiere.dart';
import 'package:education/screenAdmin/AddCours_page.dart';
import 'package:education/screenAdmin/Profile_admin.dart';
import 'package:education/screenAdmin/listeADD/ListExercice.dart';
import 'package:education/screenAdmin/AddObjectif_page.dart';
import 'package:education/screenAdmin/AddQuiz_page.dart';
import 'package:education/screenAdmin/listeADD/ListeFill.dart';
import 'package:education/screenAdmin/listeADD/ListObjectif.dart';
import 'package:education/screenAdmin/listeADD/ListQuiz.dart';
import 'package:education/screenAdmin/listeADD/ListQuiz.dart';
import 'package:education/screenAdmin/listeADD/ListMod.dart';
import 'package:education/screenAdmin/listeADD/ListApprenants.dart';
import 'package:education/screen/omboard/onboarding_screen.dart';
import 'package:education/screenAdmin/listeADD/ListCours.dart';
import 'package:education/screen/Homepage/accueil_page.dart';
import 'package:education/screen/Profil/avatar.dart';
import 'package:education/screen/Info/mes_info.dart';
import 'package:education/screen/Profil/boite_profil.dart';
//import 'package:education/screen/Compte/theme_provider.dart';
import 'package:education/screen/Compte/setting.dart';
import 'package:education/screen/Quiz/Contenu/architecture.dart';
import 'package:education/screen/Quiz/list_favori.dart';
import 'package:education/screen/Quiz/success.dart';
//import 'package:education/screen/Quiz/quiz_page.dart';
//import 'package:flutter_localization/flutter_localization.dart';
//import 'package:education/screenAdmin/listeADD/ListCours.dart';
import 'package:education/screenAdmin/ListCour.dart';
import 'package:education/screenAdmin/ListFill.dart';
import 'package:education/screenAdmin/ListObject.dart';
import 'package:education/screenAdmin/ListExo.dart';
import 'package:education/screenAdmin/Listquiz.dart';
import 'package:education/screenAdmin/Liste_app_quiz.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  configLoading();
  runApp(const MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 0)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green // Changer la couleur ici
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
    //..customAnimation = CustomAnimation();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(key: Key('splash')),
        '/login': (context) => const LoginPage(key: Key('login')),
        '/OnboardingScreen': (context) => const OnboardingScreen(key: Key('OnboardingScreen')),
        '/register': (context) => const RegisterPage(key: Key('register')),
        '/editPass': (context) => const EditPassPage(key: Key('editPass')),
        //'/IntroPage': (context) => const IntroPage(key: Key('IntroPage')),
        '/FilierePage': (context) => const FilierePage(key: Key('FilierePage')),
        '/AvatarPage': (context) => const AvatarPage(key: Key('AvatarPage')),
        '/ObjectifPage': (context) => const ObjectifPage(key: Key('ObjectifPage')),
        '/ListFiliere': (context) => const ListFiliere(key: Key('ListFiliere')),
        '/BoitePage': (context) => const BoitePage(key: Key('BoitePage')),
       // '/AccueilPage': (context) => const AccueilPage(key: Key('AccueilPage')),
        '/AccueilMod': (context) => const AccueilMod(key: Key('AccueilMod')),
        '/AdAccueilPage': (context) => const AdAccueilPage(key: Key('AdAccueilPage')),
        '/AddFiliere': (context) => const AddFiliere(key: Key('AddFiliere')),
        '/MesinfoPage': (context) => const MesinfoPage(key: Key('MesinfoPage')),
        //'/ObjectifPage': (context) => const ObjectifPage(key: Key('ObjectifPage')),
        //'/Architecture': (context) => const Architecture(key: Key('Architecture')),
        '/AddQuiz': (context) => const AddQuiz(key: Key('AddQuiz')),
        '/AddCours': (context) => const AddCours(key: Key('AddCours')),
        '/AdminProfilePage': (context) => const AdminProfilePage(key: Key('AdminProfilePage')),
        //'/QuizPage': (context) => const QuizPage(key: Key('QuizPage')),
        '/ListFill': (context) => const ListFill(key: Key('ListFill')),
        '/ListObjectif': (context) => const ListObjectif(),
        //'/ListeFilierePage': (context) => ListeFilierePage(),
        '/ListCours': (context) => const ListCours(),
        '/ListQuiz': (context) => const ListQuiz(),
        '/ListExercices': (context) => const ListExercices(),
        //'/SuccessPage': (context) => SuccessPage(),

        //MODERATEUR LISTE 
        '/ListFilieree': (context) => const ListFilieree(key: Key('ListFilieree')),
        '/ListeObjectif': (context) => const ListeObjectif(),
        //'/ListeFilierePage': (context) => ListeFilierePage(),
        '/ListeCours': (context) => const ListeCours(),
        '/ListeQuiz': (context) => const ListeQuiz(),
        '/ListeExercices': (context) => const ListeExercices(),
        ////
        
        '/ListMod': (context) => const ListMod(),
        '/ListApp': (context) => const ListApp(),
        '/ListAppQuiz': (context) =>const ListAppQuiz(),
        //'/ListFavoriPage': (context) => const ListFavoriPage(key: Key('ListFavoriPage')),
      },
      builder: EasyLoading.init(),
    );  
  }
}
