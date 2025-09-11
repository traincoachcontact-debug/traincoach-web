plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Define la versión de la librería de desugaring para reutilizarla
val coreLibraryDesugaringVersion = "2.0.4"

android {
    namespace = "com.example.appgym"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // --- 1. HABILITAR DESUGARING ---
        // Esta línea activa la característica.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.appgym"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// --- 2. AÑADIR LA DEPENDENCIA DE DESUGARING ---
// Este bloque añade la librería necesaria para que el desugaring funcione.
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:$coreLibraryDesugaringVersion")
}
