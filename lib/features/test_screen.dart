import 'package:flutter/material.dart';
import 'package:theme_switcher/theme_switcher.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:defer_pointer/defer_pointer.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcherBase(
      builder: (context, themeMode, routeObserver) => MaterialApp(
        themeAnimationStyle: AnimationStyle.noAnimation,
        themeMode: themeMode,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        navigatorObservers: [routeObserver],
        home: const TestScreen(),
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: double.infinity,
      child: Scaffold(
        body: Center(
          child: DeferredPointerHandler(
            child: SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
                  DeferPointer(
                    child: Transform.translate(
                      offset: const Offset(0, -130),
                      child: MouseRegion(
                        hitTestBehavior: HitTestBehavior.opaque,
                        cursor: SystemMouseCursors.click,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.abc),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  // Future<Path> svgToPath(String src) async {
  //   final svg = await rootBundle.loadString(src);

  //   final doc = parse(svg);
  //   final pathElements = doc.getElementsByTagName('path');
  //   final pathDatas = pathElements
  //       .map((e) => e.attributes['d'])
  //       .whereType<String>()
  //       .toList();

  //   final paths = pathDatas.map(parseSvgPath);

  //   final path = Path();

  //   for (var e in paths) {
  //     path.addPath(e, Offset.zero);
  //   }

  //   final size = path.getBounds().size;
  //   return path.transform(
  //     Matrix4.diagonal3Values(1 / size.width, 1 / size.height, 1).storage,
  //   );
  // }
}
