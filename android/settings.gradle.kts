pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

@Suppress("UnstableApiUsage")
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
    }
}

// Load Flutter SDK path from local.properties
val localPropertiesFile = file("local.properties")
val properties = java.util.Properties()
localPropertiesFile.inputStream().use { properties.load(it) }
val flutterSdkPath = properties.getProperty("flutter.sdk")
    ?: throw GradleException("flutter.sdk not set in local.properties")

// Include Flutter plugins
apply(from = "${flutterSdkPath}/packages/flutter_tools/gradle/app_plugin_loader.gradle")

rootProject.name = "eduai"
include(":app")
