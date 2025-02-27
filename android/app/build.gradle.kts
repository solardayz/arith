def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ntb.arith"
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
        applicationId = "com.ntb.arith"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['ntb']
            keyPassword keystoreProperties['ntbmath']
            storeFile keystorePropertiesFile.exists() ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['ntbmath']
        }
    }

    buildTypes {
        release {
            // 기존 debug 키 대신 release 서명 구성 사용
            signingConfig signingConfigs.release
                    minifyEnabled false  // 필요 시 ProGuard 활성화 가능
            shrinkResources false
        }
        debug {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}
