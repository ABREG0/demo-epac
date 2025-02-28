
$exampleFolders = Get-ChildItem -Directory

foreach ($folder in $exampleFolders) {
    try {
    <# $folder is the current item #>
    write-host "`n################################################`n"
    write-host "Running example $($folder.FullName)" -ForegroundColor green  -BackgroundColor Blue
    }
}
terraform fmt -recursive
terraform-docs -c '.\.terraform-docs.yml' .
$docFolders = @("examples", "modules")
foreach($folder in $docFolders){
    get-childItem -path $folder -Directory | % {echo "$($_.FullName)\"; terraform-docs -c '.\.terraform-docs.yml' "$($_.FullName)\"}
}
