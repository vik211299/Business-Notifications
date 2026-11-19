table 83016 "Notification Flow Header"
{
    Caption = 'Notifcation Flows';
    DataClassification = CustomerContent;
    LookupPageId = "Notification Flow List";
    DrillDownPageId = "Notification Flow Card";
    DataCaptionFields = Name;

    fields
    {
        field(1; "No."; Code[20])
        {
            NotBlank = true;
        }
        field(2; "Name"; Text[50])
        {
        }
        field(3; "Table ID"; Integer)
        {
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = filter(Table));
        }
        field(4; "Table Name"; Text[30])
        {
            Editable = false;
        }
        field(5; "Field ID"; Integer)
        {
            Editable = true;
            TableRelation = Field."No." where(TableNo = field("Table ID"), Type = filter(Date | Integer | Decimal));
            trigger OnLookup()
            var
                FieldRec: Record Field;
            begin
                FieldRec.SetRange(TableNo, "Table ID");
                FieldRec.SetFilter(Type, '%1|%2|%3', FieldRec.Type::Date, FieldRec.Type::Integer, FieldRec.Type::Decimal);
                if page.RunModal(Page::"Fields Lookup", FieldRec) in [Action::LookupOK, Action::OK] then
                    Rec.Validate("Field ID", FieldRec."No.");
            end;
        }
        field(6; "Field Name"; Text[30])
        {
            Caption = 'Field Name';

        }
        field(7; "Field Type"; Option)
        {
            OptionMembers = TableFilter,RecordID,OemText,Date,Time,DateFormula,Decimal,Media,MediaSet,Text,Code,Binary,BLOB,Boolean,Integer,OemCode,Option,BigInteger,Duration,GUID,DateTime;
            OptionCaption = ',,,Date,,,,Decimal,,,,,,,,Integer,,,,,,';
            Editable = false;
        }
        field(8; "Field Threshold"; Decimal)
        {
        }
        field(10; Active; Boolean)
        {
            Editable = false;
        }
        field(11; Header; Text[250])
        {
        }
        field(12; Footer; Text[250])
        {
        }
        field(13; "Page ID"; Integer)
        {
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = filter(Page));
        }
        field(14; "Filter Blob"; Blob)
        {
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ReportSelectionNotf: Record "Report Selections-Notif";
        Notificationque: Record "Notification Queue";
        Notificationflowline: Record "Notification Flow Line";
    begin
        ReportSelectionNotf.SetRange("Notification No.", Rec."No.");
        ReportSelectionNotf.DeleteAll();

        Notificationque.SetRange("Notification Workflow Code", Rec."No.");
        Notificationque.DeleteAll();

        Notificationflowline.SetRange("No.", Rec."No.");
        Notificationflowline.DeleteAll();


    end;
}
