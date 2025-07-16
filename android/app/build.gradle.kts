// 📌 1. Imports and loading key.properties
import java.util.Properties
import java.io.FileInputStream

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

// Below keyProperties block
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}
val MAPS_API_KEY = localProperties["MAPS_API_KEY"] as? String ?: ""







// 📌 2. Plugins block
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// 📌 3. Android config
android {
    namespace = "com.anasnasr.cairocrew"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.anasnasr.cairocrew"
        minSdk = 23
        targetSdk = 35
        versionCode = 5
        versionName = "1.0.4"
        manifestPlaceholders["MAPS_API_KEY"] = MAPS_API_KEY
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

// 📌 4. Flutter binding
flutter {
    source = "../.."
}
dependencies {
    // ✅ Add this:
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
