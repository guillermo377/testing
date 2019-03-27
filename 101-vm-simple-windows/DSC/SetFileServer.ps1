configuration SetFileServer 
{ 
   param 
   ( 

        [Parameter(Mandatory)]
        [String]$FirstGroupName,
        [Parameter(Mandatory)]
        [String]$SecondGroupName,

        [Int]$RetryCount=40,
        [Int]$RetryIntervalSec=60

    ) 
    
    Import-DscResource -ModuleName xStorage,xSmbShare,PSDesiredStateConfiguration,cNtfsAccessControl

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
             DestinationPath = 'H:\'+ $FirstGroupName +'Data'
             DependsOn = '[xDisk]HVolume','[WindowsFeature]FileServices'

           }


        File 'ShareFolderTwo'

           {

             Ensure = 'Present'
             Type = 'Directory'
             DestinationPath = 'I:\'+ $SecondGroupName +'Data'
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


        cNtfsPermissionEntry 'FileShareRightsOne'

            {
                 Ensure = 'Present'
                 DependsOn = '[File]ShareFolderOne','[Group]GroupOne','[xDisk]HVolume'
                 Principal = $FirstGroupName +'SecurityGroup'
                 Path = 'H:\'+ $FirstGroupName +'Data'
                 AccessControlInformation = @(

                       cNtfsAccessControlInformation

                       {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'Read,Write,Modify'
                            Inheritance = 'ThisFolderSubfoldersAndFiles'
                            NoPropagateInherit = $false
                       }
                 )

            }


        cNtfsPermissionEntry 'FileShareRightsTwo'

            {
                 Ensure = 'Present'
                 DependsOn = '[File]ShareFolderOne','[Group]GroupOne','[xDisk]IVolume'
                 Principal = $SecondGroupName +'SecurityGroup'
                 Path = 'I:\'+ $SecondGroupName +'Data'
                 AccessControlInformation = @(

                       cNtfsAccessControlInformation

                       {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'Read,Write,Modify'
                            Inheritance = 'ThisFolderSubfoldersAndFiles'
                            NoPropagateInherit = $false
                       }
                 )

            }

}

} 