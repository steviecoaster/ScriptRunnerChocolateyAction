function Upgrade-ChocolateyPackage {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String[]]
        $Package,

        [Parameter()]
        [String]
        $Source
    )

    begin {       
        
        if(-not (Get-Command choco)){
            throw "Chocolatey is required for this plugin"
        }

        $ChocoArgs = [System.Collections.Generic.List[string]]::New()
        $ChocoArgs.Add('upgrade')
    }

    process {
        $ChocoArgs.Add("$($Package -join ';')")

        if($Source){
            $ChocoArgs.Add("--source='$Source'")
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