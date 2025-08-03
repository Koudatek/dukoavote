import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/core.dart';
import 'src/dukoavote_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  EnvConfig.validate();
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  runApp(
    const ProviderScope(
      child: DukoaVoteApp(),
    ),
  );
}

