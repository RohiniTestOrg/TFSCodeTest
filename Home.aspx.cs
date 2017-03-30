using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Text;
using System.Collections.ObjectModel;
using Microsoft.Azure; // Namespace for CloudConfigurationManager
using Microsoft.WindowsAzure.Storage; // Namespace for CloudStorageAccount
using Microsoft.WindowsAzure.Storage.Blob; // Namespace for Blob storage types


namespace AzureAuditsPoc
{
    public partial class Home : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ddlAuditTypeDropDown_SelectedIndexChanged(object sender, EventArgs e)
        {
            //StringBuilder builder = new StringBuilder();
            var option = ddlAuditTypeDropDown.SelectedValue.ToLower();
            List<System.Uri> list = new List<System.Uri>();
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(
            CloudConfigurationManager.GetSetting("StorageConnectionString"));
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();
            CloudBlobContainer container = blobClient.GetContainerReference(option);
            foreach (IListBlobItem item in container.ListBlobs(null, false))
            {
                if (item.GetType() == typeof(CloudBlockBlob))
                {
                    CloudBlockBlob blob = (CloudBlockBlob)item;
                    list.Add(blob.Uri);
                    //Console.WriteLine("Block blob of length {0}: {1}", blob.Properties.Length, blob.Uri);

                }
            }
           // var result = Server.HtmlEncode(builder.ToString());
            if (list.Count > 0)
            {
                ddlAuditxmls.DataSource = list;
                ddlAuditxmls.DataBind();
            }

            //var list = container.ListBlobs();
            //var xml = list.Uri.Segments[2];


            /*
                // Clean the Result TextBox
                ResultBox.Text = string.Empty;

                Runspace rs = RunspaceFactory.CreateRunspace();
                rs.Open();


                PowerShell shell = PowerShell.Create();
                shell.Runspace = rs;

                RunspaceInvoke runSpaceInvoker = new RunspaceInvoke(rs);
                Pipeline pipeLine = rs.CreatePipeline();

            Command myCommand = new Command(@"C:\Users\v-venkis\Desktop\Blobinfo.ps1");
            //Command myCommand = new Command(@"https://smdbsourcetest.blob.core.windows.net/smdbsource/Blobinfo.ps1");
             
            var option = ddlAuditTypeDropDown.SelectedValue.ToLower();
                CommandParameter testParam = new CommandParameter("ContainerName", option);
                myCommand.Parameters.Add(testParam);



                // Command myCommand = new Command(@"C:\Users\v-venkis\Desktop\Blobinfo.ps1");
                pipeLine.Commands.Add(myCommand);
                var results = pipeLine.Invoke();
                if (results.Count > 0)
                {
                    ddlAuditxmls.DataSource = results;
                    ddlAuditxmls.DataBind();
                }
                */
        }



        protected void btnSubmit_Click(object sender, EventArgs e)
        {

            string value = (ddlAuditTypeDropDown.SelectedItem).ToString();
            var option = ddlAuditxmls.SelectedValue;
            System.Web.UI.WebControls.ListItem xml = ddlAuditxmls.Items.FindByText(option);
            using (PowerShell PowerShellInstance = PowerShell.Create())
            {
                PowerShellInstance.AddScript("param($param1,$param2)  $date = Get-Date; $uri ='https://s5events.azure-automation.net/webhooks?token=SO4TYgMIWGml1dq2vkMXJ6yW3IGKqsvr8sI2x24VXkc%3d';" +
"$headers = @{'From'='$env:USERNAME';'Date' = $date};$XmlFile =@( @{Name=$param1;xmlfilepath= $param2});" +
"$body=ConvertTo-Json -InputObject $XmlFile;$result = Invoke-WebRequest -method Post -Uri $uri -Headers $headers -Body $body;$statuscode=$result.StatusCode; $jobid = (ConvertFrom-Json($result.Content)).jobids[0];write-output 'The Status code is' $statuscode; write-output 'The Status Description is' ($result.StatusDescription);write-output 'Job id is' ($jobid)");
                /*   PowerShellInstance.AddScript("param($param1,$param2)  $date = Get-Date; $uri ='https://s5events.azure-automation.net/webhooks?token=SO4TYgMIWGml1dq2vkMXJ6yW3IGKqsvr8sI2x24VXkc%3d';" +
   "$headers = @{'From'='$env:USERNAME';'Date' = $date};$XmlFile =@( @{Name=$param1;xmlfilepath= $param2});"+
   "$body=ConvertTo-Json -InputObject $XmlFile;$result = Invoke-WebRequest -method Post -Uri $uri -Headers $headers -Body $body;$statuscode=$result.StatusCode; $jobid = (ConvertFrom-Json($result.Content)).jobids[0];write-output 'The Status code is' $statuscode; write-output 'The Status Description is' ($result.StatusDescription);write-output 'Job id is' ($jobid);"+
   "$login=Login-AzureRmAccount -SubscriptionId “4c0bb932-99d0-41ad-a95b-263414adcce3” -TenantId '72f988bf-86f1-41af-91ab-2d7cd011db47';$auditrunid=$null;"+
   ":Lable while($auditrunid.count -ne 1){$out= Get-AzureRmAutomationJobOutput -ResourceGroupName 'nonprod' –AutomationAccountName 'EZpatch' -Id $jobid –Stream Output;$res =$out|where-object{$_.summary -match 'Audit Runid'} | select summary;$res;if (-not($res)){continue Lable;}else{$auditrunid =$res.Summary.split(' ')[-1];break;}}" +
   "do{$StatusResult = Get-AzureRmAutomationJob -Id $jobid -ResourceGroupName nonprod -AutomationAccountName EZpatch; $JobStatus=$StatusResult.Status;$RptSQLServer = 'patchsqldb.database.windows.net';$RptSQLDB = 'EZ_Automation_Development';"+
     " $conn = New-Object System.Data.SqlClient.SqlConnection"+
      "$conn.ConnectionString = 'Server=$RptSQLServer;Database=$RptSQLDB;Authentication=Active Directory Integrated;Encrypt=True;TrustServerCertificate=False;' "+
       "$Conn.Open();$SqlCmd = New-Object System.Data.SqlClient.SqlCommand;$SqlCmd.Connection=$Conn;$insert_stmt = 'UPDATE AuditRun SET AzureJobID =$jobid,AzureJobStatus =$JobStatus WHERE AuditRunID=$auditrunid';$SqlCmd.CommandText =$insert_stmt;"+
       "$cmdtxt =$SqlCmd.CommandText;$wid=$SqlCmd.ExecuteNonQuery();Start-Sleep -Seconds 1;}while($StatusResult.Status -ne 'Completed');"+ 
       "$SqlCmd = New-Object System.Data.SqlClient.SqlCommand"+
       "$SqlCmd.Connection = $Conn;"+
       "$insert_stmt1 = 'Select * from AuditRun where AuditRunID =$auditrunid';" +
       "$SqlCmd.CommandText =$insert_stmt1;"+
       "$cmdtxt =$SqlCmd.CommandText;"+
       "$finalResult = $SqlCmd.ExecuteReader();"+
       "$table = new-object “System.Data.DataTable” "+
       "$table.Load($finalResult);"+
       "write-output 'The current audit results are' $table;");
       */

                // use "AddParameter" to add a single parameter to the last command/script on the pipeline.
                PowerShellInstance.AddParameter("param1", value);
                
                //PowerShellInstance.AddScript("param($param1) $d = get-date; $s = 'test string value'; " +
              // "$d; $s; $param1;write-output 'This is'+$param1"+" get-service");

                // use "AddParameter" to add a single parameter to the last command/script on the pipeline.
               // PowerShellInstance.AddParameter("param1", "Venkatesh Kistam");

                PowerShellInstance.AddParameter("param2", xml.Value);
                Runspace rs1 = RunspaceFactory.CreateRunspace();
                rs1.Open();
                // use "AddParameter" to add a single parameter to the last command/script on the pipeline.
                // PowerShellInstance.AddParameter("AuditType", value);
                // PowerShellInstance.AddParameter("InputFilepath", xml.Value);
               
                Collection<PSObject> PSOutput = PowerShellInstance.Invoke();
                var builder = new StringBuilder();
                foreach (PSObject outputItem in PSOutput)
                {
                    
                    if (outputItem != null)
                    {
                        builder.Append(outputItem.ToString() + "\r\n");
                    }
                }
                ResultBox.Text = Server.HtmlEncode(builder.ToString());
            }
/*
            string value = (ddlAuditTypeDropDown.SelectedItem).ToString();

         
            if (value == "AuditDotNetVersion")
            {
            
                
                ResultBox.Text = string.Empty;

                Runspace rs1 = RunspaceFactory.CreateRunspace();
                rs1.Open();


                PowerShell shell1 = PowerShell.Create();
                shell1.Runspace = rs1;

                RunspaceInvoke runSpaceInvoker1 = new RunspaceInvoke(rs1);
                Pipeline pipeLine1 = rs1.CreatePipeline();
              //  var option = ddlAuditxmls.SelectedValue;
               //  System.Web.UI.WebControls.ListItem xml = ddlAuditxmls.Items.FindByText(option);
                string cmd123 = @"
                $date = Get-Date
$uri = ""https://s5events.azure-automation.net/webhooks?token=SO4TYgMIWGml1dq2vkMXJ6yW3IGKqsvr8sI2x24VXkc%3d"";
$headers = @{
    'From' = ""$env:USERNAME""
    'Date' = ""$date""
}

$XmlFile  =@(
            @{Name=""Value"";
            xmlfilepath=""xml.value""}
           
        )
$body = ConvertTo-Json -InputObject $XmlFile
$result=Invoke-WebRequest -method Post -Uri $uri -Headers $headers -Body $body 
$jobid=(ConvertFrom-Json ($result.Content)).jobids[0]

$WebhookStattusCode = ""The Status code is $($result.StatusCode)""
$WebhookStattusCode | Out-String;
$WebhookStattusDescription = ""The Status Description is $($result.StatusDescription)""
$WebhookStattusDescription | Out-String;
$webhookjobid = ""Job id is $($jobid)""
$webhookjobid | Out-String; -argument
                ";
                /* Command myCommand1 = new Command(@"https://smdbsourcetest.blob.core.windows.net/powersehllscripts/TriggerWebhook.ps1");

                 CommandParameter testParam1 = new CommandParameter("AuditType", value);
                 var option = ddlAuditxmls.SelectedValue;
                 CommandParameter testParam2 = new CommandParameter("InputFilepath", ddlAuditxmls.Items.FindByText(option));
                 myCommand1.Parameters.Add(testParam1);
                 myCommand1.Parameters.Add(testParam2);
                 
                pipeLine1.Commands.AddScript(cmd123);
                
                try
                {
                    var results = pipeLine1.Invoke();

                    if (results.Count > 0)
                    {
                        // We use a string builder ton create our result text
                        var builder = new StringBuilder();

                        foreach (var psObject in results)
                        {
                            // Convert the Base Object to a string and append it to the string builder.
                            // Add \r\n for line breaks
                            builder.Append(psObject.BaseObject.ToString() + "\r\n");
                        }

                        // Encode the string in HTML (prevent security issue with 'dangerous' caracters like < >
                        ResultBox.Text = Server.HtmlEncode(builder.ToString());


                    }
                }



                catch (Exception ex)
                {
                    Console.WriteLine("An error occured: " + ex.Message);
                }
                finally
                {
                    pipeLine1.Stop();

                    rs1.Close();
                }
               
            }


            else if (value == "GenericAudit")
            {
                // Clean the Result TextBox
                ResultBox.Text = string.Empty;

                Runspace rs = RunspaceFactory.CreateRunspace();
                rs.Open();


                PowerShell shell = PowerShell.Create();
                shell.Runspace = rs;

                RunspaceInvoke runSpaceInvoker = new RunspaceInvoke(rs);
                Pipeline pipeLine = rs.CreatePipeline();

                Command myCommand = new Command(@"C:\Users\v-venkis\Desktop\Webhookcall.ps1");
                var option = ddlAuditxmls.SelectedValue;
                CommandParameter testParam = new CommandParameter("xmlfilepath", ddlAuditxmls.Items.FindByText(option));
                myCommand.Parameters.Add(testParam);

                pipeLine.Commands.Add(myCommand);

                try
                {
                    var results1 = pipeLine.Invoke();

                    if (results1.Count > 0)
                    {
                        // We use a string builder ton create our result text
                        var builder = new StringBuilder();

                        foreach (var psObject in results1)
                        {
                            // Convert the Base Object to a string and append it to the string builder.
                            // Add \r\n for line breaks
                            builder.Append(psObject.BaseObject.ToString() + "\r\n");
                        }

                        // Encode the string in HTML (prevent security issue with 'dangerous' caracters like < >
                        ResultBox.Text = Server.HtmlEncode(builder.ToString());


                    }
                }



                catch (Exception ex)
                {
                    Console.WriteLine("An error occured: " + ex.Message);
                }
                finally
                {
                    pipeLine.Stop();

                    rs.Close();
                }
            }
            
    */
        }
    

        protected void Auditxmls_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}