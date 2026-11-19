table 83021 "Business Notification Setup"
{
    Caption = 'Business Notification Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; code[20])
        {
            Caption = ' ';
        }
        field(2; "Start Time"; Time)
        {
            Caption = 'Start Time';
        }
        field(3; "End Time"; Time)
        {
            Caption = 'End Time';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
