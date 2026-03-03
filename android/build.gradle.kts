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
            
            // Force JVM Target 17 for Java and Kotlin across all plugins
            if (subproject.plugins.hasPlugin("com.android.library") || subproject.plugins.hasPlugin("com.android.application")) {
                val android = subproject.extensions.getByName("android") as com.android.build.gradle.BaseExtension
                android.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
            subproject.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
