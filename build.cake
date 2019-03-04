#tool nuget:?package=GitVersion.CommandLine&version=4.0.0
#addin nuget:?package=Cake.Powershell&version=0.4.7

///////////////////////////////////////////////////////////////////////////////
// ARGUMENTS
///////////////////////////////////////////////////////////////////////////////
var target      = Argument("target", "Default");
var apiKey      = Argument("apikey", EnvironmentVariable("PS_GALLERY_API_KEY") ?? "");

Task("Default")
  .Does(() =>
{
  GitVersion(new GitVersionSettings {
    OutputType = GitVersionOutput.BuildServer
  });

  var version = GitVersion();
  Information($"Version: {version.NuGetVersionV2}");

  StartPowershellFile("./Deploy.ps1", args =>
  {
        args.Append("version", version.AssemblySemFileVer);

        if (!string.IsNullOrEmpty(apiKey)) {
            args.Append("apiKey", apiKey)
            ;
        }
  });

});

RunTarget(target);