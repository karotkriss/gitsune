plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dev.gitsune.gitsune"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.gitsune.gitsune"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // F-Droid's inclusion policy forbids proprietary tracking or push services (notably
    // Firebase Cloud Messaging) in the build it distributes (docs/decisions/0004-app-store-launch-scope.md).
    // The `fdroid` flavor is that FOSS-only build; any future proprietary push dependency
    // (E12.x) must be added only via `playImplementation`/`playCompileOnly` below, never to
    // `implementation`/`api`, so it never reaches the fdroid flavor's dependency tree.
    flavorDimensions += "distribution"
    productFlavors {
        create("fdroid") {
            dimension = "distribution"
        }
        create("play") {
            dimension = "distribution"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // Proprietary push (e.g. Firebase Cloud Messaging, added under E12.x) is scoped to the
    // `play` flavor only, e.g.: playImplementation("com.google.firebase:firebase-messaging:...")
}

flutter {
    source = "../.."
}
