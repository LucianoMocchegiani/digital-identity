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
    project.plugins.withId("com.android.library") {
        val android = project.extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        if (android?.namespace == null) {
            val ns = when (project.name) {
                "isar_flutter_libs" -> "dev.isar.isar_flutter_libs"
                else -> "com.phinx.${project.name.replace("-", "_")}"
            }
            android?.namespace = ns
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
