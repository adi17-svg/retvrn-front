    plugins {
        id("com.android.application")
        // START: FlutterFire Configuration
        id("com.google.gms.google-services") 
        // END: FlutterFire Configuration
        id("kotlin-android")
        // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
        id("dev.flutter.flutter-gradle-plugin")
    }

    android {
        namespace = "com.example.retvrn"
        compileSdk = flutter.compileSdkVersion
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
            applicationId = "com.example.retvrn"
            minSdk = 24                          // <-- Updated here from 23 to 24
            targetSdk = flutter.targetSdkVersion
            versionCode = flutter.versionCode
            versionName = flutter.versionName
        }

        buildTypes {
            release {
                // Enable code shrinking and resource shrinking to fix your error
                isMinifyEnabled = true
                isShrinkResources = true

                // You can keep debug signing config for now
                signingConfig = signingConfigs.getByName("debug")

                // Proguard rules files needed when minifyEnabled is true
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
                )
            }
            debug {
                // For debug build, disable shrinking and minifying for faster builds
                isMinifyEnabled = false
                isShrinkResources = false
            }
        }
    }

    flutter {
        source = "../.."
    }
    dependencies {
        // Add the core library desugaring dependency
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    }
