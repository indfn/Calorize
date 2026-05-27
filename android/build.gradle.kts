allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 🔴 THE FIX: Force all plugins to use SDK 36
subprojects {
    afterEvaluate {
        // Check if the subproject is an Android Module (Library or App)
        if (project.extensions.findByName("android") != null) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                // Force the compile version to 36 to support Android 16 resources
                compileSdkVersion(36)
                
                defaultConfig {
                    // Force minimums to support Health Connect
                    minSdk = 26
                    targetSdk = 36
                }
            }
        }
// Keep your Isar Specific Fix (Namespace)
        if (project.name == "isar_flutter_libs") {
             project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }


    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}