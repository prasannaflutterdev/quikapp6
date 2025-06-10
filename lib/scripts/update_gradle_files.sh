#!/usr/bin/env bash

set -e
echo "🚀 Starting modern Gradle file injection..."

# 1. Overwrite android/settings.gradle.kts with the correct Flutter SDK path
echo "📝 Writing modern android/settings.gradle.kts..."
# Note: The 'EOF' is NOT in single quotes, to allow shell variable expansion for $FLUTTER_ROOT
cat <<EOF > android/settings.gradle.kts
pluginManagement {
    // THIS IS THE FIX: Use the $FLUTTER_ROOT environment variable
    // provided by the Codemagic build environment.
    includeBuild("$FLUTTER_ROOT/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

include(":app")
EOF
[[ -f android/settings.gradle.kts ]] && echo "✅ settings.gradle.kts updated."

# 2. Overwrite android/build.gradle.kts (root-level)
echo "📝 Writing modern android/build.gradle.kts..."
cat <<'EOF' > android/build.gradle.kts
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

#rootProject.buildDir = "../build"
#subprojects {
#    project.buildDir = "${rootProject.buildDir}/${project.name}"
#}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
EOF
[[ -f android/build.gradle.kts ]] && echo "✅ build.gradle.kts updated."


# 3. Overwrite android/app/build.gradle.kts (app-level)
echo "📝 Writing modern android/app/build.gradle.kts..."
cat <<'EOF' > android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = System.getenv("PKG_NAME") ?: "com.example.quikapp6"
    compileSdk = 34
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = System.getenv("PKG_NAME") ?: "com.example.quikapp6"
        minSdk = 21
        targetSdk = 34
        // These values will be replaced by your update_version.sh script
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // This references the signing configuration set up by inject_keystore.sh
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {}
EOF
[[ -f android/app/build.gradle.kts ]] && echo "✅ app/build.gradle.kts updated."

echo "🎉 Gradle files successfully updated to modern configuration."
##!/usr/bin/env bash
#
#set -e
#echo "🚀 Starting modern Gradle file injection..."
#
## Set default versions if environment variables are not provided
#export VERSION_NAME="${VERSION_NAME:-1.0.0}"
#export VERSION_CODE="${VERSION_CODE:-$(date +%Y%m%d%H%M)}"
#export PKG_NAME="${PKG_NAME:-com.example.app}"
#export COMPILE_SDK_VERSION="${COMPILE_SDK_VERSION:-34}"
#export MIN_SDK_VERSION="${MIN_SDK_VERSION:-21}"
#export TARGET_SDK_VERSION="${TARGET_SDK_VERSION:-34}"
#
#echo "Using VERSION_NAME: $VERSION_NAME"
#echo "Using VERSION_CODE: $VERSION_CODE"
#echo "Using PKG_NAME: $PKG_NAME"
#
## 1. Overwrite android/settings.gradle.kts
#echo "📝 Writing modern android/settings.gradle.kts..."
#cat <<'EOF' > android/settings.gradle.kts
#pluginManagement {
#    includeBuild("../flutter_sdk/packages/flutter_tools/gradle")
#
#    repositories {
#        google()
#        mavenCentral()
#        gradlePluginPortal()
#    }
#}
#
#plugins {
#    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
#    id("com.android.application") version "8.2.2" apply false
#    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
#}
#
#include(":app")
#EOF
#[[ -f android/settings.gradle.kts ]] && echo "✅ settings.gradle.kts updated."
#
## 2. Overwrite android/build.gradle.kts (root-level)
#echo "📝 Writing modern android/build.gradle.kts..."
#cat <<'EOF' > android/build.gradle.kts
#allprojects {
#    repositories {
#        google()
#        mavenCentral()
#    }
#}
#
#rootProject.buildDir = "../build"
#subprojects {
#    project.buildDir = "${rootProject.buildDir}/${project.name}"
#}
#
#tasks.register<Delete>("clean") {
#    delete(rootProject.buildDir)
#}
#EOF
#[[ -f android/build.gradle.kts ]] && echo "✅ build.gradle.kts updated."
#
#
## 3. Overwrite android/app/build.gradle.kts (app-level)
#echo "📝 Writing final android/app/build.gradle.kts..."
#cat <<EOF > android/app/build.gradle.kts
#plugins {
#    id("com.android.application")
#    id("org.jetbrains.kotlin.android")
#    id("dev.flutter.flutter-gradle-plugin")
#}
#
#android {
#    namespace = System.getenv("PKG_NAME")
#    compileSdk = (System.getenv("COMPILE_SDK_VERSION") ?: "34").toInt()
#    ndkVersion = "25.1.8937393"
#
#    compileOptions {
#        sourceCompatibility = JavaVersion.VERSION_1_8
#        targetCompatibility = JavaVersion.VERSION_1_8
#    }
#
#    kotlinOptions {
#        jvmTarget = "1.8"
#    }
#
#    sourceSets {
#        getByName("main") {
#            java.srcDirs("src/main/kotlin")
#        }
#    }
#
#    defaultConfig {
#        applicationId = System.getenv("PKG_NAME")
#        minSdk = (System.getenv("MIN_SDK_VERSION") ?: "21").toInt()
#        targetSdk = (System.getenv("TARGET_SDK_VERSION") ?: "34").toInt()
#        versionCode = (System.getenv("VERSION_CODE") ?: "1").toInt()
#        versionName = System.getenv("VERSION_NAME")
#    }
#
#    buildTypes {
#        release {
#            signingConfig = signingConfigs.getByName("release")
#        }
#    }
#}
#
#flutter {
#    source = "../.."
#}
#
#dependencies {}
#EOF
#[[ -f android/app/build.gradle.kts ]] && echo "✅ app/build.gradle.kts written with all configurations."
#
#echo "🎉 Gradle files successfully updated."
##echo "📝 Writing modern android/app/build.gradle.kts with dynamic versioning..."
##cat <<'EOF' > android/app/build.gradle.kts
##plugins {
##    id("com.android.application")
##    id("org.jetbrains.kotlin.android")
##    id("dev.flutter.flutter-gradle-plugin")
##}
##
##// ============== START: VERSIONING LOGIC ==============
##// Reads versions from local.properties, which is populated by Flutter
##def localProperties = new Properties()
##def localPropertiesFile = rootProject.file("local.properties")
##if (localPropertiesFile.exists()) {
##    localPropertiesFile.withReader("UTF-8") { reader ->
##        localProperties.load(reader)
##    }
##}
##
##def flutterVersionCode = localProperties.getProperty("flutter.versionCode")
##if (flutterVersionCode == null) {
##    flutterVersionCode = "1"
##}
##
##def flutterVersionName = localProperties.getProperty("flutter.versionName")
##if (flutterVersionName == null) {
##    flutterVersionName = "1.0"
##}
##// ============== END: VERSIONING LOGIC ==============
##
##android {
##    namespace = System.getenv("PKG_NAME") ?: "com.example.quikapp6"
##    compileSdk = 34
##    ndkVersion = "25.1.8937393"
##
##    compileOptions {
##        sourceCompatibility = JavaVersion.VERSION_1_8
##        targetCompatibility = JavaVersion.VERSION_1_8
##    }
##
##    kotlinOptions {
##        jvmTarget = "1.8"
##    }
##
##    sourceSets {
##        getByName("main") {
##            java.srcDirs("src/main/kotlin")
##        }
##    }
##
##    defaultConfig {
##        applicationId = System.getenv("PKG_NAME") ?: "com.example.quikapp6"
##        minSdk = 21
##        targetSdk = 34
##        // Uses the dynamic version values defined above
##        versionCode = flutterVersionCode.toInteger()
##        versionName = flutterVersionName
##    }
##
##    buildTypes {
##        release {
##            signingConfig = signingConfigs.getByName("release")
##        }
##    }
##}
##
##flutter {
##    source = "../.."
##}
##
##dependencies {}
##EOF
##[[ -f android/app/build.gradle.kts ]] && echo "✅ app/build.gradle.kts updated."
##
##echo "🎉 Gradle files successfully updated to modern configuration."