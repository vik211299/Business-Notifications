table 83019 "Notification Recipient Header"
{
    DataClassification = CustomerContent;
    Caption = 'Notification Recipient Header';
    LookupPageId = "Notification Recipient List";
    DrillDownPageId = "Notification Recipient Card";

    fields
    {
        field(1; Code; code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; Status; Enum "Notification Flow Status")
        {
            Caption = 'Status';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}