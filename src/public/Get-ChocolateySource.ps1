function Get-ChocolateySource {
    [CmdletBinding()]
    Param()

    process {

        $chocoArgs = @('source','list','-r')
        $header = @('Name',
        'Source',
        'Disabled',
        'Authenticated',
        'Certificate',
        'Priority',
        'BypassProxy',
        'SelfService',
        'AdminOnly')

        & choco @chocoArgs | ConvertFrom-Csv -Delimiter '|' -Header $header
    }
}