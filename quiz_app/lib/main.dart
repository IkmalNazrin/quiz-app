import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'core/injection/app_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'package:quiz_features/quiz_features.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';
import 'package:quiz_infrastructure/quiz_infrastructure.dart';
import 'package:quiz_domain/quiz_domain.dart';
import 'package:quiz_ui_core/src/core_presentation/widgets/compromised_device_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Activate App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  // Initialize Secure Storage
  final secureStorage = SecureStorageServiceImpl();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SupabaseSecureStorage(secureStorage),
    ),
  );

  final supabase = Supabase.instance.client;

  // Initialize Observability Services with Supabase Client
  AppLogger.initialize(supabase);
  ErrorReporterService.initialize(supabase);
  PerformanceService.initialize(supabase);

  AppLogger.i('Application starting...', category: LogCategory.system);

  // Enforce Device Integrity. ADR-026 mandates a fail-closed posture.
  final integrityService = DeviceIntegrityService();
  final isCompromised = await integrityService.isDeviceCompromised();

  if (isCompromised) {
    AppLogger.e('Application blocked: device integrity check failed.', category: LogCategory.system);
    runApp(const ProviderScope(child: CompromisedDeviceApp()));
    return;
  }



  final container = ProviderContainer(overrides: appProviderOverrides);
  
  // Validate DI wiring in debug mode to prevent UnimplementedError crashes
  assertDIComplete(container);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final branding = ref.watch(currentBrandingProvider);

    return MaterialApp.router(
      title: branding.appNameOverride ?? 'Quiz Arena',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(branding),
      routerConfig: router,
    );
  }
}
