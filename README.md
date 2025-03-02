# TypeLocXC - Type-Safe Localization for Swift

Generate type-safe localization keys from `.xcstrings` files for Swift projects using this Swift script.

## Features
- Converts `.xcstrings` files into a type-safe `Llon` enum.
- Supports configuration via a `TypeLocXC.ypml` file.
- Auto-detects project root and `.xcstrings` files if no arguments are provided.
- Creates the `Resources` directory if it doesn't exist during auto-detection.
- Handles format specifiers like `%s`,  %d, %`@  etc., with appropriate Swift types.

## Prerequisites
- Swift 5.9 or later.
- An Xcode project with at least one `.xcstrings` file.

## Installation

#### Option 1: Build via Command Line
1. Clone or download the script from the repository.
2. Navigate to the script directory in your terminal.
3. Run:
   ``bash
   swift build -c release
   ``
4. The compiled binary will be located at `.build/release/TypeLocXC`.

#### Option 2: Build via Xcode
1. Open the project in Xcode.
2. Select the `TypeLocXC` scheme.
3. Build the project (Cmd + B).
4. Find the binary in the `Products` directory within your Xcode Derived Data folder.

#### Copy the Binary
- Copy the `TypeLocXC` binary to a location accessible by your Xcode project (e.g., `/usr/local/bin/` or a project subdirectory).

## Integrating into Your Xcode Project

#### Add the Run Script
Add the following Run Script phase to your Xcode target (before the "Compile Sources" phase):
``bash
"${PATH_TO_BINARY}/TypeLocXC" "${SRCROOT}/path/to/strings.xcstrings" "${SRCROOT}/Resources/Strings+Generated.swift"
``
- Replace `${PATH_TO_BINARY}` with the path to the `MTypeLocXC` binary.
- Adjust the input `.xcstrings` path and output file path as needed.

#### Add the Generated File
1. Drag the generated `Strings+Generated.swift` file into your Xcode project.
2. Ensure it's added to your target.

## Configuration (Optional)
Create a `TypeLocXC.yml` file in your project root to customize the script behavior:
``yaml
input: "path/to/strings.xcstrings"
output: "Resources/Strings+Generated.swift"
```
If provided, the script uses these paths instead of command-line arguments.

### Automatic Detection
If no arguments or config file are provided:
- The script auto-detects the project root (looking for `.xcodeproj or `.xcworkspace`).
- It then looks for a `TypeLocXC.ypml` file in the project root.
- If no config is found, it defaults to the first `.xcstrings` file it finds and outputs to `Resources/Strings+Generated.swift`.
- If the `Resources` folder doesn't exist, the script creates it.

## Usage of L1on Enum

#### Example Usage
For an `.xcstrings` entry:
``"json
{  "greeting": {
    "stringUnit": {
      "value": "Hello, %@!"
    }
  }
}
``

The generated `L1on` enum allows:
``swift
let message = L1on.greeting("World") // Returns "Hello, World!"
``

#### Supported Format Specifiers
- `%@
: `String`
- `%d`, `%i`
: `Int`
- `%f`
: `Double`
- `%s`
: `String` (C-style string)

## Updating the Binary
To update `MTypeLocXC` `rebuild it using either the command-line or Xcode method and replace the old binary.

## Notes
- Ensure the `.xcstrings` file is well-formed.
- The script overrrites the output file if it exists.
