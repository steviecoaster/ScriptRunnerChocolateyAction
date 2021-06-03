[cmdletBinding()]
param(
    [Parameter()]
    [Switch]
    $Build,
    
    [Parameter()]
    [Switch]
    $TestPrePublish,

    [Parameter()]
    [Switch]
    $TestPostPublish,

    [Parameter()]
    [Switch]
    $DeployToGallery,

    [Parameter()]
    [Switch]
    $Choco
)

process {

    $root = Split-Path -Parent $MyInvocation.MyCommand.Definition

    switch ($true) {

        $Build {

            if (Test-Path "$root\Output") {
                Remove-Item "$root\Output\ScriptRunnerChocolatey\*.psm1" -Recurse -Force
            } else {
                $Null = New-Item "$root\Output" -ItemType Directory
                $null = New-item "$root\Output\ScriptRunnerChocolatey" -ItemType Directory
            }
        
            if (Test-Path "$root\src\nuget\tools\ScriptRunnerChocolatey.zip") {
                Remove-Item "$root\src\nuget\tools\ScriptRunnerChocolatey.zip" -Force
            }
            
            Get-ChildItem $root\src\public\*.ps1 | 
            Foreach-Object { 
                Get-Content $_.FullName | Add-Content "$root\Output\ScriptRunnerChocolatey\ScriptRunnerChocolatey.psm1" -Force
            }

            Get-ChildItem $root\src\private\*.ps1 | 
            Foreach-Object { 
                Get-Content $_.FullName | Add-Content "$root\Output\ScriptRunnerChocolatey\ScriptRunnerChocolatey.psm1" -Force
            }

            Copy-Item $root\ScriptRunnerChocolatey.psd1 $root\Output\ScriptRunnerChocolatey -Force


        }

        $TestPrePublish {
            
            Get-ChildItem $root\src\public\*.ps1, $root\Poshbot\*.ps1 | 
            Foreach-Object { 
                . $_.FullName
            }
            #Import-Module "$root\Output\ScriptRunnerChocolatey\ScriptRunnerChocolatey.psd1" -Force
            Import-Module PoshBot -Force

            Invoke-Pester "$root\tests\pre"
            
        }

        $TestPostPublish {

            Install-Module ScriptRunnerChocolatey -Force
            Import-Module PoshBot -Force

            Invoke-Pester "$root\tests\*.ps1"
        }

        $DeployToGallery {

            Publish-Module -Path "$root\Output\ScriptRunnerChocolatey" -NuGetApiKey $env:NugetApiKey

        }

        $Choco {
            
            $Nuspec = Get-ChildItem "$root\src\nuget" -recurse -filter *.nuspec

            if (Test-Path "$root\src\nuget\tools\ScriptRunnerChocolatey.zip") {
                choco pack $Nuspec.Fullname --output-directory $Nuspec.directory
            }

            else {
                throw "Welp, ya need the zip in the tools folder, dumby"
            }
            Get-ChildItem "$root\src\nuget" -recurse -filter *.nupkg | 
            Foreach-Object { 
                choco push $_.FullName -s https://push.chocolatey.org --api-key="'$($env:ChocoApiKey)'"
            }

        }

    }

}