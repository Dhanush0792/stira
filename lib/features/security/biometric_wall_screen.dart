import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_primary_button.dart';
import '../navigation/main_navigation.dart';

/// Interception screen that requires FaceID / TouchID to proceed
class BiometricWallScreen extends StatefulWidget {
  const BiometricWallScreen({super.key});

  @override
  State<BiometricWallScreen> createState() => _BiometricWallScreenState();
}

class _BiometricWallScreenState extends State<BiometricWallScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    try {
      final canAuthenticate = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) {
        _proceed();
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Access your clinical data securely',
      );

      if (authenticated) {
        _proceed();
      } else {
        setState(() {
          _isAuthenticating = false;
          _error = 'Authentication failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _error = 'Error: $e';
        });
      }
    }
  }

  void _proceed() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StiraTokens.stiraBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                color: StiraTokens.stiraViolet,
                size: 64,
              ),
              const SizedBox(height: 32),
              Text(
                'Stira is Locked',
                style: GoogleFonts.syne(
                  color: StiraTokens.stiraWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unlock to access your clinical journal and insights.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: StiraTokens.stiraMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              if (_isAuthenticating)
                const CircularProgressIndicator(color: StiraTokens.stiraViolet)
              else
                StiraPrimaryButton(
                  label: 'Unlock Stira',
                  color: StiraTokens.stiraViolet,
                  onTap: _authenticate,
                ),
              if (_error != null) ...[
                const SizedBox(height: 24),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: StiraTokens.stiraPink,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
