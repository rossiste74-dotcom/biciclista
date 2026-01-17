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
subprojects {
    project.evaluationDependsOn(":app")

    val subproject = this
    fun configureSdk() {
        if (subproject.plugins.hasPlugin("com.android.library")) {
            val android = subproject.extensions.getByName("android") as com.android.build.gradle.LibraryExtension
            if (android.namespace == null) {
                android.namespace = "dev.isar.${subproject.name.replace("-", "_")}"
            }
            android.compileSdk = 36
        }
    }

    if (subproject.state.executed) {
        configureSdk()
    } else {
        subproject.afterEvaluate {
            configureSdk()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
