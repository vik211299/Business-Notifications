page 83012 "Notification Queue List"
{
    ApplicationArea = All;
    Caption = 'Notification Queue List';
    PageType = List;
    SourceTable = "Notification Queue";
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    Editable = true;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Notification Workflow Code"; Rec."Notification Workflow Code")
                {
                    ToolTip = 'Specifies the value of the Notification Workflow Code field.', Comment = '%';
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Range Name"; Rec."Range Name")
                {
                    ToolTip = 'Specifies the value of the Range Name field.';
                }
                field("Record ID"; this.RecordIDText)
                {
                    ToolTip = 'Specifies the value of the Record ID field.';
                }
                field("User Group"; Rec."User Group")
                {
                    ToolTip = 'Specifies the value of the User Group field.', Comment = '%';
                }
                field("Mail Scheduled DateTime"; Rec."Mail Scheduled DateTime")
                {
                    ToolTip = 'Specifies the value of the Mail Scheduled DateTime field.';
                }
                field("Has Error"; Rec."Has Error")
                {
                    ToolTip = 'Specifies the value of the Has Error field.';
                }
                field("Notification Recipient Type"; Rec."Notification Recipient Type")
                {
                    ToolTip = 'Specifies the value of the Notification Recipient Type field.';
                }
                field("Field Value"; Rec."Notification Recipient")
                {
                    ToolTip = 'Specifies the value of the Field Value field.';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(ViewErrorMessageActionRef; ViewErrorMessage)
            {

            }
        }
        area(Navigation)
        {
            action(ViewErrorMessage)
            {
                Caption = 'View Error Message';
                Image = View;
                ToolTip = 'View the Error Message for the Notification Queue.';
                trigger OnAction()
                begin
                    if Rec."Has Error" then
                        Page.RunModal(Page::"Notification Error Display", Rec)
                    else
                        Message('No Error Message Found');
                end;

            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        this.GetRecordIDText();
    end;

    local procedure GetRecordIDText(): Text
    begin
        this.RecordIDText := Format(Rec."Record Id");
    end;

    var
        RecordIDText: Text;
}