table 83022 "Notification Subject Line"
{
    Caption = 'Notification Subject Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Notification No."; Code[20])
        {
            Caption = 'Notification No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(4; "Field ID"; Integer)
        {
            Caption = 'Field No.';
            trigger OnLookup()
            var
                FieldRec: Record Field;
                NotificationSubjectLine: Record "Notification Subject Line";
            begin
                FieldRec.SetRange(TableNo, "Table ID");
                if page.RunModal(Page::"Fields Lookup", FieldRec) in [Action::LookupOK, Action::OK] then begin
                    Rec.Validate("Field Name", FieldRec.FieldName);
                    Rec.Validate("Field ID", FieldRec."No.");
                    NotificationSubjectLine.SetRange("Notification No.", Rec."Notification No.");
                    NotificationSubjectLine.SetRange("Table ID", Rec."Table ID");
                    NotificationSubjectLine.SetRange("Notification Line No.", Rec."Notification Line No.");
                    if NotificationSubjectLine.FindLast() then
                        Rec.Validate("Sequence No.", NotificationSubjectLine."Sequence No." + 1)
                    else
                        Rec.Validate("Sequence No.", 1);
                end;
            end;

            trigger OnValidate()
            var
                NotificationSubjectLine: Record "Notification Subject Line";
                FieldAlreadyExistErr: Label 'Field %1 Already Exists', Locked = true;
            begin
                NotificationSubjectLine.SetRange("Notification No.", Rec."Notification No.");
                NotificationSubjectLine.SetRange("Table ID", Rec."Table ID");
                NotificationSubjectLine.SetRange("Field ID", Rec."Field ID");
                NotificationSubjectLine.SetRange("Notification Line No.", Rec."Notification Line No.");
                NotificationSubjectLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
                if not NotificationSubjectLine.FindFirst() then
                    exit;
                Error(FieldAlreadyExistErr, Rec."Field Name");
            end;
        }
        field(5; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            Editable = false;
        }
        field(6; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            MinValue = 1;
            Editable = false;
        }
        field(7; "Notification Line No."; Integer)
        {
            Caption = 'Notification Line No.';
        }
    }
    keys
    {
        key(PK; "Notification No.", "Table ID", "Notification Line No.", "Line No.")
        {
            Clustered = true;
        }
        key(SK; "Sequence No.") { }
    }
}