page 83010 "Notification Flow List"
{
    ApplicationArea = All;
    Caption = 'Notification Flow List';
    PageType = List;
    SourceTable = "Notification Flow Header";
    UsageCategory = Lists;
    InsertAllowed = true;
    Editable = false;
    DeleteAllowed = true;
    ShowFilter = true;
    LinksAllowed = true;
    CardPageId = "Notification Flow Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field.', Comment = '%';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the value of the Table Name field.', Comment = '%';
                }
                field("Field ID"; Rec."Field ID")
                {
                    ToolTip = 'Specifies the value of the Field ID field.', Comment = '%';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ToolTip = 'Specifies the value of the Field Name field.', Comment = '%';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ToolTip = 'Specifies the value of the Field Type field.', Comment = '%';
                }
                field("Field Threshold"; Rec."Field Threshold")
                {
                    ToolTip = 'Specifies the value of the Field Threshold field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Process)
            {
                actionref(EnableNotificationFlow; "Activate Notification Flow")
                {
                }
                actionref(DisableNotificationFlow; "Deactivate Notification Flow")
                {
                }

            }
        }
        area(Processing)
        {
            action("Activate Notification Flow")
            {
                Image = Approve;
                ToolTip = 'Activates Notification Flow';
                Enabled = not Rec.Active;
                Visible = not Rec.Active;
                trigger OnAction()
                var
                    BusinessNotificationMgmt: Codeunit "Business Notification Mgmt.";
                begin
                    BusinessNotificationMgmt.ActivateNotificationFlow(Rec);
                end;
            }
            action("Deactivate Notification Flow")
            {
                Image = Reject;
                ToolTip = 'Deactivates Notification Flow';
                Enabled = Rec.Active;
                Visible = Rec.Active;
                trigger OnAction()
                var
                    BusinessNotificationMgmt: Codeunit "Business Notification Mgmt.";
                begin
                    BusinessNotificationMgmt.DeactivateNotificationFlow(Rec);
                end;
            }
        }
    }

}
