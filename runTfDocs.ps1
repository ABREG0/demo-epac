
write-host "run `terraform fmt -recursive"
terraform fmt -recursive

    write-host "`nRunning tflint"
    tflint --init
    $tflintResult = @(tflint -f json) | convertfrom-json

    write-output "$($tflintResult.issues)"

    if ($null -ne $tflintResult.issues) {

        write-host "TFlint found issues $($tflintResult.issues)" -ForegroundColor red
        tflint -f sarif
        write-error "Error with tflint rules" -ErrorAction Stop
    }


write-host "`nRunning terraform docs"
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