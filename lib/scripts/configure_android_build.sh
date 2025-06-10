#!/usr/bin/env bash

set -euo pipefail
echo "噫 Configuring a complete and modern Android build..."

# Set default values
export PKG_NAME="${PKG_NAME:-com.example.app}"
export COMPILE_SDK_VERSION="${COMPILE_SDK_VERSION:-35}"
export MIN_SDK_VERSION="${MIN_SDK_VERSION:-21}"
export TARGET_SDK_VERSION="${TARGET_SDK_VERSION:-34}"

# --- Debugging to verify file locations ---
echo "-------------------------------------------------"
echo "🔍 Listing contents of the project root and /android/ directory..."
echo "--- Project Root ---"
ls -l
echo "--- Android Directory ---"
ls -l android/
echo "-------------------------------------------------"

# --- Common Gradle Configuration ---
echo "統 Writing root Gradle files..."
cat <<EOF > android/settings.gradle.kts
pluginManagement {
    includeBuild("$FLUTTER_ROOT/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}
include(":app")
EOF


cat <<'EOF' > android/build.gradle.kts
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
EOF

# --- Conditionally Generate app/build.gradle.kts ---
if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
  echo "✅ PUSH_NOTIFY is true. Generating build.gradle.kts WITH Firebase."
  cat <<EOF > android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = System.getenv("PKG_NAME")
    compileSdk = (System.getenv("COMPILE_SDK_VERSION") ?: "35").toInt()

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = System.getenv("PKG_NAME")
        minSdk = (System.getenv("MIN_SDK_VERSION") ?: "21").toInt()
        targetSdk = (System.getenv("TARGET_SDK_VERSION") ?: "35").toInt()
        versionCode = (System.getenv("VERSION_CODE") ?: "1").toInt()
        versionName = System.getenv("VERSION_NAME") ?: "1.0"
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release") // Correctly uses the release signing config
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
EOF
else
  # This block is for when PUSH_NOTIFY is false
  echo "🚫 PUSH_NOTIFY is false. Generating build.gradle.kts WITHOUT Firebase."
  cat <<EOF > android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = System.getenv("PKG_NAME")
    compileSdk = (System.getenv("COMPILE_SDK_VERSION") ?: "35").toInt()

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = System.getenv("PKG_NAME")
        minSdk = (System.getenv("MIN_SDK_VERSION") ?: "21").toInt()
        targetSdk = (System.getenv("TARGET_SDK_VERSION") ?: "35").toInt()
        versionCode = (System.getenv("VERSION_CODE") ?: "1").toInt()
        versionName = System.getenv("VERSION_NAME") ?: "1.0"
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            } else {
                println("Warning: key.properties file not found at " + keystorePropertiesFile.absolutePath)
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
EOF
fi

echo "脂 All Android Gradle files configured successfully."