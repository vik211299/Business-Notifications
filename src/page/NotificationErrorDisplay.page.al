page 83008 "Notification Error Display"
{
    ApplicationArea = All;
    Caption = 'Notification Error Display';
    PageType = Card;
    SourceTable = "Notification Queue";
    UsageCategory = None;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    DataCaptionExpression = Rec."Notification Workflow Code" + ' - ' + Rec."User Group" + ' - ' + Rec."Range Name";

    layout
    {
        area(Content)
        {
            group(ErrorCodeGroup)
            {
                Caption = 'Error Code';
                field(ErrorCode; this.ErrorCode)
                {
                    ShowCaption = false;
                    Caption = 'Error Code';
                    ToolTip = 'Specifies the value of the Error Code field.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    Editable = false;
                }
            }
            group(ErrorTextGroup)
            {
                Caption = 'Error Text';
                field(ErrorText; this.ErrorText)
                {
                    ShowCaption = false;
                    Caption = 'Error Text';
                    ToolTip = 'Specifies the value of the Error Text field.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    Editable = false;
                }
            }
            group(ErrorCallStackGroup)
            {
                Caption = 'Error Call Stack';
                field(ErrorCallStack; this.ErrorCallStack)
                {
                    ShowCaption = false;
                    Caption = 'Error Call Stack';
                    ToolTip = 'Specifies the value of the Error Call Stack field.';
                    MultiLine = true;
                    ExtendedDatatype = RichContent;
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var

        InStream: InStream;
    begin
        Rec.CalcFields("Error Message Code", "Error Message Text", "Error Call Stack");
        Rec."Error Message Code".CreateInStream(InStream);
        InStream.ReadText(this.ErrorCode);
        Clear(InStream);
        Rec."Error Message Text".CreateInStream(InStream);
        InStream.ReadText(this.ErrorText);
        Clear(InStream);
        Rec."Error Call Stack".CreateInStream(InStream);
        InStream.ReadText(this.ErrorCallStack);
    end;

    var
        ErrorCode: Text;
        ErrorText: Text;
        ErrorCallStack: Text;
}
