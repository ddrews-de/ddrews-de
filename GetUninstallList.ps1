#Create an array with a list of all regestry paths to uninstall keys
$UninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)
#create an empty array to store the result
$UninstallList = @()
#read the array and get all the keys
$UninstallKeys | ForEach-Object {
    #Get all the subkeys
    $SubKeys = Get-ChildItem -Path $_ -ErrorAction SilentlyContinue
    #read the subkeys and get the values
    $SubKeys | ForEach-Object {
        #Get the values
        $DisplayName = (Get-ItemProperty -Path $_.PSPath -Name DisplayName -ErrorAction SilentlyContinue).DisplayName
        $DisplayVersion = (Get-ItemProperty -Path $_.PSPath -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
        $Publisher = (Get-ItemProperty -Path $_.PSPath -Name Publisher -ErrorAction SilentlyContinue).Publisher
        $InstallDate = (Get-ItemProperty -Path $_.PSPath -Name InstallDate -ErrorAction SilentlyContinue).InstallDate
        $UninstallString = (Get-ItemProperty -Path $_.PSPath -Name UninstallString -ErrorAction SilentlyContinue).UninstallString
        #Get the parent Key name
        $ParentKeyName = (Split-Path -Path $_.PSPath -Leaf)
        #Get the path and replace the HKEY_LOCAL_MACHINE with HKLM: and HKEY_CURRENT_USER with HKCU:
        $Path = $_.PSPath -replace "HKEY_LOCAL_MACHINE","HKLM:" -replace "HKEY_CURRENT_USER","HKCU:" -replace "Microsoft.PowerShell.Core\\Registry::",""

        #Create a custom object

        $UninstallObj = [PSCustomObject]@{
            Path = $Path
            ParentKeyName = $ParentKeyName
            DisplayName = $DisplayName
            DisplayVersion = $DisplayVersion
            Publisher = $Publisher
            InstallDate = $InstallDate
            UninstallString = $UninstallString
        }

        #Add the custom object to the array list when the displayname is not null
        if($DisplayName){
            $UninstallList += $UninstallObj
        }
    
    }
}
#export the result to a csv file
$UninstallList | Export-Csv -Path "C:\temp\UninstallList.csv" -NoTypeInformation -Force
