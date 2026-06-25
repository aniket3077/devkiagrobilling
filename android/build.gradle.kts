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
}

subprojects {
    fun forceCompileSdk(proj: Project) {
        proj.plugins.withId("com.android.library") {
            val android = proj.extensions.findByName("android")
            if (android != null) {
                try {
                    val compileSdkVersionMethod = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    compileSdkVersionMethod.invoke(android, 36)
                } catch (e: Exception) {
                    try {
                        val compileSdkVersionMethod = android.javaClass.getMethod("compileSdkVersion", String::class.java)
                        compileSdkVersionMethod.invoke(android, "android-36")
                    } catch (e2: Exception) {
                        println("Failed to force compileSdkVersion for ${proj.name}: ${e2.message}")
                    }
                }
            }
        }
    }

    if (state.executed) {
        forceCompileSdk(this)
    } else {
        afterEvaluate {
            forceCompileSdk(this)
        }
    }
    plugins.withId("com.android.library") {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespace.invoke(android) as? String
                if (currentNamespace.isNullOrEmpty()) {
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val parser = javax.xml.parsers.DocumentBuilderFactory.newInstance().newDocumentBuilder()
                        val doc = parser.parse(manifestFile)
                        val packageName = doc.documentElement.getAttribute("package")
                        if (!packageName.isNullOrEmpty()) {
                            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                            setNamespace.invoke(android, packageName)
                        }
                    }
                }
            } catch (e: Exception) {
                println("Failed to set namespace for ${project.name}: ${e.message}")
            }
        }
    }
    plugins.withId("com.android.application") {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespace.invoke(android) as? String
                if (currentNamespace.isNullOrEmpty()) {
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val parser = javax.xml.parsers.DocumentBuilderFactory.newInstance().newDocumentBuilder()
                        val doc = parser.parse(manifestFile)
                        val packageName = doc.documentElement.getAttribute("package")
                        if (!packageName.isNullOrEmpty()) {
                            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                            setNamespace.invoke(android, packageName)
                        }
                    }
                }
            } catch (e: Exception) {
                println("Failed to set namespace for ${project.name}: ${e.message}")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
