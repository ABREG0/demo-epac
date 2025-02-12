
$exampleFolders = Get-ChildItem -Directory

$deploymentMatrix = @()

foreach ($folder in $exampleFolders) {
    
    <# $folder is the current item #>
    write-host "`n################################################`n"
    write-host "Running example $($folder.FullName)" -ForegroundColor green  -BackgroundColor Blue

    $deployment = @{
    name= "$($folder.name)"
    path= "example/$($folder.name)"
    remote_state_key= "$($folder.name).tfstate"
    runner= "ubuntu-latest"
    run_plan_only= "false"
    }
    $deploymentMatrix += $deployment
    
}
$deploymentMatrix | convertto-json