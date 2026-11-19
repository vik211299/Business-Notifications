page 83015 "Notification Recipient Subform"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Notification Recipient Subform';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Notification Recipient Line";
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Notification Recipient Type field.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Name; Rec.Name)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the E-Mail field.';
                }
            }
        }
    }
}