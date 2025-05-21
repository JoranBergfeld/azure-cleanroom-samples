param(
    [ValidateSet("litware")]
    [string]$persona = "$env:PERSONA",
    [string]$resourceGroup = "$env:RESOURCE_GROUP",

    [string]$samplesRoot = "/home/samples",
    [string]$privateDir = "$samplesRoot/demo-resources/private",

    [string]$demo = "$(Split-Path $PSScriptRoot -Leaf)",
    [string]$environmentConfig = "$privateDir/$resourceGroup.generated.json",
    [string]$contractConfig = "$privateDir/$resourceGroup-$demo.generated.json"
)

#https://learn.microsoft.com/en-us/powershell/scripting/learn/experimental-features?view=powershell-7.4#psnativecommanderroractionpreference
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

Import-Module $PSScriptRoot/../../scripts/common/common.psm1

if (-not (("litware") -contains $persona))
{
    Write-Log Warning `
        "No action required for persona '$persona' in demo '$demo'."
    return
}

$configResult = Get-Content $contractConfig | ConvertFrom-Json
Write-Log OperationStarted `
    "Adding application details for '$persona' in the '$demo' demo to" `
    "'$($configResult.contractFragment)'..."

#
# Use inline code instead of packaging application into a container.
#
$image = "docker.io/mathworks/matlab:r2024b"
$inline_code = $(cat $PSScriptRoot/application/wafer_plot.m | base64 -w 0)

# Define the command with correct variable escaping
# Note: we need to use single quotes for the outer command and escape the $CODE variable with a backslash
$command = "bash -c 'echo $CODE | base64 -d > wafer_plot.m; matlab -nosplash -nodesktop -r `"run(wafer_plot.m); exit;`"'" `

az cleanroom config add-application `
    --cleanroom-config $configResult.contractFragment `
    --name demoapp-$demo `
    --image $image `
    --command $command `
    --datasources "fabrikam-input=/mnt/remote/fabrikam-input" `
    --datasinks "fabrikam-output=/mnt/remote/fabrikam-output" `
    --env-vars "WAFER_OUTPUT_DIRECTORY=/mnt/remote/fabrikam-output/" `
               "WAFER_OUTPUT_FILENAME=plot.jpg" `
               "WAFER_INPUT_DIRECTORY=/mnt/remote/fabrikam-input/" `
               "WAFER_INPUT_FILENAME=data.xml" `
               "CODE=$inline_code" `
    --cpu 0.5 `
    --memory 4

Write-Log OperationCompleted `
    "Added application 'demoapp-$demo' ($image)."