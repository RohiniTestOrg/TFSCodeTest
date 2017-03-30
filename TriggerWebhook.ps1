<#  
    .NAME
        TriggerWebhook
  
    .SYNOPSIS  
        It will trigger the webhook url and update the database with azurejobid and job status

    .DESCRIPTION
        This Function called after clicking submit button in web application of portal.
            it will trigger webhook url,it will automatically call azure runbook.
	    Connect to azure portal using login-azurermaccount, will authenticate us by prompting one form.
	    retrieve the job status and update table auditrun.

    .NOTES  
        
    .EXAMPLE

        .\TriggerWebhook.ps1 -AuditType "AuditDotNetVersion" -InputFilepath "xml of blob url "
         
    .OUTPUTS
       it will send  all the results to webapplicaton result box.
	#>






[CmdletBinding()]
    Param(
        [Parameter(Position=0, Mandatory=$true, HelpMessage="xml file path")]
        [string]$AuditType,
        [Parameter(Position=1, Mandatory=$true, HelpMessage="input file path")]
        [string]$InputFilepath)

#$AuditType="AuditDotNetVersion"
#$InputFilepath="https://smdbsourcetest.blob.core.windows.net/auditdotnetversion/corp_10_.XML"

#Get current date
$date = Get-Date
$uri = "https://s5events.azure-automation.net/webhooks?token=SO4TYgMIWGml1dq2vkMXJ6yW3IGKqsvr8sI2x24VXkc%3d";
$headers = @{
    'From' = "$env:USERNAME"
    'Date' = "$date"
}

$XmlFile  =@(
            @{ Name=$AuditType;
            xmlfilepath=$InputFilepath}
           
        )
$body = ConvertTo-Json -InputObject $XmlFile
$result=Invoke-WebRequest -method Post -Uri $uri -Headers $headers -Body $body 
$jobid=(ConvertFrom-Json ($result.Content)).jobids[0]

$WebhookStattusCode = "The Status code is $($result.StatusCode)"
$WebhookStattusCode | Out-String;
$WebhookStattusDescription= "The Status Description is $($result.StatusDescription)"
$WebhookStattusDescription | Out-String;
$webhookjobid= "Job id is $($jobid)"
$webhookjobid | Out-String;
#https://smdbsourcetest.blob.core.windows.net/auditdotnetversion/corp_10_.XML

#login to portal
$login=Login-AzureRmAccount -SubscriptionId “4c0bb932-99d0-41ad-a95b-263414adcce3”  -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"

$auditrunid=$null;

:Lable while($auditrunid.count -ne 1)
{
    #trying to get audit runid from azure output 
    $out=Get-AzureRmAutomationJobOutput -ResourceGroupName "nonprod" –AutomationAccountName "EZpatch" -Id $jobid –Stream Output

    $res=$out | where-object {$_.summary -match "Audit Runid"} | select summary
    
    if(-not($res))
    {
        continue Lable;
    }
    else
    {
    $auditrunid=$res.Summary.split(" ")[-1]
   
    break;}
}
 
#get the azure job status untill it got completed.
do{
    $StatusResult= Get-AzureRmAutomationJob -Id $jobid -ResourceGroupName nonprod -AutomationAccountName EZpatch 
    $JobStatus=$StatusResult.Status
    $RptSQLServer = "patchsqldb.database.windows.net";
    $RptSQLDB = "EZ_Automation_Development"

    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString ="Server=$RptSQLServer;Database=$RptSQLDB;Authentication=Active Directory Integrated;Encrypt=True;TrustServerCertificate=False;" 
    $Conn.Open()
     $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
     $SqlCmd.Connection = $Conn;
     $insert_stmt = "UPDATE AuditRun
    SET AzureJobID = '$jobid' , AzureJobStatus='$JobStatus'
    WHERE AuditRunID = '$auditrunid'"
            $SqlCmd.CommandText =$insert_stmt ;
            $cmdtxt=$SqlCmd. CommandText;
            #$exec=$SqlCmd.ExecuteNonQuery();
            $wid= $SqlCmd.ExecuteNonQuery();
            Start-Sleep -Seconds 2
   }
   while($StatusResult.Status -ne "Completed") 
   



#getting results from table and writing to web application.
     $Msg= "The Current Audit details are "
    $Msg | Out-String;

    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.Connection = $Conn;
    $insert_stmt1 = "Select * from AuditRun where AuditRunID =$auditrunid"
    $SqlCmd.CommandText =$insert_stmt1 ;
    $cmdtxt=$SqlCmd. CommandText;
    #$exec=$SqlCmd.ExecuteNonQuery();
    $finalResult= $SqlCmd.ExecuteReader();
    $table = new-object “System.Data.DataTable”
    $table.Load($finalResult);
    $table | Out-String