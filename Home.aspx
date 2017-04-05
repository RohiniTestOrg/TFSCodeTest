<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="AzureAuditsPoc.Home" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .auto-style3 {
            height: 54px;
            width: 842px;
            margin-left: 40px;
        }
        .auto-style5 {
            height: 54px;
        }
        .auto-style7 {
            height: 365px;
            width: 900px;
            margin-top: 30px;
        }
        .auto-style8 {
            margin-left: 265px;
        }
        .auto-style9 {
            margin-left: 71px;
            }
        .auto-style10 {
            margin-left: 80px;
            height: 35px;
            width: 842px;
        }
        .auto-style11 {
            margin-left: 77px;
            margin-top: 17px;
        }
        .auto-style12 {
            width: 842px;
        }
        .auto-style13 {
            margin-left: 17px;
        }
        .auto-style14 {
            height: 63px;
        }
        .auto-style15 {
            height: 54px;
            width: 6px;
        }
        </style>
</head>
<body >
    <form id="form1" runat="server" >
    <div>
    <table  border="0" cellpadding="0" cellspacing="0" class="auto-style7" style="margin-left: 175px; ">
    <tr>
        <th colspan="3" class="auto-style14" >
            AzureAudits 
        </th>
    </tr>
        <tr>
             <td class="auto-style10">
                    Select AuditType<asp:DropDownList ID="ddlAuditTypeDropDown" runat="server" Width="505px"
                    AutoPostBack="True"
                     CssClass="auto-style9" Height="26px" OnSelectedIndexChanged="ddlAuditTypeDropDown_SelectedIndexChanged" DataSourceID="AzurePatchDB" DataTextField="WorkflowName" DataValueField="WorkflowName">
            </asp:DropDownList>
                    <asp:SqlDataSource ID="AzurePatchDB" runat="server" ConnectionString="<%$ ConnectionStrings:EZ_Automation_DevelopmentConnectionString %>" SelectCommand="SELECT [WorkflowName] FROM [WorkflowType]"></asp:SqlDataSource>
                </td>

        </tr>
        <tr>
                <td class="auto-style10">
                    Select Your Xml<asp:DropDownList ID="ddlAuditxmls" runat="server" Width="503px"  OnSelectedIndexChanged="Auditxmls_SelectedIndexChanged" CssClass="auto-style11" Height="26px">
                <asp:ListItem Text="Select Your XmlFile" Value="0"></asp:ListItem>
            </asp:DropDownList></td></tr>
        <td class="auto-style3">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Label ID="lblinputfilepath" runat="server" Text="InputFilesPath"></asp:Label>
                      &nbsp;<asp:TextBox ID="txtinputfilepath" runat="server" Width="413px" CssClass="auto-style13" />
            <br />
            <br />
           <asp:Button ID="btnSubmit" Text="Submit" runat="server" OnClick="btnSubmit_Click" Width="200px" CssClass="auto-style8" Height="27px" backcolor="pink"/>
        </td>
        <td class="auto-style15">
            <br />
            <br />
            <br />
            <br />
            <br />
            </td>
        <td class="auto-style5">
            </td>
    </tr>

        <tr><td class="auto-style12">
                  <asp:TextBox ID="ResultBox" TextMode="MultiLine" Width=708px Height=218px  runat="server" style="margin-top: 0px"></asp:TextBox>
                 
              </td>

        </tr>
        </table>
    </div>
    </form>
</body>
</html>

