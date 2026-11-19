table 83020 "Notification Recipient Line"
{
    DataClassification = CustomerContent;
    Caption = 'Notification Recipient Line';

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            Editable = false;
            TableRelation = "Notification Recipient Header".Code;
        }
        field(2; "Line No"; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(3; Type; Enum "Notification Recipient Type")
        {
            Caption = 'Notification Recipient Type';
        }
        field(4; "No."; Code[50])
        {
            Caption = 'No.';
            TableRelation = if
                (Type = const(User)) User."User Security ID"
            else if
                (Type = const(Employee)) Employee."No."
            else if
                (Type = const("Salespeople/Purchaser")) "Salesperson/Purchaser";
            ValidateTableRelation = false;
            trigger OnValidate()
            var
                UserRec: Record User;
                EmployeeRec: Record Employee;
                SalesPurchaserRec: Record "Salesperson/Purchaser";
            begin
                case Rec.Type of
                    Rec.Type::User:
                        begin
                            if not UserRec.Get(Rec."No.") then
                                exit;
                            Rec.Validate(Name, UserRec."User Name");
                            UserRec.TestField("Contact Email");
                            Rec.Validate("E-Mail", UserRec."Contact Email");
                        end;
                    Rec.Type::Employee:
                        begin
                            if not EmployeeRec.Get(Rec."No.") then
                                exit;
                            Rec.Validate(Name, EmployeeRec."First Name");
                            EmployeeRec.TestField("Company E-Mail");
                            Rec.Validate("E-Mail", EmployeeRec."Company E-Mail");
                        end;
                    Rec.Type::"Salespeople/Purchaser":
                        begin
                            if not SalesPurchaserRec.Get(Rec."No.") then
                                exit;
                            Rec.Validate(Name, SalesPurchaserRec.Name);
                            SalesPurchaserRec.TestField("E-Mail");
                            Rec.Validate("E-Mail", SalesPurchaserRec."E-Mail");
                        end;
                end;
            end;
        }

        field(5; Name; Text[80])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(6; "E-Mail"; Text[250])
        {
            Caption = 'E-Mail';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Code, "Line No")
        {
            Clustered = true;
        }
    }
}