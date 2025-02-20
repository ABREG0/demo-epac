
$tfdocs = Get-ChildItem -path . -include .terraform-docs.yml -Recurse

foreach ($tfdoc in $tfdocs) {
    <# $currentItemName is the current item #>
    write-host "Directory name [$($tfdoc.Directory)]"

        $tfFiles = get-childItem -path "$($tfdoc.Directory)" -name *.tf
        $tfFiles
        if($null -eq $tfFiles){
            write-host "NO terraform files in directory" -ForegroundColor Red
        }
        # -and !(test-path -path "$($tfdoc.Directory)\_footer.md)" -PathType leaf)
        if($null -eq (get-childItem -path "$($tfdoc.Directory)" -name _*.md) ){
            
            write-host "Missing header or footer markdown files in directory" -ForegroundColor Red
        }
    
    $tfdoc.FullName

    echo "##############"
}