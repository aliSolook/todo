import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo/features/counter/counter.dart';
import 'package:todo/features/home/home.dart';
import 'package:todo/features/screen_manager/screen_manager.dart';
import 'package:todo/constants/constants.dart';
import 'package:todo/features/image/repository/image_repository.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/task/task.dart';
import 'package:todo/features/widgets/widgets.dart';
import 'package:theme_switcher/theme_switcher.dart';

ScreenManagerCubit _getCubit(BuildContext context) =>
    BlocProvider.of<ScreenManagerCubit>(context);

class ScreenManager extends StatelessWidget {
  const ScreenManager({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ImageRepository>(
      create: (context) => locator.get(),
      child: DefaultTabController(
        length: 3,
        child: ThemeSwitcherArea(
          darkModeStyle: const ThemeSwitcherAnimationStyle(forward: false),
          child: Scaffold(
            // drawer: _getDrawer(context),
            appBar: _getAppBar(context),
            floatingActionButton: _getFab(context),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            body: SafeArea(
              bottom: false,
              top: false,
              child: Builder(builder: _body),
            ),
            bottomNavigationBar: _bottomNavigationBar(context),
          ),
        ),
      ),
    );
  }

  Drawer _getDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DividerTheme(
            data: const DividerThemeData(color: Colors.transparent),
            child: DrawerHeader(
              decoration: ShapeDecoration(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                color: ColorScheme.of(context).surfaceContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(
                              color: ColorScheme.of(context).primary,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/icons/image_icon.svg',
                            width: 40,
                            colorFilter: ColorFilter.mode(
                              ColorScheme.of(context).onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const ThemeSwitcherButton(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('title'),
                  const Text('sub title', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          ListTile(
            onTap: () {},
            title: const Text('settings'),
          ),
        ],
      ),
    );
  }

  AppBar _getAppBar(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      title: const Text('تو‌ دو'),
      actions: [const ThemeSwitcherButton()],
    );
  }

  Widget _getFab(BuildContext context) {
    return BlocBuilder<ScreenManagerCubit, ScreenManagerState>(
      builder: (context, state) {
        return TweenAnimationBuilder(
          tween: Tween<double>(end: state.isFabVisible ? 1 : 0),
          duration: animationDuration * .5,
          builder: (context, value, child) {
            return Visibility(
              visible: value != 0,
              child: Transform.rotate(
                angle: pi * .5 * value,
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              ),
            );
          },
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: ColorScheme.of(context).primary,
            onPressed: state.fabCallbacks[state.selectedIndex],
            child: Icon(
              Icons.add_rounded,
              color: ColorScheme.of(context).onPrimary,
              size: 32,
            ),
          ),
        );
      },
    );
  }

  Widget _bottomNavigationBar(BuildContext context) {
    final shadow =
        kElevationToShadow[Theme.of(
                  context,
                ).bottomAppBarTheme.elevation?.round() ??
                3]!
            .map(
              (e) => e.copyWith(
                offset: -e.offset,
                color: ColorScheme.of(
                  context,
                ).shadow.withAlpha(e.color.a * 255 ~/ 1),
              ),
            )
            .toList();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surfaceContainer,
        boxShadow: shadow,
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: TabBar(
            onTap: (index) {
              _getCubit(context).screenChanged(index);
            },
            splashBorderRadius: const BorderRadius.all(Radius.circular(10)),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            indicator: OverlineTabIndicator(
              borderSide: BorderSide(
                color: ColorScheme.of(context).primary,
                width: 3,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
            indicatorColor: ColorScheme.of(context).primary,
            tabs: [
              tabBarAnimator(
                context,
                child: SvgPicture.asset(
                  'assets/icons/home_icon.svg',
                  colorFilter: ColorFilter.mode(
                    ColorScheme.of(context).onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                selectedChild: SvgPicture.asset(
                  'assets/icons/home_filled_icon.svg',
                ),
                index: 0,
              ),
              tabBarAnimator(
                context,
                child: SvgPicture.asset(
                  'assets/icons/calendar_icon.svg',
                  colorFilter: ColorFilter.mode(
                    ColorScheme.of(context).onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                selectedChild: SvgPicture.asset(
                  'assets/icons/calendar_filled_icon.svg',
                ),
                index: 1,
              ),
              tabBarAnimator(
                context,
                child: SvgPicture.asset(
                  'assets/icons/clock_icon.svg',
                  colorFilter: ColorFilter.mode(
                    ColorScheme.of(context).onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                  width: 25,
                  height: 25,
                ),
                selectedChild: SvgPicture.asset(
                  'assets/icons/clock_filled_icon.svg',
                ),
                index: 2,
              ),
              // tabBarAnimator(
              //   child: SvgPicture.asset(
              //     'assets/icons/settings_icon.svg',
              //     colorFilter: ColorFilter.mode(
              //       ColorScheme.of(context).onSurfaceVariant,
              //       BlendMode.srcIn,
              //     ),
              //   ),
              //   selectedChild: SvgPicture.asset(
              //     'assets/icons/settings_icon.svg',
              //   ),
              //   index: 3,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabBarAnimator(
    BuildContext context, {
    required Widget child,
    required Widget selectedChild,
    required int index,
  }) {
    return BlocBuilder<ScreenManagerCubit, ScreenManagerState>(
      buildWhen: (previous, current) =>
          current.selectedIndex != previous.selectedIndex &&
          (current.selectedIndex == index || previous.selectedIndex == index),
      builder: (context, state) {
        return Tab(
          child: AnimatedSwitcher(
            duration: animationDuration,
            child: SizedBox(
              key: UniqueKey(),
              child: state.selectedIndex == index ? selectedChild : child,
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return BlocListener<ScreenManagerCubit, ScreenManagerState>(
      listenWhen: (previous, current) =>
          previous.selectedIndex != current.selectedIndex,
      listener: (context, state) {
        if (state.selectedIndex != controller.index) {
          controller.index = state.selectedIndex;
        }
      },
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _screenWrapper(
            context,
            const HomeScreen(index: 0),
            blocProviders: [
              BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
            ],
          ),
          _screenWrapper(
            context,
            const TaskListScreen(index: 1),
            blocProviders: [
              BlocProvider<TaskListBloc>(create: (_) => TaskListBloc()),
            ],
          ),
          _screenWrapper(
            context,
            const CounterListScreen(index: 2),
            blocProviders: [
              BlocProvider<CounterListBloc>(
                create: (context) => CounterListBloc(),
              ),
              BlocProvider<CountDownBloc>(
                create: (context) => CountDownBloc(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _screenWrapper(
    BuildContext context,
    Widget child, {
    List<BlocProvider>? blocProviders,
  }) {
    final cubit = _getCubit(context);
    return LayoutBuilder(
      builder: (context, constraints) => KeepAliveWidget(
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            cubit.scrollMetricsChanged(notification, constraints.biggest);
            return false;
          },
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              if ((notification.scrollDelta ?? 0) == 0) return false;
              cubit.scrolled(notification);
              return false;
            },
            child: blocProviders == null
                ? child
                : MultiBlocProvider(
                    providers: blocProviders,
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
