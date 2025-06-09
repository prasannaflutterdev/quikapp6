#!/usr/bin/env bash

set -euo pipefail
echo "噫 Configuring a complete and modern Android build..."

# Set default values if environment variables are not provided
export PKG_NAME="${PKG_NAME:-com.example.app}"
export COMPILE_SDK_VERSION="${COMPILE_SDK_VERSION:-34}"
export MIN_SDK_VERSION="${MIN_SDK_VERSION:-21}"
export TARGET_SDK_VERSION="${TARGET_SDK_VERSION:-34}"

echo "Using PKG_NAME: $PKG_NAME"
echo "Using MIN_SDK_VERSION: $MIN_SDK_VERSION"
echo "Using TARGET_SDK_VERSION: $TARGET_SDK_VERSION"

# 1. Overwrite android/settings.gradle.kts
echo "統 Writing android/settings.gradle.kts..."
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

# 2. Overwrite android/build.gradle.kts
echo "統 Writing android/build.gradle.kts..."
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

# 3. Overwrite android/app/build.gradle.kts
echo "統 Writing final android/app/build.gradle.kts..."
cat <<EOF > android/app/build.gradle.kts
import java.util.Properties // <-- ADDED THIS LINE
import java.io.File          // <-- ADDED THIS LINE FOR BEST PRACTICE

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = System.getenv("PKG_NAME")
    compileSdk = (System.getenv("COMPILE_SDK_VERSION") ?: "34").toInt()

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = System.getenv("PKG_NAME")
        minSdk = (System.getenv("MIN_SDK_VERSION") ?: "21").toInt()
        targetSdk = (System.getenv("TARGET_SDK_VERSION") ?: "34").toInt()
        versionCode = (System.getenv("VERSION_CODE") ?: "1").toInt()
        versionName = System.getenv("VERSION_NAME") ?: "1.0"
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("android/key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(keystorePropertiesFile.reader())
                storeFile = rootProject.file("android/" + keystoreProperties["storeFile"])
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
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
EOF

echo "脂 All Android Gradle files configured successfully."
##!/usr/bin/env bash
#
#set -euo pipefail
#echo "噫 Configuring a complete and modern Android build..."
#
## Set default values if environment variables are not provided
#export PKG_NAME="${PKG_NAME:-com.example.app}"
#export COMPILE_SDK_VERSION="${COMPILE_SDK_VERSION:-34}"
#export MIN_SDK_VERSION="${MIN_SDK_VERSION:-21}"
#export TARGET_SDK_VERSION="${TARGET_SDK_VERSION:-34}"
#
#echo "Using PKG_NAME: $PKG_NAME"
#echo "Using MIN_SDK_VERSION: $MIN_SDK_VERSION"
#echo "Using TARGET_SDK_VERSION: $TARGET_SDK_VERSION"
#
## 1. Overwrite android/settings.gradle.kts
#echo "統 Writing android/settings.gradle.kts..."
#cat <<EOF > android/settings.gradle.kts
#pluginManagement {
#    includeBuild("$FLUTTER_ROOT/packages/flutter_tools/gradle")
#    repositories {
#        google()
#        mavenCentral()
#        gradlePluginPortal()
#    }
#}
#plugins {
#    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
#    id("com.android.application") version "8.3.0" apply false
#    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
#    id("com.google.gms.google-services") version "4.4.2" apply false
#}
#include(":app")
#EOF
#
## 2. Overwrite android/build.gradle.kts
#echo "統 Writing android/build.gradle.kts..."
#cat <<'EOF' > android/build.gradle.kts
#allprojects {
#    repositories {
#        google()
#        mavenCentral()
#    }
#}
#tasks.register<Delete>("clean") {
#    delete(rootProject.buildDir)
#}
#EOF
#
## 3. Overwrite android/app/build.gradle.kts
#echo "統 Writing final android/app/build.gradle.kts..."
#cat <<EOF > android/app/build.gradle.kts
#plugins {
#    id("com.android.application")
#    id("org.jetbrains.kotlin.android")
#    id("dev.flutter.flutter-gradle-plugin")
#    id("com.google.gms.google-services")
#}
#
#android {
#    namespace = System.getenv("PKG_NAME")
#    compileSdk = (System.getenv("COMPILE_SDK_VERSION") ?: "34").toInt()
#
#    compileOptions {
#        sourceCompatibility = JavaVersion.VERSION_11 // <-- CHANGED
#        targetCompatibility = JavaVersion.VERSION_11 // <-- CHANGED
#    }
#
#    kotlinOptions {
#        jvmTarget = "11" // <-- CHANGED
#    }
#
#    defaultConfig {
#        applicationId = System.getenv("PKG_NAME")
#        minSdk = (System.getenv("MIN_SDK_VERSION") ?: "21").toInt()
#        targetSdk = (System.getenv("TARGET_SDK_VERSION") ?: "34").toInt()
#        versionCode = (System.getenv("VERSION_CODE") ?: "1").toInt()
#        versionName = System.getenv("VERSION_NAME") ?: "1.0"
#    }
#
#    signingConfigs {
#        create("release") {
#            val keystorePropertiesFile = rootProject.file("android/key.properties")
#            if (keystorePropertiesFile.exists()) {
#                val keystoreProperties = java.util.Properties()
#                keystoreProperties.load(keystorePropertiesFile.reader())
#                storeFile = rootProject.file("android/" + keystoreProperties["storeFile"])
#                storePassword = keystoreProperties["storePassword"] as String
#                keyAlias = keystoreProperties["keyAlias"] as String
#                keyPassword = keystoreProperties["keyPassword"] as String
#            }
#        }
#    }
#
#    buildTypes {
#        release {
#            isMinifyEnabled = true
#            isShrinkResources = true
#            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
#            signingConfig = signingConfigs.getByName("release")
#        }
#    }
#}
#
#flutter {
#    source = "../.."
#}
#EOF
#
#echo "脂 All Android Gradle files configured successfully."