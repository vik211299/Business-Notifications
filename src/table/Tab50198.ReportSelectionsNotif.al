table 83023 "Report Selections-Notif"
{
    Caption = 'Report Selections-Notification';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Usage; Enum "Report Selection Usage")
        {
            Caption = 'Usage';
        }
        field(2; Sequence; Code[10])
        {
            Caption = 'Sequence';
            Numeric = true;
        }
        field(3; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));

            trigger OnValidate()
            begin
                Calcfields("Report Caption");
                Validate("Use for Email Body", false);

                if "Report ID" = 0 then
                    exit;

                // UpdateReportSelectionFromNotification();

            end;
        }
        field(4; "Report Caption"; Text[250])
        {
            CalcFormula = lookup("Report Metadata".Caption where(ID = field("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = Flowfield;
        }
        field(7; "Custom Report Layout Code"; Code[20])
        {
            Caption = 'Custom Report Layout Code';
            Editable = false;
            TableRelation = "Custom Report Layout".Code where(Code = field("Custom Report Layout Code"), "Built-In" = const(false));
        }
        field(19; "Use for Email Attachment"; Boolean)
        {
            Caption = 'Use for Email Attachment';
            InitValue = true;

            trigger OnValidate()
            begin
                if not "Use for Email Body" then begin
                    "Email Body Layout Code" := '';
                    "Email Body Layout Name" := '';
                end;
            end;
        }
        field(20; "Use for Email Body"; Boolean)
        {
            Caption = 'Use for Email Body';

            trigger OnValidate()
            begin
                if not "Use for Email Body" then begin
                    "Email Body Layout Code" := '';
                    "Email Body Layout Name" := '';
                end;
            end;
        }
        field(21; "Email Body Layout Code"; Code[20])
        {
            Caption = 'Email Body Custom Layout Code';
            TableRelation = if ("Email Body Layout Type" = const("Custom Report Layout")) "Custom Report Layout".Code where(Code = field("Email Body Layout Code"), "Report ID" = field("Report ID"), "Built-In" = const(false))
            else
            if ("Email Body Layout Type" = const("HTML Layout")) "O365 HTML Template".Code;

            trigger OnValidate()
            begin
                if "Email Body Layout Code" <> '' then begin
                    Testfield("Use for Email Body", true);
                    "Email Body Layout Name" := '';
                end;
                Calcfields("Email Body Layout Description");
            end;
        }
        field(22; "Email Body Layout Description"; Text[250])
        {
            CalcFormula = lookup("Custom Report Layout".Description where(Code = field("Email Body Layout Code")));
            Caption = 'Email Body Custom Layout Description';
            Editable = false;
            FieldClass = Flowfield;

            trigger OnLookup()
            var
                CustomReportLayout: Record "Custom Report Layout";
            begin
                if "Email Body Layout Type" = "Email Body Layout Type"::"Custom Report Layout" then
                    if CustomReportLayout.LookupLayoutOK("Report ID") then
                        Validate("Email Body Layout Code", CustomReportLayout.Code);
            end;
        }
        field(25; "Email Body Layout Type"; Enum "Email Body Layout Type")
        {
            Caption = 'Email Body Layout Type';
        }
        field(26; "Email Body Layout Name"; Text[250])
        {
            Caption = 'Email Body Layout Name';
            TableRelation = "Report Layout List".Name where("Report ID" = field("Report ID"));

            trigger OnLookup()
            var
                ReportLayoutList: Record "Report Layout List";
                ReportManagement: Codeunit ReportManagement;
                Handled: Boolean;
            begin
                ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                ReportManagement.OnSelectReportLayout(ReportLayoutList, Handled);
                if not Handled then
                    exit;
                "Email Body Layout Name" := ReportLayoutList.Name;
                "Email Body Layout AppID" := ReportLayoutList."Application ID";
            end;

            trigger OnValidate()
            var
                ReportLayoutList: Record "Report Layout List";
            begin
                if "Email Body Layout Name" <> '' then begin
                    "Use for Email Body" := true;
                    "Email Body Layout Code" := '';
                    "Email Body Layout Description" := '';
                    ReportLayoutList.SetRange(Name, "Email Body Layout Name");
                    ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                    if not IsNullGuid("Email Body Layout AppID") then
                        ReportLayoutList.SetRange("Application ID", "Email Body Layout AppID");
                    if not ReportLayoutList.FindFirst() then begin
                        ReportLayoutList.SetRange("Application ID");
                        ReportLayoutList.FindFirst();
                    end;
                    if IsNullGuid("Email Body Layout AppID") then
                        Rec."Email Body Layout AppID" := ReportLayoutList."Application ID";
                end;
            end;
        }
        field(27; "Email Body Layout AppID"; Guid)
        {
            Caption = 'Email Body Layout AppID';
            TableRelation = "Report Layout List"."Application ID" where("Report ID" = field("Report ID"));
        }
        field(28; "Email Body Layout Publisher"; Text[250])
        {
            Caption = 'Email Body Layout Publisher';
            FieldClass = FlowField;
            CalcFormula = lookup("Report Layout List"."Layout Publisher" where("Report ID" = field("Report ID"), Name = field("Email Body Layout Name")));
            Editable = false;
        }
        field(29; "Email Body Layout Caption"; Text[250])
        {
            Caption = 'Email Body Layout';
            FieldClass = FlowField;
            CalcFormula = lookup("Report Layout List".Caption where("Report ID" = field("Report ID"), Name = field("Email Body Layout Name")));
            Editable = false;
            trigger OnLookup()
            var
                ReportLayoutList: Record "Report Layout List";
                ReportManagement: Codeunit ReportManagement;
                Handled: Boolean;
            begin
                ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                ReportManagement.OnSelectReportLayout(ReportLayoutList, Handled);
                if not Handled then
                    exit;
                "Email Body Layout Name" := ReportLayoutList.Name;
                "Email Body Layout AppID" := ReportLayoutList."Application ID";
            end;
        }
        field(30; "Report Layout Name"; Text[250])
        {
            Caption = 'Report Layout name';
            ToolTip = 'Specifies the name of the report layout that is used.';
            TableRelation = "Report Layout List".Name where("Report ID" = field("Report ID"));

            trigger OnLookup()
            var
                ReportLayoutList: Record "Report Layout List";
                ReportManagement: Codeunit ReportManagement;
                Handled: Boolean;
            begin
                ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                ReportManagement.OnSelectReportLayout(ReportLayoutList, Handled);
                if not Handled then
                    exit;
                "Report Layout Name" := ReportLayoutList.Name;
                "Report Layout AppID" := ReportLayoutList."Application ID";
            end;

            trigger OnValidate()
            var
                ReportLayoutList: Record "Report Layout List";
            begin
                if "Report Layout Name" <> '' then begin
                    "Use for Email Attachment" := true;
                    ReportLayoutList.SetRange(Name, "Report Layout Name");
                    ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                    if not IsNullGuid("Report Layout AppID") then
                        ReportLayoutList.SetRange("Application ID", "Report Layout AppID");
                    if not ReportLayoutList.FindFirst() then begin
                        ReportLayoutList.SetRange("Application ID");
                        ReportLayoutList.FindFirst();
                    end;
                    if IsNullGuid("Report Layout AppID") then
                        Rec."Report Layout AppID" := ReportLayoutList."Application ID";
                end;

                // UpdateReportSelectionFromNotification();
            end;
        }
        field(31; "Report Layout AppID"; Guid)
        {
            Caption = 'Report Layout App ID';
            Editable = false;
        }
        field(32; "Report Layout Caption"; Text[250])
        {
            Caption = 'Report Layout';
            ToolTip = 'Specifies the Name of the report layout that is used.';
            FieldClass = FlowField;
            CalcFormula = lookup("Report Layout List".Caption where("Report ID" = field("Report ID"), Name = field("Report Layout Name")));
            Editable = false;
            trigger OnLookup()
            var
                ReportLayoutList: Record "Report Layout List";
                ReportManagement: Codeunit ReportManagement;
                Handled: Boolean;
            begin
                ReportLayoutList.SetRange("Report ID", Rec."Report ID");
                ReportManagement.OnSelectReportLayout(ReportLayoutList, Handled);
                if not Handled then
                    exit;
                "Report Layout Name" := ReportLayoutList.Name;
                "Report Layout AppID" := ReportLayoutList."Application ID";
                if "Report Layout Name" <> '' then
                    "Use for Email Attachment" := true;
            end;
        }
        field(33; "Report Layout Publisher"; Text[250])
        {
            Caption = 'Report Layout Publisher';
            ToolTip = 'Specifies the publisher of the email Attachment layout that is used.';
            FieldClass = FlowField;
            CalcFormula = lookup("Report Layout List"."Layout Publisher" where("Report ID" = field("Report ID"), "Application ID" = field("Report Layout AppID")));
            Editable = false;
        }
        field(50000; "Notification Line No."; Integer)
        {
        }
        field(50001; "Notification No."; Code[20])
        {

        }
        field(50002; "E-Mail Body"; Blob)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Notification No.", "Notification Line No.")
        {
            Clustered = true;
        }
    }

    /*  trigger OnDelete()
     var
         ReportSelection: Record "Report Selections";
     begin
         ReportSelection.SetRange("Notification No.", "Notification No.");
         ReportSelection.SetRange("Notification Line No.", "Notification Line No.");
         ReportSelection.SetRange(Usage, Usage);
         ReportSelection.DeleteAll();
     end; */

    procedure SaveReportAsPDFInTempBlob(var TempBlob: Codeunit "Temp Blob"; ReportID: Integer)
    var
        ReportLayoutSelectionLocal: Record "Report Layout Selection";
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
        CustomerStatementSub: codeunit "Customer Statement Subscr";
        LastUsedParameters: Text;
        IsHandled: Boolean;
        OutStream: OutStream;
        RepInst: InStream;
        OutPut: Text;
    begin

        if Rec."Report Layout Name" <> '' then
            ReportLayoutSelectionLocal.SetTempLayoutSelectedName(Rec."Report Layout Name", Rec."Report Layout AppID");
        //else
        //ReportLayoutSelectionLocal.SetTempLayoutSelected(LayoutCode);

        TempBlob.CreateOutStream(OutStream);
        LastUsedParameters := CustomLayoutReporting.GetReportRequestPageParameters(ReportID);
        Report.SaveAs(ReportID, LastUsedParameters, ReportFormat::Pdf, OutStream);


        ReportLayoutSelectionLocal.ClearTempLayoutSelected();

        Commit();
        // TempBlob.CreateInStream(RepInst);
        //RepInst.Read(OutPut)
    end;


}