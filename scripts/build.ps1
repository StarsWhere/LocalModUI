[CmdletBinding()]
param(
    [string]$GameRoot = $env:BEAT_SABER_DIR,
    [string]$BuildDirectory,
    [string]$OutputDirectory
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'build_local_paths.ps1')
if ((Get-Content -LiteralPath (Join-Path $GameRoot 'BeatSaberVersion.txt') -Raw).Trim() -ne '1.45.2_28848') { throw 'Unsupported game build.' }
if (!$BuildDirectory) { $BuildDirectory = Join-Path $RepoRoot '.tmp/local-mod-ui/bundle-build' }
$BuildDirectory = Resolve-RepoBuildPath $BuildDirectory
if (!$OutputDirectory) { $OutputDirectory = Join-Path $RepoRoot '.tmp/package' }
if ($OutputDirectory) { $OutputDirectory = Resolve-RepoBuildPath $OutputDirectory }

$uiBuild = Join-Path $RepoRoot '.tmp/local-mod-ui/build'
[IO.Directory]::CreateDirectory($uiBuild) | Out-Null
$source = Join-Path $PSScriptRoot 'local_mod_ui'
$compiler = Get-ChildItem -LiteralPath 'C:/Program Files/dotnet/sdk' -Directory | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1 | ForEach-Object { Join-Path $_.FullName 'Roslyn/bincore/csc.dll' }
if (!$compiler -or !(Test-Path -LiteralPath $compiler -PathType Leaf)) { throw 'A local .NET SDK with the Roslyn compiler is required.' }
$output = Join-Path $uiBuild 'LocalModUI.dll'
$arguments = @('/nologo','/target:library','/nostdlib+','/langversion:latest','/optimize+','/codepage:65001',('/out:'+$output))
$arguments += Get-ChildItem -LiteralPath (Join-Path $GameRoot 'Beat Saber_Data/Managed') -File -Filter '*.dll' | ForEach-Object { '/r:'+$_.FullName }
$arguments += @('Plugins/BSML.dll','Plugins/SiraUtil.dll','Libs/0Harmony.dll') | ForEach-Object { '/r:'+(Join-Path $GameRoot $_) }
$arguments += Get-ChildItem -LiteralPath $source -File -Filter '*.cs' | ForEach-Object { $_.FullName }
$arguments += @(('/resource:'+(Join-Path $source 'manifest.json')+',LocalModUI.manifest.json'),('/resource:'+(Join-Path $source 'Center.bsml')+',LocalModUI.Center.bsml'))
& 'C:/Program Files/dotnet/dotnet.exe' $compiler @arguments
if ($LASTEXITCODE -ne 0) { throw 'LocalModUI compilation failed.' }
if ($OutputDirectory) {
    $plugins = Join-Path $OutputDirectory 'Plugins'
    [IO.Directory]::CreateDirectory($plugins) | Out-Null
    Copy-Item -LiteralPath $output -Destination (Join-Path $plugins 'LocalModUI.dll') -Force
}
Write-Output $output
