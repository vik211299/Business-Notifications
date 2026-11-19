table 83017 "Notification flow line"
{
    Caption = 'Notification flow line';
    DataClassification = CustomerContent;
    LookupPageId = "Notification Flow Subform";

    fields
    {
        field(1; "No."; Code[20])
        {
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Editable = false;
        }
        field(3; "Range Name"; Text[50])
        {
            Caption = 'Range Name';
        }
        field(5; "Recipient Code"; Code[20])
        {
            Caption = 'Recipient';
            TableRelation = "Notification Recipient Header".Code where(Status = filter(Certified));
        }
        field(6; Frequency; Integer)
        {
            Caption = 'Frequency';
            MinValue = 0;
        }
        field(7; Content; Text[50])
        {
            Caption = 'Content';
        }
        field(8; "Start Range"; Integer)
        {
            Caption = 'Start Range';
        }
        field(9; "End Range"; Integer)
        {
            Caption = 'End Range';
        }
        field(10; Active; Boolean)
        {
            Caption = 'Active';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Notification Flow Header".Active where("No." = field("No.")));
        }
        field(11; "Notification Group"; Enum "Notification Group")
        {
            Caption = 'Notification Group';
        }
        field(12; "Notification Recipient Type"; Enum "Notification Recipient Type")
        {
            Caption = 'Notification Recipient Type';
        }
        field(13; "Table ID"; Integer)
        {
            Editable = false;
        }
        field(14; "Field ID"; Integer)
        {
            Editable = true;
            TableRelation = Field."No." where(TableNo = field("Table ID"), Type = filter(Text | Code | GUID));
            trigger OnLookup()
            var
                FieldRec: Record Field;
            begin
                FieldRec.SetRange(TableNo, "Table ID");
                //FieldRec.SetFilter(Type, '%1|%2|%3', FieldRec.Type::Text, FieldRec.Type::Code, FieldRec.Type::GUID);
                if page.RunModal(Page::"Fields Lookup", FieldRec) in [Action::LookupOK, Action::OK] then
                    Rec.Validate("Field ID", FieldRec."No.");
            end;
        }

    }

    keys
    {
        key(PK; "No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ReportSelectionNotf: Record "Report Selections-Notif";
        Notificationque: Record "Notification Queue";
    begin
        ReportSelectionNotf.SetRange("Notification No.", Rec."No.");
        ReportSelectionNotf.SetRange("Notification Line No.", Rec."Line No.");
        ReportSelectionNotf.DeleteAll();

        Notificationque.SetRange("Notification Workflow Code", Rec."No.");
        Notificationque.SetRange("Line No.", Rec."Line No.");
        Notificationque.DeleteAll();


    end;

    trigger OnInsert()
    var
        NotificFlowHdr: Record "Notification Flow Header";
    begin
        if NotificFlowHdr.Get(Rec."No.") then
            Rec.Validate("Table ID", NotificFlowHdr."Table ID");
    end;
}
