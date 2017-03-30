
<# 
 .NAME
        AuditDotNetVersion
.SYNOPSIS  
    Get mseg dotnet compliance results and call the function to insert the compliacne date to Table.
.DESCRIPTION
    It will read the xml from azure or local  and call the Get-MSEGdotNetCompliance function to get dotnetcompliance results, after that it will call Add-DataTableToSQL  to insert the results to table.

.EXAMPLE
    AuditDotNetVersion -SourceDS $SourceDs -OutputFolder <Path> -OutputDistinctValue <Value> -AuditRunID $AuditRunID -DBConnectionString $DBConnectionString

    
      
.Inputs
   SourceDS
   OutputFolder
   OutputDistinctValue
   AuditRunID
   DBConnectionString
.OUTPUTS
    FinalResults   : All the dot net compliance results of the servers provided in xml file
    ActivityStatus : True/False

#>
    [CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$True, HelpMessage="Source dataset")]
        [object]$SourceDS,
        [Parameter(Position=1, Mandatory=$True, HelpMessage="Location for Output Files")]
        [string]$OutputFolder,
        [parameter(position=2, Mandatory=$True, HelpMessage="Distinct Run ID value")]
        [string]$OutputDistinctValue,
        [parameter(position=3, Mandatory=$True, HelpMessage="Audit Run ID value")]
        [string]$AuditRunID,
        [parameter(position=4, Mandatory=$True, HelpMessage="DB Connection String object")]
        [System.Data.SqlClient.SqlConnection]$DBConnectionString
    )


    #Import-Module E:\AzurePOCAudits\Auditcode\ActiveDirectory -force
    Import-Module E:\AzurePOCAudits\Auditcode\AuditFunctions -force
    Import-Module E:\AzurePOCAudits\Auditcode\MSEG.Data -force

   <# If(!(Test-Path -Path $SourceDS)) 
    {
        #Write-Host "Source file is not found"
        Exit
    }#>

    If(!(Test-Path -Path $OutputFolder))
    {
        #Write-Host "Output folder does not exist"
        Exit
    }


    #[String]$xpVersionStatusfile = Join-Path -Path $OutputFolder -ChildPath "XPVersionStatus$OutputdistinctValue.csv"
    #Reading xml from azure 

if($SourceDS -match "https")
{
    $DataSource_XML=$SourceDS

$doc=New-Object System.Xml.XmlDocument
   $doc.Load($DataSource_XML);
   $Dataset = $doc.Load($DataSource_XML);
        
        [array]$ServerCount=$doc.objs.obj.ms
        if ($ServerCount.Count -gt 0)
        { $ActivityStatus = $true; $ActivityMsg = "{0} targets retrieved from $DataSource_XML" -f $ServerCount.Count.ToString(); }
        else
        { $ActivityMsg = "No dataset returned from $DataSource_XML"; }

	    $Dataset=@();

	    for($i=0;$i -lt $ServerCount.Count; $i++)
	    {
		    $OutputObj = New-Object PsObject;
            if($ServerCount.Count -eq 1)
            {
		        [array]$1try = $doc.objs.obj.ms.childnodes | group N,"#text" | select Name
            }
            else
            {
                [array]$1try = $doc.objs.obj.ms[$i].childnodes | group N,"#text" | select Name
            }
	            for($j=0;$j -lt $1try.Length;$j++)
	            {  
	                [array]$Val=$1try[$j].Name.Split(",")
		            $OutputObj | Add-Member NoteProperty $val[0]$val[1].Trim();
                }
	                $Dataset+=$OutputObj;
        
	    }

[Array]$ServerList = $Dataset
}
else
{

    [Array]$ServerList = Import-Clixml $SourceDS -ErrorAction Stop;

}
    [String]$WorkingLog = Join-Path -Path $Outputfolder -childpath "Logrun$OutputdistinctValue.Log"

    #Determine which Domain we are working in
    $CompSysInfo = get-wmiobject Win32_ComputerSystem 
    $Mydomain = $Compsysinfo.Domain
    SWitch($MyDomain)
    {
	    "Phx.gbl"
	    {
		    [String]$DomaintoCheck = 'Phx'
		    [String]$EZexecAccount = 'Phx-EZExec'
	    }
	    "Redmond.Corp.Microsoft.com"
	    {
		    [String]$DomaintoCheck = 'Redmond'
		    [String]$EZexecAccount = 'EZExec'
	    }
    } 



    #Declare Strings to be used.
    $MyAuditRunID = $AuditRunID

    [Array]$AllDotNet = @()


    [int]$Servercount = 0

    [String]$Totalcount = $serverList.count
    Foreach($Server in $ServerList)
    {
   #  $Server = $ServerList[0]
        $Servercount++
        $ServerFQDN = $Server.ServerFQDN
        $ServerName = $Server.ServerName
        $listdate = get-date
        Write-Output "$Listdate -  Attempting: $ServerName :CurrentServer Count:  $ServerCount of $TotalCount" | Out-File $WorkingLog -Append;

        $ServerAccess = $Null;

        [Array]$DomainParsed = $ServerFQDN.Split('.')
        $SGDomain = $DomainParsed[1]

        #
        #  Activity Directory Audit
        #
        [Array]$NetResults = Get-MSEGdotNetCompliance $ServerName $ServerFQDN $AuditRunID $WorkingLog
        $AllDotNet += $NetResults

 

    }

    $TargetServerName = "patchsqldb.database.windows.net"
    $TargetDbName = 'EZ_Automation_Development'
   <# $user = "patchlogadmin"
    $pwd = "EZPatch!23"
    $security = ("Uid={0};Pwd={1};" -f $user,$pwd) #>

    $TargetTableName = 'audit.NETCompliance'
    $DotNetTable = ConvertTo-DataTable -Source $AllDotNet
    Add-DataTableToSQL -SQLServer $TargetServerName -SQLDB $TargetDbName  -SQLConnection $DBConnectionString -Target $TargetTableName -Source $DotNetTable -ExcludeFieldList ('RecordID')

   

    $listdate = get-date
    Write-Output "$Listdate - $WorkingLog for .NET Audit is now COMPLETE" | Out-File $WorkingLog -Append;

    [String]$CompleteLog = Join-Path -Path $OutputFolder -ChildPath "Logrun-COMPLETE$OutputDistinctValue.log"
    Move-Item -Path $WorkingLog -Destination $CompleteLog -Force  
    #Rename-Item $WorkingLog $CompleteLog -Force

    if($AllDotNet.Count -gt 0)
    {
         $Outputobj = New-Object PsObject;
	    $Outputobj | Add-Member NoteProperty FinalResults $AllDotNet
	    $Outputobj | Add-Member NoteProperty ActivityStatus $true;
        
    }
    else
    {
         $Outputobj = New-Object PsObject;
	    $Outputobj | Add-Member NoteProperty FinalResults $AllDotNet
	    $Outputobj | Add-Member NoteProperty ActivityStatus $false;
    }

     $AllDotNet = $Null
    $DotNetTable = $Null

    return $OutputObj;
#}
