page 83006 "Notification Subject page"
{
    ApplicationArea = All;
    Caption = 'Notification Subject page';
    PageType = List;
    SourceTable = "Notification Subject Line";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Field ID"; Rec."Field ID")
                {
                    ToolTip = 'Specifies the value of the Field No. field.', Comment = '%';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ToolTip = 'Specifies the value of the Field Name field.', Comment = '%';
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ToolTip = 'Specifies the value of the Sequence No. field.', Comment = '%';
                }
            }
        }
    }
}
