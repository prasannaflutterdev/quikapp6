#!/usr/bin/env bash

set -e
echo "🛠️ Writing Gradle configuration files..."

# 🧾 Write android/app/build.gradle.kts
echo "🧾 Writing android/app/build.gradle.kts..."
cat <<'EOF' > android/app/build.gradle.kts
import java.util.Properties

plugins {
    id("com.android.application")
    kotlin("android")
}

val keystorePropertiesFile = File(rootProject.projectDir, "android/key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
    println("✅ key.properties loaded for signing.")
} else {
    println("⚠️ key.properties not found — skipping signing.")
}

android {
    namespace = "${System.getenv("PKG_NAME") ?: "com.example.app"}"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "${System.getenv("PKG_NAME") ?: "com.example.app"}"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        maybeCreate("release").apply {
            if (keystorePropertiesFile.exists()) {
                storeFile = File(rootProject.projectDir, "android/keystore.jks")
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            isDebuggable = true
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
EOF
[[ -f android/app/build.gradle.kts ]] && echo "✅ app/build.gradle.kts written"

# 🧾 Write android/build.gradle.kts (project-level)
echo "📁 Writing android/build.gradle.kts..."
cat <<'EOF' > android/build.gradle.kts
// The buildscript block is for older Gradle versions and can be simplified
// for modern plugin management. The dependencies here are for the Android
// and Kotlin plugins.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

// THIS CONFLICTING PLUGINS BLOCK HAS BEEN REMOVED
// plugins {
//     id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
// }

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF
[[ -f android/build.gradle.kts ]] && echo "✅ build.gradle.kts written at android/"

echo "🚀 Gradle configuration completed."