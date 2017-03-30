<#  
    .NAME
        Run-EZD_AuditDB
  
    .SYNOPSIS  
        it will call Start,Update and End stored procedures based on user input

    .DESCRIPTION
        This Function called from runbook created in azure portal. runbook details provided in below.
           runbookname:AuditsProofsofconcept
           Automation Account Name : EZPatch
           resource group : nonprod
           Subscription: MSEG Deployment and Automation -Non-Prod
        it will take Action as one of the input parameters and perform the action based on the user input. 

    .NOTES  
        
    .EXAMPLE

        .\Run-EZD_AuditDB.ps1 -AuditType "AuditDotNetVersion" -Action "StartAudit\UpdateAudit\EndAudit"

        .\Run-EZD_AuditDB.ps1 -AuditType "AuditDotNetVersion" -Action "StartAudit\UpdateAudit\EndAudit" -EndStatus True/False 
         
    .OUTPUTS
       it will send  Auditrunid to runbook
	#>
[CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true, HelpMessage="AuditScript")]
        [string]$AuditScript,
         [Parameter(Position=1, Mandatory=$true, HelpMessage="Action ")]
        [string]$Action,
         [Parameter(Position=2, Mandatory=$false, HelpMessage="end status ")]
        [string]$EndStatus
         
        )


$RptSQLServer = "patchsqldb.database.windows.net";
$RptSQLDB = "EZ_Automation_Development"

$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString ="Server=$RptSQLServer;Database=$RptSQLDB;Authentication=Active Directory Integrated;Encrypt=True;TrustServerCertificate=False;" 
$Conn.Open()


Switch($Action)
{
    "StartAudit"
    {
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand;
        $SqlCmd.Connection = $Conn;
        #$AuditScript="AuditDotNetVersion"
        $insert_stmt = "select WorkflowId from WorkflowType where WorkflowName='$AuditScript'"
                $SqlCmd.CommandText =$insert_stmt ;
                $cmdtxt=$SqlCmd. CommandText;
                #$exec=$SqlCmd.ExecuteNonQuery();
                $wid= $SqlCmd.ExecuteScalar();   
                  
        #$Workflowtypeid= Invoke-Sqlcmd -ServerInstance "patchsqldb.database.windows.net" -Database "EZ_Automation_Development" -Query "select WorkflowId from WorkflowType where WorkflowName='$AuditScript'" -Username "patchlogadmin" -Password "EZPatch!23"
        #$wid=$Workflowtypeid.WorkflowId
        $ServerName= "CO1MSSSSBILDB22"
        $Execuuser= whoami
        $Command = new-Object System.Data.SqlClient.SqlCommand("StartAuditRun", $Conn)
        $Command.CommandType = [System.Data.CommandType]'StoredProcedure'
        $Command.Parameters.Add("@WorkflowId", [System.Data.SqlDbType]"int")
        $Command.Parameters["@WorkflowId"].Value = $wid
        $Command.Parameters.Add("@HostServerName", [System.Data.SqlDbType]"nvarchar")
        $Command.Parameters["@HostServerName"].Value =$ServerName
        $Command.Parameters.Add("@ExecutionUser",[System.Data.SqlDbType]"nvarchar")
        $Command.Parameters["@ExecutionUser"].Value =$Execuuser
        $Command.Parameters.Add("@RunId",[System.Data.SqlDbType]"int")
        $Command.Parameters["@RunId"].Direction = [system.Data.ParameterDirection]::Output
        $Command.ExecuteNonQuery();

        $runid = $Command.Parameters["@RunId"].value

       
    }
    "UpdateAudit"
    {
        $Command = new-Object System.Data.SqlClient.SqlCommand("UpdateAuditRunStatus", $Conn)
        $Command.CommandType = [System.Data.CommandType]'StoredProcedure'
        $Command.Parameters.Add("@AuditRunId", [System.Data.SqlDbType]"int")
        $Command.Parameters["@AuditRunId"].Value = $runid
        $Command.Parameters.Add("@StatusCode", [System.Data.SqlDbType]"nvarchar")
        $Command.Parameters["@StatusCode"].Value ="RUNNING"
        $Command.ExecuteNonQuery();
    }
    "EndAudit"
    {
        if($EndStatus -eq $true)
        {
             $Command = new-Object System.Data.SqlClient.SqlCommand("EndAuditRun", $Conn)
            $Command.CommandType = [System.Data.CommandType]'StoredProcedure'
            $Command.Parameters.Add("@AuditRunId", [System.Data.SqlDbType]"int")
            $Command.Parameters["@AuditRunId"].Value = $runid
            $Command.Parameters.Add("@StatusCode", [System.Data.SqlDbType]"nvarchar")
            $Command.Parameters["@StatusCode"].Value ="SUCCESS"
            $Command.ExecuteNonQuery();
        }
        elseif($EndStatus -eq $false)
        {
            $Command = new-Object System.Data.SqlClient.SqlCommand("[EndAuditRun]", $Conn)
            $Command.CommandType = [System.Data.CommandType]'StoredProcedure'
            $Command.Parameters.Add("@AuditRunId", [System.Data.SqlDbType]"int")
            $Command.Parameters["@AuditRunId"].Value = $runid
            $Command.ExecuteNonQuery();
        }


    }
    }
$conn.close();


     $OutputObj = New-Object PsObject;
        $OutputObj | Add-Member NoteProperty runid $runid;
    return $OutputObj;
