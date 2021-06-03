function Install-ChocolateyPackage {
    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName = "package", Mandatory)]
        [String[]]
        $Package,

        [Parameter(ParameterSetName = "config", Mandatory)]
        [String]
        $PackageConfig,

        [Parameter(ParameterSetName = "package")]
        [Parameter(ParameterSetName = "config")]
        [String]
        $Source,

        [Parameter(ParameterSetName = "package")]
        [Parameter(ParameterSetName = "config")]
        [String]
        $Version,

        [Parameter(ParameterSetName = "package")]
        [Parameter(ParameterSetName = "config")]
        [switch]
        $UseVerbose,

        [Parameter(ParameterSetName = "package")]
        [Parameter(ParameterSetName = "config")]
        [Switch]
        $Trace,

        [Parameter(ParameterSetName = "package")]
        [Parameter(ParameterSetName = "config")]
        [Switch]
        $Force
    )
    begin {       
        
        if(-not (Get-Command choco)){
            throw "Chocolatey is required for this plugin"
        }

        $ChocoArgs = [System.Collections.Generic.List[string]]::New()
        $ChocoArgs.Add('install')
    }

    process {

        Switch ($PSCmdlet.ParameterSetName) {
            'package' {
                $ChocoArgs.Add("$($Package -join ' ')")
            }
            'config' {
                $ChocoArgs.Add($PackageConfig)
            }
        }

        switch ($true) {
            'Trace' { 
                $ChocoArgs.Add('--trace')
            }
            'Force' { 
                $ChocoArgs.Add('--force')
            }
            'UseVerbose' {
                $ChocoArgs.Add('--verbose')
            }
        }

        if($Source){
            $ChocoArgs.Add("--source='$Source'")
        }

        if($Version){
            $ChocoArgs.Add("--version='$Version'")
        }

        $ChocoArgs.Add('-y')

       try {
            & choco @ChocoArgs
       }
       catch {
           throw $_
       }
    }
}