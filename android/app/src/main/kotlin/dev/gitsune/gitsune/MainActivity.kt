package dev.gitsune.gitsune

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) because local_auth's
// BiometricPrompt requires a FragmentActivity host.
class MainActivity : FlutterFragmentActivity()
