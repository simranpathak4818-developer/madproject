buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Aligned with modern Flutter/Firebase requirements
        classpath("com.android.tools.build:gradle:8.6.0")
        classpath("com.google.gms:google-services:4.4.1")
        // ADD THIS LINE
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Flutter's custom build directory setup
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // Crucial for Flutter projects to link the app module correctly
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}