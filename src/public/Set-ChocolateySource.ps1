function Set-ChocolateySource {
    
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "add", Mandatory)]
        [Parameter(ParameterSetName = "remove", Mandatory)]
        [ValidateSet('Add', 'Remove')]
        [String]
        $Action,

        [Parameter(ParameterSetName = "add", Mandatory)]
        [Parameter(ParameterSetName = "remove")]
        [String]
        $FriendlyName,
        
        [Parameter(ParameterSetName = "add", Mandatory)]
        [Parameter(ParameterSetName = "remove", Mandatory)]
        [String]
        $Source,

        [Parameter(ParameterSetName = "add")]
        [Switch]
        $AllowSelfService,

        [Parameter(ParameterSetName = "add")]
        [Switch]
        $AdminOnly,

        [Parameter(ParameterSetName = "add")]
        [ValidateRange(0, 100)]
        [Int]
        $Priority,

        [Parameter(ParameterSetName = "add")]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(ParameterSetName = "add")]
        [ValidateScript( { Test-Path $_ })]
        [String]
        $PFXCertificate,
        
        [Parameter(ParameterSetName = "add")]
        [String]
        $CertificatePassword,

        [Parameter(ParameterSetName = "add")]
        [Switch]
        $BypassProxy
    )

    begin {       
        if (-not (Get-Command choco)) {
            throw "Chocolatey is required for this plugin"
        }

        $ChocoArgs = [System.Collections.Generic.List[string]]::New()
        $ChocoArgs.Add('source')
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            'Add' {
                
                $ChocoArgs.Add('add')

                #Add the base arguments, then Add the remainder from provided parameter values
                foreach ($BoundParam in $PSBoundParameters.GetEnumerator()) {
                    $parameter = $null
                    $value = $null

                    switch ($BoundParam.Key) {
                        'FriendlyName' {
                            $parameter = '--name'
                            $value = $BoundParam.Value
                            $chocoArgs.Add("$parameter='$value'")

                    
                        }
                        'Source' {
                            $parameter = '--source'
                            $value = $BoundParam.Value
                            $chocoArgs.Add("$parameter='$value'")

                        }
                        'AllowSelfService' {
                            $chocoArgs.Add('--allow-self-service')
                        }
                        'AdminOnly' {
                            $chocoArgs.Add('--admin-only')
                        }
                        'Priority' {
                            $parameter = '--priority'
                            $value = $BoundParam.Value
                            $chocoArgs.Add("$parameter='$value'")

                        }
                        'Credential' {
                            $chocoArgs.Add('--user="$($Credential.UserName)"')
                            $chocoArgs.Add('--password="$($Credential.GetNetworkCredential().Password)"')
                        }
                        'PFXCertificate' {
                            $parameter = '--cert'
                            $value = $BoundParam.Value
                            $chocoArgs.Add("$parameter='$value'")

                        }
                        'CertificatePassword' {
                            $parameter = '--certpassword'
                            $value = $BoundParam.Value
                            $chocoArgs.Add("$parameter='$value'")

                        }
                        'BypassProxy' {
                            $chocoArgs.Add('--bypass-proxy')
                        }
                    }
                }

                try {
                    & choco @ChocoArgs
               }
               catch {
                   throw $_
               }
            }

            'Remove' {

                $ChocoArgs.Add('remove')
                foreach ($BoundParam in $PSBoundParameters.GetEnumerator()) {
                    $parameter = $null
                    $value = $null
                    
                    switch ($BoundParam.Key) {
                        'FriendlyName' {
                            $parameter = '--name'
                            $value = $BoundParam.Value
                            $chocoArgs.Add("$parameter='$value'")
                        }

                        'Source' {
                            $parameter = '--source'
                            $value = $BoundParam.Value
                            $chocoArgs.Add("$parameter='$value'")
                        }
                    }
                }

                try {
                    & choco @ChocoArgs
               }
               catch {
                   throw $_
               }
            }
        }

        
    }
}