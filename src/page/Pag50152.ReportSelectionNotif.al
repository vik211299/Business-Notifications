page 83007 "Report Selection - Notif"
{
    ApplicationArea = All;
    Caption = 'Report Selection - Notifications';
    PageType = Card;
    SaveValues = true;
    SourceTable = "Report Selections-Notif";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(RichTextVar; RichTextVar)
                {
                    ApplicationArea = all;
                    MultiLine = true;
                    ShowCaption = false;
                    ExtendedDatatype = RichContent;
                    trigger OnValidate()
                    begin
                        SetRichText();
                    end;
                }

            }
        }

    }

    actions
    {
    }

    /*  trigger OnNewRecord(BelowxRec: Boolean)
     begin
         Rec.Usage := Rec.Usage::"Business Notification";

         ReportSelection2.SetRange(Usage, Rec.Usage::"Business Notification");
         ReportSelection2.SetRange("Notification No.", Rec."Notification No.");
         ReportSelection2.SetRange("Notification Line No.", Rec."Notification Line No.");
         if ReportSelection2.FindLast() and (ReportSelection2.Sequence <> '') then
             Rec.Sequence := IncStr(ReportSelection2.Sequence)
         else
             Rec.Sequence := '1';
     end;
  */

    var
        ReportUsage2: Enum "Report Selection Usage";


    procedure DrillDownToSelectLayout(var SelectedLayoutName: Text[250]; var SelectedLayoutAppID: Guid)
    var
        ReportLayoutListSelection: Record "Report Layout List";
        ReportManagementCodeunit: Codeunit ReportManagement;
        IsReportLayoutSelected: Boolean;
    begin
        ReportLayoutListSelection.SetRange("Report ID", Rec."Report ID");
        ReportManagementCodeunit.OnSelectReportLayout(ReportLayoutListSelection, IsReportLayoutSelected);
        if IsReportLayoutSelected then begin
            SelectedLayoutName := ReportLayoutListSelection."Name";
            SelectedLayoutAppID := ReportLayoutListSelection."Application ID";
        end;
    end;

    local procedure GetRichText()
    var
        RichTextInS: InStream;
    begin
        Rec.CalcFields("E-Mail Body");
        Rec."E-Mail Body".CreateInStream(RichTextInS, TextEncoding::UTF8);
        RichTextInS.Read(RichTextVar);
    end;

    local procedure SetRichText()
    var
        RichTextOutS: OutStream;
    begin
        Clear(Rec."E-Mail Body");
        Rec."E-Mail Body".CreateOutStream(RichTextOutS, TextEncoding::UTF8);
        RichTextOutS.Write(RichTextVar);
        if not Rec.Insert(true) then
            Rec.Modify();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetRichText();
    end;

    var
        ReportSelection2: Record "Report Selections-Notif";
        RichTextVar: Text;
}