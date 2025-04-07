import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Import your AuthBloc and App widget
import 'app.dart'; // Assuming app.dart holds the main App widget
import './features/auth/bloc/auth_bloc.dart'; // Assuming this path for AuthBloc

Future<void> main() async {
  //Load environment variables
  await dotenv.load(fileName: ".env");
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Replace with your actual Supabase URL and Anon Key
  // It's recommended to use environment variables for these in a real app
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,       // ✅ Use environment variables safely
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

// Helper function to get the Supabase client instance
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the AuthBloc to the entire widget tree
    return BlocProvider(
      create: (context) => AuthBloc(supabase.auth)..add(AuthSubscriptionRequested()), // Start listening to auth changes
      child: const App(), // Your main App widget
    );
  }
}
