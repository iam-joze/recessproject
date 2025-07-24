// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript { // <--- ADDED: This block is for defining build script dependencies
    repositories {
        google()
        mavenCentral()
    }
    dependencies { // <--- ADDED: This dependencies block is specifically for the buildscript
        classpath("com.android.tools.build:gradle:8.1.2") // Your Android Gradle Plugin version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20") // Your Kotlin version
        classpath("com.google.gms:google-services:4.4.2") // Google Services plugin
    }
}

allprojects { // <--- EXISTING: This block is for defining repositories for all projects
    repositories {
        google()
        mavenCentral()
    }
    // REMOVED: The incorrect 'dependencies' block from here
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}