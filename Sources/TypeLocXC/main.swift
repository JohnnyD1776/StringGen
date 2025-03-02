import Foundation
import Yams

let args = CommandLine.arguments
var xcstringsPath: String
var outputFilePath: String

if args.count == 1 { // No arguments beyond the executable name
  guard let projectRoot = findProjectRoot(from: FileManager.default.currentDirectoryPath) else {
    fatalError("Error: No Xcode project found in current directory or parents.")
  }
  let configPath = "\(projectRoot)/TypeLocXC.yml"
  if FileManager.default.fileExists(atPath: configPath) {
    // Load and parse TypeLocXC.yml
    do {
      let configData = try String(contentsOfFile: configPath)
      guard let config = try Yams.load(yaml: configData) as? [String: String],
            let source = config["source"],
            let destination = config["destination"] else {
        fatalError("Error: Invalid format in '\(configPath)'. Expected 'source' and 'destination' keys.")
      }
      xcstringsPath = source
      outputFilePath = destination
    } catch {
      fatalError("Error reading config file '\(configPath)': \(error)")
    }
  } else {
    // Auto-detect .xcstrings file
    guard let xcstringsFile = findFirstXcstringsFile(in: projectRoot) else {
      fatalError("Error: No .xcstrings file found and no config provided.")
    }
    xcstringsPath = xcstringsFile
    outputFilePath = "\(projectRoot)/Resources/Strings+Generated.swift"
    // Ensure Resources directory exists
    let resourcesDir = "\(projectRoot)/Resources"
    if !FileManager.default.fileExists(atPath: resourcesDir) {
      try FileManager.default.createDirectory(atPath: resourcesDir, withIntermediateDirectories: true)
    }
  }
} else if args.count >= 3 && !args.contains("--config") {
  // Explicit paths provided
  xcstringsPath = args[1]
  outputFilePath = args[2]
} else {
  // Look for a config file
  var configPath: String
  if let configIndex = args.firstIndex(of: "--config"), configIndex + 1 < args.count {
    configPath = args[configIndex + 1]
  } else {
    configPath = "TypeLocXC.yml"
  }

  // Verify the config file exists
  guard FileManager.default.fileExists(atPath: configPath) else {
    print("Error: No parameters provided and config file '\(configPath)' not found.")
    print("Usage: TypeLocXC <xcstringsPath> <outputFilePath>")
    print("   or: TypeLocXC --config <configFile.yml>")
    exit(1)
  }

  do {
    let configData = try String(contentsOfFile: configPath)
    guard let config = try Yams.load(yaml: configData) as? [String: String],
          let source = config["source"],
          let destination = config["destination"] else {
      print("Error: Invalid format in '\(configPath)'. Expected 'source' and 'destination' keys.")
      exit(1)
    }
    xcstringsPath = source
    outputFilePath = destination
  } catch {
    print("Error reading config file '\(configPath)': \(error)")
    exit(1)
  }
}

// At this point, xcstringsPath and outputFilePath are set
print("Using source: \(xcstringsPath)")
print("Using destination: \(outputFilePath)")

// Verify input file exists
guard FileManager.default.fileExists(atPath: xcstringsPath) else {
  fatalError("Input file does not exist: \(xcstringsPath)")
}

// Load and parse the .xcstrings file
guard let data = try? Data(contentsOf: URL(fileURLWithPath: xcstringsPath)),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let strings = json["strings"] as? [String: Any] else {
  fatalError("Failed to read or parse .xcstrings file")
}

// MARK: MAIN FUNCTIONS

func findProjectRoot(from directory: String) -> String? {
  var currentDir = directory
  while currentDir != "/" {
    let contents = try? FileManager.default.contentsOfDirectory(atPath: currentDir)
    if contents?.contains(where: { $0.hasSuffix(".xcodeproj") || $0.hasSuffix(".xcworkspace") }) == true {
      return currentDir
    }
    currentDir = URL(fileURLWithPath: currentDir).deletingLastPathComponent().path
  }
  return nil
}


// Add this helper function
func findFirstXcstringsFile(in directory: String) -> String? {
  let enumerator = FileManager.default.enumerator(atPath: directory)
  while let file = enumerator?.nextObject() as? String {
    if file.hasSuffix(".xcstrings") {
      return "\(directory)/\(file)"
    }
  }
  return nil
}



// Extract format specifiers from a string
func extractSpecifiers(from string: String) -> [String] {
  let regex = try! NSRegularExpression(pattern: "%d|%@|%f")
  let matches = regex.matches(in: string, options: [], range: NSRange(string.startIndex..., in: string))
  return matches.map { String(string[Range($0.range, in: string)!]) }
}

// Map specifiers to Swift types
func mapSpecifierToType(_ specifier: String) -> String {
  switch specifier {
  case "%d": return "Int"
  case "%@": return "String"
  case "%f": return "Float"
  default: return "Any" // Fallback (shouldn’t occur with current specifiers)
  }
}

// Generate labeled parameters (e.g., "p1: Int, p2: String")
func generateParameters(for specifiers: [String]) -> String {
  return specifiers.enumerated().map { (index, specifier) in
    switch specifier {
    case "%d": return "p\(index + 1): Int"
    case "%@": return "p\(index + 1): String"
    case "%f": return "p\(index + 1): Float"
    default: return ""
    }
  }.joined(separator: ", ")
}

// Generate arguments for String(format:) (e.g., "p1, p2")
func generateArguments(for specifiers: [String]) -> String {
  specifiers.enumerated().map { index, _ in
    "p\(index + 1)"
  }.joined(separator: ", ")
}

// Start building the output
var output = """
// Auto-generated file for type-safe access to .xcstrings
import Foundation

/// Type-safe access to localized strings from `Localizable.xcstrings`.
/// Automatically generated by `TypeLocXC.swift`. Do not edit manually.
///
/// The `L10n` enum provides functions for each string key in `Localizable.xcstrings`.
/// - Keys with dots (e.g., "GameOver.backToMain") are converted to underscores (e.g., `GameOver_backToMain`).
/// - For simple strings without format specifiers, the function takes no parameters.
/// - For strings with format specifiers (`%d`, `%@`, `%f`), the function includes labeled parameters (`p1`, `p2`, etc.) with types `Int`, `String`, `Float`, respectively.
/// - For plural strings defined with variations in `.xcstrings`, pass the count as the first parameter (typically `p1: Int`).
///
/// Example usage:
/// ```swift
/// // Simple string
/// let mainMenu = L10n.GameOver_backToMain()  // "Main Menu"
///
/// // Parameterized string
/// let score = L10n.HUD_Label_score(p1: 42)   // "Score: 42"
///
/// // Plural string (assuming "apple_count" is defined with plurals)
/// let oneApple = L10n.apple_count(p1: 1)     // "1 apple"
/// let manyApples = L10n.apple_count(p1: 5)   // "5 apples"
/// ```
///
/// Supported format specifiers:
/// - `%d`: Integer (`Int`)
/// - `%@`: String (`String`)
/// - `%f`: Float (`Float`)
///
/// Ensure `Localizable.xcstrings` is up-to-date in your project.

enum L10n {
"""

// Process each string key
for (key, value) in strings {
  guard let valueDict = value as? [String: Any],
        let localizations = valueDict["localizations"] as? [String: Any],
        let enLocalization = localizations["en"] as? [String: Any],
        let stringUnit = enLocalization["stringUnit"] as? [String: String],
        let stringValue = stringUnit["value"] else {
    continue
  }

  let specifiers = extractSpecifiers(from: stringValue)
  let safeKey = key.replacingOccurrences(of: ".", with: "_") // Replace dots for valid Swift identifiers
  let parameters = generateParameters(for: specifiers)
  let arguments = generateArguments(for: specifiers)

  if specifiers.isEmpty {
    output += """
        
    static func \(safeKey)() -> String {
        return NSLocalizedString("\(key)", tableName: "Localizable", comment: "")
    }
"""
  } else {
    output += """
        
    static func \(safeKey)(\(parameters)) -> String {
        return String(format: NSLocalizedString("\(key)", tableName: "Localizable", comment: ""), \(arguments))
    }
"""
  }
}

output += "\n}\n"

// Write the output file
do {
  try output.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
  print("✅ Generated \(outputFilePath) successfully!")
} catch {
  fatalError("Failed to write to \(outputFilePath): \(error)")
}

