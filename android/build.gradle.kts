allprojects {
    repositories {
        google()
        mavenCentral()
    }
    project.extensions.extraProperties.set("compileSdkVersion", 36)
    project.extensions.extraProperties.set("targetSdkVersion", 36)
    
    configurations.all {
        resolutionStrategy {
            force("androidx.glance:glance:1.1.0")
            force("androidx.glance:glance-appwidget:1.1.0")
        }
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

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    project.plugins.withId("com.android.library") {
        project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            compileSdk = 36
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
