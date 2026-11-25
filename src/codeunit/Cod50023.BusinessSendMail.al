codeunit 83001 BusinessSendMail
{
    TableNo = "Notification Queue";
    trigger OnRun()

    begin
        SendEmail(Rec);
    end;

    procedure SendEmail(var NotificationQueueRec: Record "Notification Queue"): Boolean
    var
        EmployeeRec: record "Employee";
        NotificationFlowHeader: Record "Notification Flow Header";
        RecipientListRec: Record "Notification Recipient Line";
        SalesPurchaserRec: record "Salesperson/Purchaser";
        UserRec: record "User";
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        PageManagement: Codeunit "Page Management";
        TypeHelper: Codeunit "Type Helper";
        RecRef: RecordRef;
        EmailSubject: Text;
        RecipientList: List of [Text];
        HyperLinkText: Text;
        RichTextContent: Text;
        CRLF: Text[1];
        EmailBody: TextBuilder;
        UserSecurityGUID: Guid;
    begin
        // RecipientListRec.SetRange(Code, NotificationQueueRec."User Group");
        // if not RecipientListRec.FindSet(false) then
        //     exit;
        // repeat
        //     RecipientList.Add(RecipientListRec."E-Mail");
        // until RecipientListRec.Next() = 0;

        case NotificationQueueRec."Notification Group" of
            NotificationQueueRec."Notification Group"::"Recipient Group":
                begin
                    RecipientListRec.SetRange(Code, NotificationQueueRec."User Group");
                    if not RecipientListRec.FindSet(false) then
                        exit;
                    repeat
                        RecipientList.Add(RecipientListRec."E-Mail");
                    until RecipientListRec.Next() = 0;
                end;
            NotificationQueueRec."Notification Group"::"Field Group":
                case NotificationQueueRec."Notification Recipient Type" of
                    NotificationQueueRec."Notification Recipient Type"::User:
                        begin
                            if Evaluate(UserSecurityGUID, NotificationQueueRec."Notification Recipient") then begin
                                if UserRec.Get(UserSecurityGUID) then
                                    RecipientList.Add(UserRec."Contact Email")
                            end else begin
                                UserRec.Reset();
                                UserRec.SetRange("User Name", NotificationQueueRec."Notification Recipient");
                                if UserRec.FindFirst() then
                                    RecipientList.Add(UserRec."Contact Email");
                            end;


                        end;
                    NotificationQueueRec."Notification Recipient Type"::Employee:
                        if EmployeeRec.Get(NotificationQueueRec."Notification Recipient") then
                            RecipientList.Add(EmployeeRec."E-Mail");
                    NotificationQueueRec."Notification Recipient Type"::"Salespeople/Purchaser":
                        if SalesPurchaserRec.Get(NotificationQueueRec."Notification Recipient") then
                            RecipientList.Add(SalesPurchaserRec."E-Mail");
                end;
        end;
        // RecRef := NotificationQueueRec."Record Id".GetRecord();
        // RecRef.FindFirst();
        RecRef.Get(NotificationQueueRec."Record Id");
        NotificationFlowHeader.Get(NotificationQueueRec."Notification Workflow Code");
        RichTextContent := GetNotificationEmailBody(RecRef, NotificationQueueRec);
        EmailSubject := GetEmailSubject(RecRef, NotificationQueueRec);
        CRLF := TypeHelper.LFSeparator();
        EmailBody.AppendLine(NotificationFlowHeader.Header);
        EmailBody.AppendLine('<br>');
        EmailBody.AppendLine('<br>');
        EmailBody.AppendLine(RichTextContent);

        EmailBody.AppendLine('<br>');
        EmailBody.AppendLine('<br>');

        HyperLinkText := PageManagement.GetWebUrl(RecRef, NotificationFlowHeader."Page ID");


        hyperlinkText := '<a href=' + HyperLinkText + '>' + 'Click this link to open Page</a>';



        EmailBody.AppendLine(hyperlinkText);
        EmailBody.AppendLine('<br>');
        EmailBody.AppendLine('<br>');
        EmailBody.AppendLine(NotificationFlowHeader.Footer);

        EmailMessage.Create(RecipientList, EmailSubject, EmailBody.ToText(), true);
        //Email.OpenInEditor(EmailMessage, Enum::"Email Scenario"::"Notification");
        exit(Email.Send(EmailMessage, Enum::"Email Scenario"::"Notification"));
    end;

    procedure GetEmailSubject(Var RecRef: RecordRef; var NotificationQueue: Record "Notification Queue"): Text
    var
        NotificationFlowHeader: Record "Notification Flow Header";
        NotificationFlowLine: Record "Notification flow line";
        NotificationSubjectLine: Record "Notification Subject Line";

        FieldRef: FieldRef;
        Subject: Text;
    begin
        Clear(Subject);
        NotificationFlowHeader.Get(NotificationQueue."Notification Workflow Code");
        NotificationSubjectLine.Reset();
        NotificationSubjectLine.SetCurrentKey("Sequence No.");
        NotificationSubjectLine.SetRange("Table ID", NotificationQueue."Table No.");
        NotificationSubjectLine.SetRange("Notification No.", NotificationQueue."Notification Workflow Code");
        NotificationSubjectLine.SetRange("Notification Line No.", NotificationQueue."Line No.");
        NotificationSubjectLine.SetAscending("Sequence No.", true);
        if not NotificationSubjectLine.FindSet() then
            exit(NotificationFlowHeader.Name);
        repeat
            if NotificationSubjectLine."Field ID" = 0 then
                continue;
            Clear(FieldRef);
            FieldRef := RecRef.Field(NotificationSubjectLine."Field ID");
            if FieldRef.Class = FieldClass::FlowField then
                FieldRef.CalcField();
            Subject += Format(FieldRef.Value) + ' - ';
        until NotificationSubjectLine.Next() = 0;

        if StrLen(Subject) <> 0 then
            RemoveUnwantedHifen(Subject);
        exit(Subject);
    end;

    procedure RemoveUnwantedHifen(Var Subject: Text)
    begin
        Subject := CopyStr(Subject, 1, StrLen(Subject) - 3);
    end;

    local procedure GetNotificationEmailBody(RecRef: RecordRef; NotificationQueue: Record "Notification Queue"): Text
    var
        ReportSelecNotif: Record "Report Selections-Notif";
        Instream: InStream;
        ContentLine: Text;
        FieldRef: FieldRef;
        i: Integer;
        Tag: Text;
    begin
        ReportSelecNotif.SetRange("Notification No.", NotificationQueue."Notification Workflow Code");
        if NotificationQueue."Line No." <> 0 then
            ReportSelecNotif.SetRange("Notification Line No.", NotificationQueue."Line No.");
        if ReportSelecNotif.FindFirst() then begin
            ReportSelecNotif.CalcFields("E-Mail Body");
            if ReportSelecNotif."E-Mail Body".HasValue then begin
                ReportSelecNotif."E-Mail Body".CreateInStream(Instream, TextEncoding::UTF8);
                Instream.Read(ContentLine);

                // Replace custom/virtual variables first so blank custom fields don't overwrite resolved values
                ReplaceCustomVariables(RecRef, ContentLine);

                // Dynamically replace {{Field Name}} and {{Field Caption}} with record values
                for i := 1 to RecRef.FieldCount do begin
                    FieldRef := RecRef.FieldIndex(i);
                    Tag := '{{' + FieldRef.Name + '}}';
                    if ContentLine.Contains(Tag) then begin
                        if FieldRef.Class = FieldClass::FlowField then
                            FieldRef.CalcField();
                        ContentLine := ContentLine.Replace(Tag, Format(FieldRef.Value));
                    end;
                    Tag := '{{' + FieldRef.Caption + '}}';
                    if ContentLine.Contains(Tag) then begin
                        if FieldRef.Class = FieldClass::FlowField then
                            FieldRef.CalcField();
                        ContentLine := ContentLine.Replace(Tag, Format(FieldRef.Value));
                    end;
                end;

                exit(ContentLine);
            end;
        end;
    end;

    local procedure ReplaceCustomVariables(RecRef: RecordRef; var ContentLine: Text)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        CustNoFldRef: FieldRef;
        CustNo: Code[20];
        CustomerName: Text;
        i: Integer;
    begin
        OnBeforeReplaceCustomVariables(RecRef, ContentLine);

        if ContentLine.Contains('{{Customer Name}}') or ContentLine.Contains('{{Customer.Name}}') or ContentLine.Contains('{{CustomerName}}') then begin
            CustNo := '';
            case RecRef.Number of
                Database::"Cust. Ledger Entry":
                    begin
                        RecRef.SetTable(CustLedgerEntry);
                        CustNo := CustLedgerEntry."Customer No.";
                    end;
                else begin
                    for i := 1 to RecRef.FieldCount do begin
                        CustNoFldRef := RecRef.FieldIndex(i);
                        if UpperCase(CustNoFldRef.Name) in ['CUSTOMER NO.', 'CUSTOMER NO', 'SELL-TO CUSTOMER NO.', 'BILL-TO CUSTOMER NO.'] then begin
                            CustNo := Format(CustNoFldRef.Value);
                            if CustNo <> '' then
                                break;
                        end;
                    end;
                end;
            end;

            CustomerName := '';
            if CustNo <> '' then
                if Customer.Get(CustNo) then
                    CustomerName := Customer.Name;

            if ContentLine.Contains('{{Customer Name}}') then
                ContentLine := ContentLine.Replace('{{Customer Name}}', CustomerName);
            if ContentLine.Contains('{{Customer.Name}}') then
                ContentLine := ContentLine.Replace('{{Customer.Name}}', CustomerName);
            if ContentLine.Contains('{{CustomerName}}') then
                ContentLine := ContentLine.Replace('{{CustomerName}}', CustomerName);
        end;

        OnAfterReplaceCustomVariables(RecRef, ContentLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReplaceCustomVariables(RecRef: RecordRef; var ContentLine: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReplaceCustomVariables(RecRef: RecordRef; var ContentLine: Text)
    begin
    end;

}
