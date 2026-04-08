import 'package:debator/app/pages/app_splash_page.dart';
import 'package:debator/app/providers/app_providers.dart';
import 'package:debator/features/account/account_page.dart';
import 'package:debator/features/auth/auth.dart';
import 'package:debator/features/home/debator_home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final config = ref.watch(appConfigProvider);
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            AppSplashPage(environment: config.environment),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            return DebatorWelcomePage(
              isDemoMode: config.isMock,
              onPrimaryAction: () {
                context.go(config.isMock ? '/app' : '/auth');
              },
              onSecondaryAction: config.isMock
                  ? () => context.go('/app')
                  : () => context.go('/auth'),
            );
          },
        ),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const _AuthRoutePage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const _OnboardingRoutePage(),
      ),
      GoRoute(
        path: '/app',
        builder: (context, state) => const DebatorHomeShell(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const DebatorAccountPage(),
      ),
      GoRoute(
        path: '/debate/:debateId',
        builder: (context, state) {
          return DebateDetailPage(
            debateId: state.pathParameters['debateId']!,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isWelcome = location == '/welcome';
      final isAuth = location == '/auth';
      final isOnboarding = location == '/onboarding';
      final isAppSurface =
          location == '/app' ||
          location == '/account' ||
          location.startsWith('/debate/');

      if (config.isMock) {
        if (isSplash || isAuth || isOnboarding) {
          return '/welcome';
        }
        return null;
      }

      if (authState.isLoading) {
        return isSplash ? null : '/splash';
      }

      if (authState.hasError) {
        return isAuth ? null : '/auth';
      }

      final user = authState.asData?.value;
      if (user == null) {
        if (isSplash) {
          return '/welcome';
        }
        return isWelcome || isAuth ? null : '/welcome';
      }

      if (!_isOnboardingComplete(user)) {
        return isOnboarding ? null : '/onboarding';
      }

      if (isSplash || isWelcome || isAuth || isOnboarding) {
        return '/app';
      }

      return isAppSurface ? null : '/app';
    },
  );
});

bool _isOnboardingComplete(User user) {
  final metadata = user.userMetadata;
  return metadata?['onboarding_completed'] == true;
}

class _AuthRoutePage extends ConsumerStatefulWidget {
  const _AuthRoutePage();

  @override
  ConsumerState<_AuthRoutePage> createState() => _AuthRoutePageState();
}

class _AuthRoutePageState extends ConsumerState<_AuthRoutePage> {
  bool _isSubmitting = false;
  String? _helperMessage;

  @override
  Widget build(BuildContext context) {
    return DebatorAuthPage(
      isSubmitting: _isSubmitting,
      helperMessage: _helperMessage,
      onBack: () => context.go('/welcome'),
      onSendMagicLink: (email) async {
        setState(() {
          _isSubmitting = true;
          _helperMessage = null;
        });

        try {
          await ref.read(sessionControllerProvider).sendMagicLink(email);
          if (!mounted) {
            return;
          }
          setState(() {
            _helperMessage =
                'Check $email for your Debator sign-in link. '
                'Once the session opens, we will continue into profile setup.';
          });
        } catch (error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _helperMessage = 'We could not send the sign-in link. $error';
          });
        } finally {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
        }
      },
    );
  }
}

class _OnboardingRoutePage extends ConsumerStatefulWidget {
  const _OnboardingRoutePage();

  @override
  ConsumerState<_OnboardingRoutePage> createState() =>
      _OnboardingRoutePageState();
}

class _OnboardingRoutePageState extends ConsumerState<_OnboardingRoutePage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).asData?.value;
    final viewerProfile = ref.watch(viewerProfileProvider).asData?.value;

    return Stack(
      children: [
        DebatorOnboardingPage(
          email: user?.email ?? 'your@email.com',
          initialDisplayName:
              viewerProfile?.displayName ?? _defaultDisplayName(user),
          initialHandle: viewerProfile?.handle ?? _defaultHandle(user),
          onSignOut: () async {
            await ref.read(sessionControllerProvider).signOut();
            if (!context.mounted) {
              return;
            }
            context.go('/welcome');
          },
          onComplete: ({
            required String displayName,
            required String handle,
          }) async {
            setState(() {
              _isSubmitting = true;
            });
            try {
              await ref.read(sessionControllerProvider).completeOnboarding(
                    displayName: displayName,
                    handle: handle,
                  );
            } catch (error) {
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('We could not save your profile yet. $error'),
                ),
              );
            } finally {
              if (mounted) {
                setState(() {
                  _isSubmitting = false;
                });
              }
            }
          },
        ),
        if (_isSubmitting)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.12),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  String? _defaultDisplayName(User? user) {
    if (user == null) {
      return null;
    }
    final metadataName = user.userMetadata?['display_name'] as String?;
    if (metadataName != null && metadataName.trim().isNotEmpty) {
      return metadataName;
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      return null;
    }
    return email.split('@').first;
  }

  String? _defaultHandle(User? user) {
    if (user == null) {
      return null;
    }
    final metadataHandle = user.userMetadata?['preferred_username'] as String?;
    if (metadataHandle != null && metadataHandle.trim().isNotEmpty) {
      return metadataHandle;
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      return null;
    }
    return email.split('@').first;
  }
}
