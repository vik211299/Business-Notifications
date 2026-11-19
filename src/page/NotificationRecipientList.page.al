page 83014 "Notification Recipient List"
{
    CardPageID = "Notification Recipient Card";
    PageType = List;
    SourceTable = "Notification Recipient Header";
    UsageCategory = Lists;
    ApplicationArea = all;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;
    ShowFilter = true;
    LinksAllowed = true;
    Caption = 'Business Notification Recipient List';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(ActivateAction; Activate)
            {
            }
            actionref(DeactivateAction; Deactivate)
            {
            }
        }
        area(Processing)
        {
            action(Activate)
            {
                Caption = 'Activate';
                ToolTip = 'Activate the Notification Recipient Group';
                Image = Certificate;
                trigger OnAction()
                var
                    NotificationManagement: Codeunit "Business Notification Mgmt.";
                begin
                    NotificationManagement.ActivateNotificationRecipientGroup(Rec, true);
                end;
            }
            action(Deactivate)
            {
                Caption = 'Deactivate';
                ToolTip = 'Deactivate the Notification Recipient Group';
                Image = Cancel;
                trigger OnAction()
                var
                    NotificationManagement: Codeunit "Business Notification Mgmt.";
                begin
                    NotificationManagement.DeactivateNotificationRecipientGroup(Rec, true);
                end;
            }
        }
    }
}