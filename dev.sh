#!/bin/bash

# CKPods Flutter App - Development Script

echo "🎧 CKPods Flutter Podcast App"
echo "=============================="

# Function to check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo "❌ Flutter is not installed or not in PATH"
        echo "Please install Flutter: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    echo "✅ Flutter is installed"
}

# Function to install dependencies
install_deps() {
    echo "📦 Installing dependencies..."
    flutter pub get
    
    echo "🔧 Generating code files..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
}

# Function to run the app
run_app() {
    echo "🚀 Starting the app..."
    flutter run
}

# Function to build for release
build_release() {
    echo "🏗️  Building for release..."
    echo "Choose platform:"
    echo "1) Android APK"
    echo "2) Android App Bundle"
    echo "3) iOS"
    read -p "Enter choice [1-3]: " choice
    
    case $choice in
        1)
            flutter build apk --release
            echo "✅ APK built: build/app/outputs/flutter-apk/app-release.apk"
            ;;
        2)
            flutter build appbundle --release
            echo "✅ App Bundle built: build/app/outputs/bundle/release/app-release.aab"
            ;;
        3)
            flutter build ios --release
            echo "✅ iOS app built"
            ;;
        *)
            echo "❌ Invalid choice"
            ;;
    esac
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
    flutter test
}

# Function to analyze code
analyze_code() {
    echo "🔍 Analyzing code..."
    flutter analyze
}

# Function to format code
format_code() {
    echo "📝 Formatting code..."
    flutter format .
}

# Main menu
show_menu() {
    echo ""
    echo "What would you like to do?"
    echo "1) Install dependencies"
    echo "2) Run app"
    echo "3) Build for release"
    echo "4) Run tests"
    echo "5) Analyze code"
    echo "6) Format code"
    echo "7) Exit"
}

# Main script
main() {
    check_flutter
    
    while true; do
        show_menu
        read -p "Enter choice [1-7]: " choice
        
        case $choice in
            1)
                install_deps
                ;;
            2)
                run_app
                ;;
            3)
                build_release
                ;;
            4)
                run_tests
                ;;
            5)
                analyze_code
                ;;
            6)
                format_code
                ;;
            7)
                echo "👋 Goodbye!"
                exit 0
                ;;
            *)
                echo "❌ Invalid choice. Please enter 1-7."
                ;;
        esac
    done
}

# Run main function
main
