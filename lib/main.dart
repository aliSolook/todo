/** TODO: top priority
 * add theme
 * add categories everything
 * add profile using shared prefrences and encrypt the databases using the users password
 * 
 */

/** TODO:
 * option 1:
 * use caching for images.
 *
 * the data sources return id, title, and Uint8List
 *
 * the repositories request the data from the data sources and cache the response using
 * a caching library and return id along side titles,
 *
 * ui accesses the images using their id, it sends a request to the repository using the getImage
 * method, the repository uses the cahcing library to return the data
 *
 *
 * option 2:
 * class cachedRemoteDataSource implements DataSource{
 *   final _remoteSource = locator.get<RemoteDataSource>();
 *   final _localSource = locator.get<LocalDataSource>();
 * }
 *
 * ui uses the repository to access the data every time.
 * the list method returns the ids and titles only.
 * no more need for a caching library
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:theme_switcher/theme_switcher.dart';
import 'package:todo/app.dart';
import 'package:todo/di/di.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/hive_init.dart';

import 'features/screen_manager/screen_manager.dart';

void main() async {
  // return runApp(const TestApp());

  WidgetsFlutterBinding.ensureInitialized();

  await hiveInit();

  print('initiating getIt');
  await getItInit();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget material = App(
      builder: (context, appObserver) => ThemeSwitcherBase(
        initThemeMode: ThemeMode.system,
        builder: (context, themeMode, themeObserver) => MaterialApp(
          supportedLocales: const [
            Locale("fa", "IR"),
            // Locale("en", "US"),
          ],
          localizationsDelegates: const [
            PersianMaterialLocalizations.delegate,
            PersianCupertinoLocalizations.delegate,
          ],
          navigatorObservers: [themeObserver, appObserver],
          themeMode: themeMode,
          theme: App.lightTheme,
          darkTheme: App.darkTheme,
          themeAnimationDuration: Duration.zero,
          themeAnimationStyle: AnimationStyle.noAnimation,
          debugShowCheckedModeBanner: false,
          home: Directionality(
            textDirection: TextDirection.rtl,
            // child: TestScreen(),
            // child: MultiBlocProvider(
            //   providers: [
            //     BlocProvider(
            //       create: (context) => TaskListBloc(),
            //     ),
            //     BlocProvider(
            //       create: (context) => ScreenManagerCubit(),
            //     ),
            //   ],
            //   child: RepositoryProvider<ImageRepository>(
            //     create: (context) => locator.get(),
            //     child: const TaskListScreen(index: 0),
            //   ),
            // ),
            child: BlocProvider(
              create: (context) => ScreenManagerCubit(),
              child: const ScreenManager(),
            ),
            // child: RepositoryProvider<ImageRepository>(
            //   create: (context) => locator.get(),
            //   child: BlocProvider(
            //     create: (context) => TaskAddScreenBloc(),
            //     child: const TaskAddScreen(),
            //   ),
            // ),
            // child: BlocProvider(
            //   create: (context) => TaskAddScreenBloc(TaskAddScreenInitState()),
            //   child: const TaskAddScreen(),
            // ),
            // child: MultiBlocProvider(
            //   providers: [
            //     RepositoryProvider<ImageRepository>(
            //       create: (context) => locator.get(),
            //     ),
            //     BlocProvider(
            //       create: (context) => CounterBloc(),
            //     ),
            //     BlocProvider(
            //       create: (context) => CountDownBloc(),
            //     ),
            //   ],
            //   child: const CounterScreen(),
            // ),
          ),
        ),
      ),
    );
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    material = AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: material,
    );

    return material;
  }
}

// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:todo/ui/widgets/pointer_linker_widget.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final GlobalKey _targetKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: InkResponse(
//           key: _targetKey,
//           highlightShape: BoxShape.rectangle,
//           highlightColor: Colors.transparent,
//           onTap: () {
//             print('InkResponse tapped!');
//           },
//           child: const SizedBox(
//             width: 100,
//             height: 100,
//             child: Center(child: Text('Tap Me')),
//           ),
//         ),
//       ),
//       floatingActionButton: PointerLinkerWidget(
//         targetKey: _targetKey,
//         child: const SizedBox(
//           width: 300,
//           height: 300,
//           child: ColoredBox(color: Colors.red),
//         ),
//       ),
//     );
//   }
// }
