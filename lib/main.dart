import 'package:dukoavote/src/app/init/supabase_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/dukoavote_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  runApp(
    const ProviderScope(
      child: DukoaVoteApp(),
    ),
  );
}

