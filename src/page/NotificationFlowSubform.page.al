page 83011 "Notification Flow Subform"
{
    Caption = 'Notification Flow Subform';
    AutoSplitKey = true;
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "Notification flow line";
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Range Name"; Rec."Range Name")
                {
                    ToolTip = 'Specifies the value of the Range Name field.', Comment = '%';
                }
                field("Notification Group"; Rec."Notification Group")
                {
                    ToolTip = 'Specifies the value of the Notification Group field.', Comment = '%';
                }
                field("Notification Recipient Type"; Rec."Notification Recipient Type")
                {
                    ToolTip = 'Specifies the value of the Notification Recipient Type field.', Comment = '%';
                    Enabled = Rec."Notification Group" = Rec."Notification Group"::"Field Group";
                }
                field("Field ID"; Rec."Field ID")
                {
                    ToolTip = 'Specifies the value of the Field ID field.', Comment = '%';
                    Enabled = Rec."Notification Group" = Rec."Notification Group"::"Field Group";
                }
                field("Recipient Groups"; Rec."Recipient Code")
                {
                    ToolTip = 'Specifies the value of the Recipient Groups field.', Comment = '%';
                    Enabled = Rec."Notification Group" = Rec."Notification Group"::"Recipient Group";
                }
                field("Start Date"; Rec."Start Range")
                {
                    ToolTip = 'Specifies the value of the Start Date field.', Comment = '%';
                    // Visible = RangeVisibility;
                }
                field("End Date"; Rec."End Range")
                {
                    ToolTip = 'Specifies the value of the End Date field.', Comment = '%';
                    //Visible = RangeVisibility;
                }
                field(Frequency; Rec.Frequency)
                {
                    ToolTip = 'Specifies the value of the Frequency field.', Comment = '%';
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Set Layout")
            {
                Caption = 'Mail Body';
                Image = Report;
                Scope = Repeater;
                ApplicationArea = All;
                Enabled = this.MailBodyEditable;
                RunObject = page "Report Selection - Notif";
                RunPageLink = "Notification No." = field("No."), "Notification Line No." = field("Line No.");
            }
            action(NotificationSubject)
            {
                ApplicationArea = all;
                Caption = 'Notification Subject';
                Image = Email;
                Enabled = this.MailBodyEditable;
                Scope = Repeater;
                RunObject = page "Notification Subject page";
                RunPageLink = "Notification No." = field("No."), "Table ID" = field("Table ID"), "Notification Line No." = field("Line No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        NotificationFlowHeaderL: Record "Notification Flow Header";
    begin
        MailBodyEditable := this.GetMailBodyEditable();
        NotificationFlowHeaderL.Reset();
        if NotificationFlowHeaderL.Get(Rec."No.") then
            RangeVisibility := NotificationFlowHeaderL."Field Type" = NotificationFlowHeaderL."Field Type"::Date;
    end;

    local procedure GetMailBodyEditable(): Boolean
    var
        FlowHeader: Record "Notification Flow Header";
    begin
        FlowHeader.Get(Rec."No.");
        exit(not FlowHeader.Active);
    end;

    var
        RangeVisibility: Boolean;
        MailBodyEditable: Boolean;
}