// 📄 android/app/build.gradle.kts

import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// — Load Flutter-related properties —
val localProperties = Properties().apply {
    rootProject.file("local.properties")
        .takeIf { it.exists() }
        ?.reader(Charsets.UTF_8)
        ?.use { load(it) }
}

val flutterRoot: String = localProperties.getProperty("flutter.sdk")
    ?: throw GradleException("Flutter SDK not found. Define flutter.sdk in local.properties")

val flutterVersionCode: Int = localProperties
    .getProperty("flutter.versionCode")?.toIntOrNull() ?: 1

val flutterVersionName: String = localProperties
    .getProperty("flutter.versionName") ?: "1.0"

// — Load keystore for signing —
val keystoreProperties = Properties().apply {
    rootProject.file("key.properties")
        .takeIf { it.exists() }
        ?.let { file -> load(FileInputStream(file)) }
}

android {
    namespace   = "com.example.shuruhat_new"
    compileSdk  = flutter.compileSdkVersion
    ndkVersion  = "27.0.12077973"  // lock NDK 27

    defaultConfig {
        applicationId     = "com.shuruhat"
        minSdk            = flutter.minSdkVersion
        targetSdk         = flutter.targetSdkVersion
        versionCode       = flutterVersionCode
        versionName       = flutterVersionName
        multiDexEnabled   = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias       = keystoreProperties.getProperty("keyAlias")
            keyPassword    = keystoreProperties.getProperty("keyPassword")
            storeFile      = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword  = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig   = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

// — إجبار جميع الاعتمادات على نسخة Google Play Billing Library 8.0.0 —
configurations.all {
    resolutionStrategy {
        eachDependency {
            if (requested.group == "com.android.billingclient"
                && requested.name == "billing"
            ) {
                useVersion("8.0.0")
                because("ضمان توافق مكتبة الفوترة مع متطلبات Google Play ≥ 7.0.0")
            }
        }
    }
}
