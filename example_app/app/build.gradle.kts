import java.util.Properties

// Load the local.properties file
val localPropertiesFile = rootProject.file("local.properties")
println("Path to local.properties: ${localPropertiesFile.absolutePath}")
val localProps = Properties()
localPropertiesFile.inputStream().use { localProps.load(it) }

val my_boost_dir = localProps.getProperty("boost.dir")
val my_boost_dir_libs = "$my_boost_dir/libs"
val my_boost_dir_inc = "$my_boost_dir/include"

println("boost.dir: $my_boost_dir")
println("my_boost_dir_libs: $my_boost_dir_libs")
println("my_boost_dir_inc: $my_boost_dir_inc")

//----------


plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.example.boost_test"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.boost_test"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        externalNativeBuild {
            cmake {
                // flags for the c++ compiler eg "-std=c++14 -frtti -fexceptions"
                // If you set cppFlags to "-std=c++14", you may need to build your boost libraries
                // with the same flags, depending on your compiler defaults.
                // cppFlags "-std=c++14"

                // This causes libc++_shared.so to get packaged into the APK
                arguments += "-DANDROID_STL=c++_shared"

                // This is used in CMakeLists.txt so our native code can find/use (prebuilt) boost
                arguments += "-DMY_BOOST_LIBS_DIR=${my_boost_dir_libs}"
                arguments += "-DMY_BOOST_INC_DIR=${my_boost_dir_inc}"

            }
        }

        ndk {
            // Specifies the ABI configurations of your native
            // libraries Gradle should build and package with your APK.
            // need to also have ~ boost binaries built for each abi specified here
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }
    buildFeatures {
        viewBinding = true
    }
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}

