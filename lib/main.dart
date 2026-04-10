import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection.dart';
import 'core/services/prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/scan/bloc/scan_bloc.dart';
import 'features/duplicate/bloc/duplicate_bloc.dart';
import 'features/sort/bloc/sort_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await PrefsService.init();
  await setupDependencies();

  runApp(const SemanticFinderApp());
}

class SemanticFinderApp extends StatelessWidget {
  const SemanticFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<ScanBloc>()),
        BlocProvider(create: (_) => GetIt.I<DuplicateBloc>()),
        BlocProvider(create: (_) => GetIt.I<SortBloc>()),
      ],
      child: MaterialApp(
        title: 'Semantic File Finder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: PrefsService.isFirstLaunch
            ? const OnboardingScreen()
            : const HomeScreen(),
      ),
    );
  }
}

