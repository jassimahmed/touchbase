# Architecture

For firebase, as it is platform specific, use it seperately. 

MyApp/
 ┣ 📂 shared/               ← Kotlin Multiplatform module
 ┃ ┣ 📂 src/commonMain/     ← shared code (runs everywhere)
 ┃ ┣ 📂 src/androidMain/    ← Android-specific code (if needed)
 ┃ ┗ 📂 src/iosMain/        ← iOS-specific code (if needed)
 ┣ 📂 androidApp/           ← Jetpack Compose UI (Kotlin)
 ┗ 📂 iosApp/               ← SwiftUI UI (Swift)

# Notes on Swift

A view is anything that is shown on the screen. 
