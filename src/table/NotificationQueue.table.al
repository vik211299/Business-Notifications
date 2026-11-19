table 83018 "Notification Queue"
{
    Caption = 'Notification Queue';
    DataClassification = CustomerContent;
    LookupPageId = "Notification Queue List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Editable = false;
        }
        field(2; "Notification Workflow Code"; Code[20])
        {
            TableRelation = "Notification Flow Header"."No.";
            Editable = false;
        }
        field(4; "User Group"; Code[20])
        {
            TableRelation = "Notification Recipient Line";
        }
        field(5; Content; Text[50])
        {
            Editable = false;
        }
        field(7; "Line No."; Integer)
        {
            TableRelation = "Notification flow line"."Line No." where("No." = field("Notification Workflow Code"));
            Editable = false;
        }
        field(8; "Range Name"; Text[50])
        {
            TableRelation = "Notification flow line"."Range Name" where("No." = field("Notification Workflow Code"), "Line No." = field("Line No."));
            Editable = false;
        }
        field(10; "Mail Scheduled DateTime"; DateTime)
        {
            Caption = 'Mail Scheduled DateTime';
            Description = 'The date and time at which the mail should be sent';
            Editable = false;
        }
        field(11; "Table No."; Integer)
        {
            Caption = 'Table No.';
            Editable = false;
        }
        field(12; "Record Id"; RecordId)
        {
            Caption = 'Record Id';
            Editable = false;
            AllowInCustomizations = Never;
        }
        field(13; "Error Message Code"; Blob)
        {
            Caption = 'Error Message';
        }
        field(14; "Error Message Text"; Blob)
        {
            Caption = 'Error Message Text';
        }
        field(15; "Error Call Stack"; Blob)
        {
            Caption = 'Error Call Stack';
        }
        field(16; "Has Error"; Boolean)
        {
            Caption = 'Has Error';
            Editable = false;
        }
        field(17; "Notification Recipient Type"; Enum "Notification Recipient Type")
        {
            Caption = 'Notification Recipient Type';
        }
        field(18; "Notification Recipient"; Text[100])
        {
            Caption = 'Field Value';
            Editable = false;
        }
        field(19; "Notification Group"; Enum "Notification Group")
        {
            Editable = false;
        }
    }
    keys

    {
        key(PK; "Entry No.")

        {
            Clustered = true;
        }
    }
}
