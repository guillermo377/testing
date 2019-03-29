configuration SetFileServer 
{ 
   param 
   ( 

        [Parameter(Mandatory)]
        [String]$FirstGroupName,
        [Parameter(Mandatory)]
        [String]$SecondGroupName,

        [String]$PathOne = ("H:\$FirstGroupName" + "Data"),
        [String]$PathTwo = ("I:\$SecondGroupName" + "Data"),
        [Int]$RetryCount=80,
        [Int]$RetryIntervalSec=120

    ) 
    
    Import-DscResource -ModuleName xStorage,xSmbShare,PSDesiredStateConfiguration,PowerShellAccessControl

    Node localhost
    {


        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec = $RetryIntervalSec
             RetryCount = $RetryCount
        }
   

        xDisk HVolume
        {
             DiskNumber = 2
             DriveLetter = 'H'
             FSFormat = 'NTFS'
             FSLabel = $FirstGroupName + 'Data'
             DependsOn = '[xWaitforDisk]Disk2'

        }
        
        xWaitForDisk Disk3

        {
             DiskNumber = 3
             RetryIntervalSec = $RetryIntervalSec
             RetryCount = $RetryCount
        }
        
        
        xDisk IVolume

        {
             DiskNumber = 3
             DriveLetter = 'I'
             FSFormat = 'NTFS'
             FSLabel = $SecondGroupName + 'Data'
             DependsOn = '[xWaitforDisk]Disk3'

        }

        
        WindowsFeature 'FileServices'

           {

             Ensure = 'Present'
             Name = 'File-Services'

           }

           
        File 'ShareFolderOne'

           {

             Ensure = 'Present'
             Type = 'Directory'
             DestinationPath = $PathOne
             DependsOn = '[xDisk]HVolume','[WindowsFeature]FileServices'

           }


        File 'ShareFolderTwo'

           {

             Ensure = 'Present'
             Type = 'Directory'
             DestinationPath = $PathTwo
             DependsOn = '[xDisk]IVolume','[WindowsFeature]FileServices'

           }


        xSmbShare 'ShareOne'

           {

             Ensure = 'Present'
             Name   = $FirstGroupName +'Data'
             Path = 'H:\'+ $FirstGroupName +'Data'
             FullAccess = 'Everyone'
             DependsOn = '[File]ShareFolderOne'

            }


        xSmbShare 'ShareTwo'

           {

             Ensure = 'Present'
             Name   = $SecondGroupName +'Data'
             Path = 'I:\'+ $SecondGroupName +'Data'
             FullAccess = 'Everyone'
             DependsOn = '[File]ShareFolderTwo'

            }


        Group 'GroupOne'

            {
    
                Ensure = "Present"
                GroupName = $FirstGroupName +'SecurityGroup'
            }


        Group 'GroupTwo'

            {
    
                Ensure = "Present"
                GroupName = $SecondGroupName +'SecurityGroup'
            }


        File TestDirectoryOne

            {
                Ensure = 'Present'
                DestinationPath = $PathOne
                Type = 'Directory'
            }

        File TestDirectoryTwo

            {
                Ensure = 'Present'
                DestinationPath = $PathTwo
                Type = 'Directory'
            }
        
        
        cAccessControlEntry RightsFirstShare 
        
            {

            AceType = "AccessAllowed"
            DependsOn = '[File]TestDirectoryOne'
            ObjectType = "Directory"
            Path = $PathOne
            Principal = $FirstGroupName +'SecurityGroup'
            AccessMask = [System.Security.AccessControl.FileSystemRights]::Modify
            AppliesTo = "Object, ChildContainers"  # Apply to the folder and subfolders only

            }

        cAccessControlEntry RightsSecondShare 
        
            {

            AceType = "AccessAllowed"
            DependsOn = '[File]TestDirectoryTwo'
            ObjectType = "Directory"
            Path = $PathTwo
            Principal = $SecondGroupName +'SecurityGroup'
            AccessMask = [System.Security.AccessControl.FileSystemRights]::Modify
            AppliesTo = "Object, ChildContainers"  # Apply to the folder and subfolders only

            }    

    }

} 