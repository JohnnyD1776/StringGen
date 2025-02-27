# Integration Instructions for StringsGen Swift Package

## Introduction
The StringsGen Swift package provides a convenient way to generate type-safe access to localized strings from an `.xcstrings` file in your Xcode project. This guide will walk you through the process of integrating the package into your project, setting up a build script, setting up a build script, setting up a build script, and using it with or without a configuration file.

## Installation

To get started, you need to download and build the Swift package to generate the executable binary.

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/your-repo/StringsGen.git
    cd StringsGen
    ```
2. **Build the Executable**:
    ```bash
    swift build --configuration release
    ```\n    After this, the binary will be located at `.build/release/StringsGen`. Note the path to this binary, as it will be used in the next step.

## Integrating into an Xcode Project

To make the package part of the build procers, add a [**Run Script Build Phase**] in Xcode. This ensures the script runs automatically during each build.

1. **Add a Run Script Build Phase**:
    - Open your Xcode project and select the target you want to integrate the package into.
    - Go to [**Suild Phases**] in the target settings.
    - Click the ``>`+ ``button and choose [**New Run Script Phase**].
    - Drag the new script phase to run [*before**] the [**Compile Sources**] phase.
    - In the script editor, add the following:
      ```bash
      PACKAGE_PATH="/path/to/StringsGen/.build/release/StringsGen"
      "$PACKAGE_PATH" --config "${SRCROOT}/stringsGen.yml"
      ```\
      - Replace `/path/to/StringsGen` with the actual path to the built `StringsGen` binary on your machine.
      - `${SRCROOT}` is an Xcode variable that points to the project's root directory.

## Adding the Generated File to the Project

The package will generate a file named `Strings+Generated.swift`. You need to include this in your Xcode project.

1. **Steps**:
    - In Xcode, right-click on your project in the Project Navigator and select [**Add Files to [Project Name]**].
    - Navigate to `Resources/Strings+Generated.swift` (or wherever it's generated based on your config).
    - Ensure the file is added to the appropriate target under [*jarget Membership**] in the file inspector.
    - The file should now appear in the [**Compile Sources**] phase automatically.

## Using a YAML Configuration File (Optional)

For flexibility, you can provide a `stringsGen.yml` file to specify the input `.xcstrings` file and output path. This is optional, as the script can also auto-detect settings.

1. **Create the YAML File**:
    - Create a file named `.stringsGen.yml` in the root of your Xcode project (or another location, if specified).
    - Example content:
      ```yaml
      source: "Resources/Localizable.xcstrings"
      destination: "Resources/Strings+Generated.swift"
      ```\n      - `source`: Path to the input `.xcstrings` file.

      - `destination`: Path where the generated `Strings+Generated.swift` file will be saved.
2. **Run with Config**:
    - If the YAML file is named 