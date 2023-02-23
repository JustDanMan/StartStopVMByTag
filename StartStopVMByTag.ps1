<#
    .DESCRIPTION
        A runbook which start or stop VMs by tag

    .NOTES
        AUTHOR: Daniel Vigano
        LASTEDIT: Feb 23, 2023
#>

workflow StartStopVMByTag {
    param (
        [Parameter(Mandatory=$true)]
        [String]$SubscriptionID,

        [Parameter(Mandatory=$true)]
        [String]$TagName,

        [Parameter(Mandatory=$true)]
        [String]$TagValue,

        [Parameter(Mandatory=$true)]
        [Boolean]$Shutdown
    )

    try
    {
        "Logging in to Azure..."
        Connect-AzAccount -Identity
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

	Set-AzContext -SubscriptionId $SubscriptionID

    $VMs = Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" -TagName $TagName -TagValue $TagValue

    foreach -Parallel ($VM in $VMs)
    {    
        if($Shutdown) {
            Write-Output ("Stopping " + $vm.Name)
            Stop-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force
        }
        else {
            Write-Output ("Starting " + $vm.Name)
            Start-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
        }
    }
}