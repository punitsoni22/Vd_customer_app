import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Load local.properties so we can read GOOGLE_MAPS_API_KEY defined there
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

fun readDotEnvValue(file: File, key: String): String? {
    if (!file.exists()) return null
    val prefix = "$key="
    for (rawLine in file.readLines()) {
        val line = rawLine.trim()
        if (line.isEmpty() || line.startsWith("#")) continue
        if (!line.startsWith(prefix)) continue
        val value = line.removePrefix(prefix).trim()
        return value.trim().trim('"').trim('\'')
    }
    return null
}

android {
    namespace = "com.veedasip.customer_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.veedasip.customer_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val dotEnvApiKey = readDotEnvValue(rootProject.file("../.env"), "GOOGLE_MAPS_API_KEY")
        val localApiKey = localProperties.getProperty("GOOGLE_MAPS_API_KEY")?.trim().orEmpty()
        val projectApiKey = (project.findProperty("GOOGLE_MAPS_API_KEY") as String?)?.trim().orEmpty()
        val envApiKey = (System.getenv("GOOGLE_MAPS_API_KEY") ?: "").trim()
        val googleMapsApiKey = listOf(localApiKey, projectApiKey, envApiKey, dotEnvApiKey ?: "")
            .firstOrNull { it.isNotBlank() }
            ?: ""

        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
    }

    signingConfigs {
        create("release") {
            keyAlias = (keystoreProperties["keyAlias"] as String?) ?: ""
            keyPassword = (keystoreProperties["keyPassword"] as String?) ?: ""
            storeFile = (keystoreProperties["storeFile"] as String?)
                ?.let { file(it) }
            storePassword = (keystoreProperties["storePassword"] as String?) ?: ""
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
