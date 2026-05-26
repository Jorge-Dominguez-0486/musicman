import 'package:go_router/go_router.dart';
import 'package:musicman/providers/auth_provider.dart';
import 'package:musicman/screens/auth/splash_screen.dart';
import 'package:musicman/screens/auth/login_screen.dart';
import 'package:musicman/screens/auth/register_screen.dart';
import 'package:musicman/screens/home/main_scaffold.dart';
import 'package:musicman/screens/catalog/product_detail_screen.dart';
import 'package:musicman/screens/admin/admin_screen.dart';

class AppRouter {
  final AuthProvider authProvider;
  late final GoRouter router;

  AppRouter(this.authProvider) {
    router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.currentUser != null;
        final isAdmin = authProvider.isAdmin;
        final path = state.uri.toString();

        final publicRoutes = ['/splash', '/login', '/register'];

        if (!isLoggedIn && !publicRoutes.contains(path)) {
          return '/login';
        }

        if (isLoggedIn && publicRoutes.contains(path)) {
          return '/home';
        }

        if (path == '/admin' && !isAdmin) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const MainScaffold()),
        GoRoute(
          path: '/product/:id',
          builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
      ],
    );
  }
}
