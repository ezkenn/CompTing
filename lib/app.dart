import 'package:compting/core/router/app_router.dart';
import 'package:compting/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompTingApp extends ConsumerWidget {
  const CompTingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CompTing — Company Accounting',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
