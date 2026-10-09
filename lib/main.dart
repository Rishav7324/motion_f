import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/project.dart';
import 'bridge/native_engine_bridge.dart';
import 'ui/editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark status & navigation bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0C0D11),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize native C++ NDK Engine FFI
  NativeEngineBridge.init();

  runApp(const MotionFApp());
}

class MotionFApp extends StatelessWidget {
  const MotionFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectModel(),
      child: MaterialApp(
        title: 'MotionF',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0C0D11),
          primaryColor: const Color(0xFF00E5FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            secondary: Color(0xFFD500F9),
            surface: Color(0xFF141519),
          ),
          fontFamily: 'Roboto',
        ),
        home: const EditorScreen(),
      ),
    );
  }
}
