page 83013 "Notification Recipient Card"
{
    ApplicationArea = All;
    Caption = 'Notification Recipient Card';
    Editable = true;
    PageType = Card;
    SourceTable = "Notification Recipient Header";
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = Rec.Status = Rec.Status::Open;
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
            part("NotificationRecipientSubform"; "Notification Recipient Subform")
            {
                Editable = Rec.Status = Rec.Status::Open;
                Caption = 'Notification Recipient Subform';
                SubPageLink = Code = field(Code);
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
                    CurrPage.Editable(false);
                    CurrPage.Update(true);
                end;
            }
        }
    }
}