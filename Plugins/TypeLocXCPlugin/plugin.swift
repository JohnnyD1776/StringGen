import PackagePlugin
import Foundation

@main
struct TypeLocXCPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
    // Locate the TypeLocXC tool
    let tool = try context.tool(named: "TypeLocXC")

    // Define input and output paths
    let sourcePath = context.package.directory.appending("Resources/Localizable.xcstrings")
    let outputPath = context.pluginWorkDirectory.appending("Strings+Generated.swift")

    // Check for config file (optional)
    let configPath = context.package.directory.appending("TypeLocXC.yml")
    var arguments: [String]
    if FileManager.default.fileExists(atPath: configPath.string) {
      arguments = ["--config", configPath.string]
    } else {
      arguments = [sourcePath.string, outputPath.string]
    }

    // Define the build command
    return [
      .prebuildCommand(
        displayName: "Generate Type-Safe Localization with TypeLocXC",
        executable: tool.path,
        arguments: arguments,
        outputFilesDirectory: context.pluginWorkDirectory
      )
    ]
  }
}
