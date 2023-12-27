import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/blocs/selectedOrder/selected_order_bloc.dart';
import 'package:ti_quai/firestore/firestore_service.dart';
import 'package:ti_quai/pages/ArticleSearchPage.dart';
import 'package:ti_quai/pages/EditOrAddOrderScreen.dart';
import 'package:ti_quai/pages/HomeScreen.dart';
import 'custom_materials/theme.dart';
import 'blocs/article/article_bloc.dart';
import 'blocs/order/order_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final fireStoreService = FirestoreService();
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrdersBloc>(
            create: (context) => OrdersBloc(fireStoreService, false)),
        BlocProvider<SelectedOrderBloc>(
          create: (context) => SelectedOrderBloc(),
        ),
        BlocProvider<ArticlesBloc>(create: (context) => ArticlesBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(extensions: <ThemeExtension<dynamic>>[
          const CustomColors(
            primary: Color(0xFF7AE582),
            //For main products and menu buttons
            primaryDark: Color(0xFF25A18E),
            primaryLight: Color(0xFF9FFFCB),
            secondary: Color(0xFFF79256),
            //For promotions and action buttons
            secondaryLight: Color(0xFFFBD1A2),
            tertiary: Color(0xFF00A5CF),
            //Main background color
            tertiaryDark: Color(0xFF004E64),
            special: Color(0xFFD4E997),
            //For special elements such as comments and supplements
            cardQuarterTransparency: Color(0x4DFFFFFF),
            //White 30% alpha
            cardHalfTransparency: Color(0x80FFFFFF), //White 50% alpha
          ),
        ]),
        initialRoute: "/home",
        routes: {
          "/home": (context) => Homescreen(),
          "/order": (context) => EditOrAddOrderScreen(),
          "/articles": (context) => ArticleSearchPage(),
        },
      ),
    );
  }
}
