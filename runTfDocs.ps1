
$tfdocs = Get-ChildItem -path . -include .terraform-docs.yml -Recurse

foreach ($tfdoc in $tfdocs) {
    <# $currentItemName is the current item #>
    write-host "Directory name [$($tfdoc.Directory)]"

        $tfFiles = get-childItem -path "$($tfdoc.Directory)"
        
        $tf = $tfFiles.Name -match '.tf'

        if($tf.count -ne 0){
        
            $md = $tfFiles.Name -match '_*.md'
            if($md.count -ne 0){
                $tfdoc.FullName
                terraform-docs $tfdoc.Directory
            }
            else {
                
                write-host "Missing header or footer markdown files in directory `n $($md)" -ForegroundColor red
            }
        }
        else {
            write-host "NO terraform files in directory" -ForegroundColor Red
        }
    

    echo "##############"
}