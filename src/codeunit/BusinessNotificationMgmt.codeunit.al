codeunit 83000 "Business Notification Mgmt."
{
    #region Job Queue
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        case Rec."Parameter String" of
            'NotificationScheduler':
                this.RunNotificationScheduler();
            'ProcessNotificationEmails':
                this.ProcessNotificationEmails();
        end;
    end;

    local procedure RunNotificationScheduler()
    var
        NotificationFlowHeader: Record "Notification Flow Header";
    begin
        NotificationFlowHeader.SetRange(Active, true);
        if not NotificationFlowHeader.FindSet() then
            exit;
        repeat
            this.CreateNotificationQueue(NotificationFlowHeader);
        until NotificationFlowHeader.Next() = 0;
    end;

    local procedure CreateNotificationQueue(var NotificationFlowHeader: Record "Notification Flow Header")
    var
        RecRef: RecordRef;
    begin
        if not this.OpenRecordReference(NotificationFlowHeader."Table ID", RecRef) then
            exit;
        case NotificationFlowHeader."Field Type" of
            NotificationFlowHeader."Field Type"::Date:
                this.CreateNotificationQueueForDate(NotificationFlowHeader, RecRef);

            NotificationFlowHeader."Field Type"::Integer, NotificationFlowHeader."Field Type"::Decimal:
                this.CreateNotificationQueueForIntegerOrDecimal(NotificationFlowHeader, RecRef);
        end;
    end;

    [TryFunction]
    local procedure OpenRecordReference(TableID: Integer; var RecRef: RecordRef)
    begin
        RecRef.Open(TableID);
    end;

    local procedure CreateNotificationQueueForIntegerOrDecimal(var NotificationFlowHeader: Record "Notification Flow Header"; var RecRef: RecordRef)
    var
        NotifiyFlowLine: Record "Notification flow line";
        FieldRef: FieldRef;
        RecordValue: Decimal;
        InStream: InStream;
        FilterText: Text;
    begin
        NotificationFlowHeader.CalcFields("Filter Blob");
        NotificationFlowHeader."Filter Blob".CreateInStream(InStream);
        InStream.ReadText(FilterText);
        RecRef.SetView(FilterText);
        if not RecRef.FindSet() then
            exit;
        repeat
            FieldRef := RecRef.Field(NotificationFlowHeader."Field ID");
            if FieldRef.Class = FieldRef.Class::FlowField then
                FieldRef.CalcField();
            if not Evaluate(RecordValue, Format(FieldRef.Value)) then
                continue;
            NotifiyFlowLine.SetRange("No.", NotificationFlowHeader."No.");
            if NotifiyFlowLine.FindSet() then
                repeat
                    if (NotifiyFlowLine."Start Range" <= RecordValue) and (NotifiyFlowLine."End Range" >= RecordValue) then
                        this.InsertNotifyQueue(NotificationFlowHeader."No.", NotifiyFlowLine, RecRef);
                until NotifiyFlowLine.Next() = 0;
        until RecRef.Next() = 0;
        RecRef.Close();
    end;

    local procedure CreateNotificationQueueForDate(var NotificationFlowHeader: Record "Notification Flow Header"; var RecRef: RecordRef)
    var
        NotifiyFlowLine: Record "Notification flow line";
        FieldRef: FieldRef;
        TempDate: Date;
        InStream: InStream;
        DaysDiff: Integer;
        FilterText: Text;
    begin
        NotificationFlowHeader.CalcFields("Filter Blob");
        NotificationFlowHeader."Filter Blob".CreateInStream(InStream);
        InStream.ReadText(FilterText);
        RecRef.SetView(FilterText);
        if not RecRef.FindSet() then
            exit;
        repeat
            FieldRef := RecRef.Field(NotificationFlowHeader."Field ID");
            if not Evaluate(TempDate, Format(FieldRef.Value)) then
                continue;
            if TempDate = 0D then
                continue;
            DaysDiff := WorkDate() - TempDate;
            NotifiyFlowLine.Reset();
            NotifiyFlowLine.SetRange("No.", NotificationFlowHeader."No.");
            if NotifiyFlowLine.FindSet() then
                repeat
                    if (NotifiyFlowLine."Start Range" <= DaysDiff) and (NotifiyFlowLine."End Range" >= DaysDiff) then
                        this.InsertNotifyQueue(NotificationFlowHeader."No.", NotifiyFlowLine, RecRef);
                until NotifiyFlowLine.Next() = 0;
        until RecRef.Next() = 0;
        RecRef.Close();
    end;

    local procedure ProcessNotificationEmails()
    var
        NotificationQueueRec: Record "Notification Queue";
        OutStream: OutStream;
        SendMail: Codeunit BusinessSendMail;
    begin
        this.CompressNotificationQueue(true);
        NotificationQueueRec.SetFilter("Mail Scheduled DateTime", '<%1', CurrentDateTime());
        if not NotificationQueueRec.FindSet() then
            exit;
        repeat
            if SendMail.Run(NotificationQueueRec) then
                NotificationQueueRec.Mark(true)
            else begin
                NotificationQueueRec."Error Message Code".CreateOutStream(OutStream);
                OutStream.WriteText(System.GetLastErrorCode());
                Clear(OutStream);
                NotificationQueueRec."Error Message Text".CreateOutStream(OutStream);
                OutStream.WriteText(System.GetLastErrorText());
                Clear(OutStream);
                NotificationQueueRec."Error Call Stack".CreateOutStream(OutStream);
                OutStream.WriteText(System.GetLastErrorCallStack());
                NotificationQueueRec.Validate("Has Error", true);
                NotificationQueueRec.Modify(true);
            end;
        until NotificationQueueRec.Next() = 0;
        NotificationQueueRec.MarkedOnly(true);
        NotificationQueueRec.DeleteAll(true);
    end;


    local procedure CompressNotificationQueue(UseCommit: Boolean)
    var
        PrimaryNotificationQueueRec: Record "Notification Queue";
        SecondaryNotificationQueueRec: Record "Notification Queue";
    begin
        PrimaryNotificationQueueRec.SetCurrentKey("Mail Scheduled DateTime");
        PrimaryNotificationQueueRec.SetAscending("Mail Scheduled DateTime", false);
        PrimaryNotificationQueueRec.SetRange("Has Error", false);
        PrimaryNotificationQueueRec.SetFilter("Mail Scheduled DateTime", '<%1', CurrentDateTime());
        if not PrimaryNotificationQueueRec.FindSet() then
            exit;
        repeat
            SecondaryNotificationQueueRec.Reset();
            SecondaryNotificationQueueRec.SetRange("Notification Workflow Code", PrimaryNotificationQueueRec."Notification Workflow Code");
            SecondaryNotificationQueueRec.SetRange("Line No.", PrimaryNotificationQueueRec."Line No.");
            SecondaryNotificationQueueRec.SetFilter("Entry No.", '<>%1', PrimaryNotificationQueueRec."Entry No.");
            SecondaryNotificationQueueRec.SetRange("Record Id", PrimaryNotificationQueueRec."Record Id");
            SecondaryNotificationQueueRec.SetRange("Has Error", false);
            SecondaryNotificationQueueRec.SetFilter("Mail Scheduled DateTime", '<%1', CurrentDateTime());
            SecondaryNotificationQueueRec.DeleteAll(true);
        until PrimaryNotificationQueueRec.Next() = 0;
        if UseCommit then
            Commit(); //To Save progress of Compression if any occurs in later stages
    end;
    #endregion
    #region Notification Recipient Header
    [EventSubscriber(ObjectType::Table, Database::"Notification Recipient Header", OnBeforeDeleteEvent, '', true, true)]
    local procedure OnBeforeDeleteNotificationRecipientHeader(var Rec: Record "Notification Recipient Header")
    begin
        this.CheckIfNotificatioNRecipientGroupIsUsed(Rec);
    end;
    #endregion
    #region Notification Flow Header
    [EventSubscriber(ObjectType::Table, database::"Notification Flow Header", OnBeforeValidateEvent, "Table ID", true, true)]
    local procedure OnBeforeValidateTableID(var Rec: Record "Notification Flow Header")
    var
        AllObjectsWithCaption: Record AllObjWithCaption;
        PageManagement: Codeunit "Page Management";
    begin
        Clear(Rec."Filter Blob");
        Clear(Rec."Field ID");
        Clear(Rec."Field Name");
        Clear(Rec."Field Type");
        Clear(Rec."Field Threshold");
        if AllObjectsWithCaption.Get(AllObjectsWithCaption."Object Type"::Table, Rec."Table ID") then begin
            Rec.Validate("Table Name", AllObjectsWithCaption."Object Caption");
            Rec.Validate("Page ID", PageManagement.GetDefaultCardPageID(Rec."Table ID"));
        end
        else begin
            Clear(Rec."Table Name");
            Clear(Rec."Page ID");
        end;
    end;

    [EventSubscriber(ObjectType::Table, database::"Notification Flow Header", OnBeforeValidateEvent, "Field Threshold", true, true)]
    local procedure OnBeforeValidateThreshold(var Rec: Record "Notification Flow Header")
    var
        TempDecimal: Decimal;

        TempInteger: Integer;
        DateFieldErrorLbl: Label '%1 cannot be used when %2 = %3', Comment = '%1 = Field Threshold, %2 = Field Type, %3 = Field Type';
    begin
        case Rec."Field Type" of
            Rec."Field Type"::Decimal:
                Evaluate(TempDecimal, Format(Rec."Field Threshold"));
            Rec."Field Type"::Integer:
                Evaluate(TempInteger, Format(Rec."Field Threshold"));
            else
                Error(DateFieldErrorLbl, Rec.FieldCaption("Field Threshold"), Rec.FieldCaption("Field Type"), Rec."Field Type");
        end;
    end;

    [EventSubscriber(ObjectType::Table, database::"Notification Flow Header", OnAfterValidateEvent, "Field ID", true, true)]
    local procedure OnAfterValidateFieldID(var Rec: Record "Notification Flow Header")
    var
        FieldRec: Record Field;

    begin
        if Rec."Field ID" = 0 then begin
            Rec.Validate("Field Name", '');
            Rec.Modify(true);
            exit;
        end;
        FieldRec.Get(Rec."Table ID", Rec."Field ID");
        Rec.Validate("Field Name", FieldRec.FieldName);
        case FieldRec.Type of
            FieldRec.Type::Date:
                Rec.Validate("Field Type", Rec."Field Type"::Date);
            FieldRec.Type::Integer:
                Rec.Validate("Field Type", Rec."Field Type"::Integer);
            FieldRec.Type::Decimal:
                Rec.Validate("Field Type", Rec."Field Type"::Decimal);
        end;
        Rec.Modify(true);
    end;
    #endregion

    #region Notification Flow Line
    [EventSubscriber(ObjectType::Table, database::"Notification Flow Line", OnBeforeValidateEvent, Frequency, true, true)]
    local procedure OnBeforeValidateFrequency(var Rec: Record "Notification Flow Line")
    var
        NotficationSetup: Record "Business Notification Setup";
        TempErrorMessageRec: Record "Error Message" temporary;
        TimeDifferenceMinutes: Integer;
        FrequencyErrorLbl: Label '%1: %2 cannot be greater than the time difference between the start and end time (%3 Minutes) of the company working hours', Comment = '%1 = Field Caption, %2 = Frequency, %3 = Time Difference in Minutes';
    begin
        if Rec.Frequency = 0 then
            exit;

        NotficationSetup.Get();
        TempErrorMessageRec.LogIfEmpty(NotficationSetup, NotficationSetup.FieldNo("Start Time"), TempErrorMessageRec."Message Type"::Error);
        TempErrorMessageRec.LogIfEmpty(NotficationSetup, NotficationSetup.FieldNo("End Time"), TempErrorMessageRec."Message Type"::Error);
        if TempErrorMessageRec.HasErrors(false) then
            TempErrorMessageRec.ShowErrorMessages(true);

        TimeDifferenceMinutes := Round(((NotficationSetup."End Time" - NotficationSetup."Start Time") / (1000 * 60)), 1, '<');
        if Rec.Frequency > TimeDifferenceMinutes then
            Error(FrequencyErrorLbl, Rec.FieldCaption(Frequency), Rec.Frequency, TimeDifferenceMinutes);
    end;

    #endregion

    #region Notification Queue
    [EventSubscriber(ObjectType::Table, database::"Notification Queue", OnBeforeInsertEvent, '', true, true)]
    local procedure OnBeforeInsertNotificationQueue(var Rec: Record "Notification Queue")
    begin
        this.GetLastNotificationQueueEntryNo(Rec);
    end;

    local procedure GetLastNotificationQueueEntryNo(var Rec: Record "Notification Queue")
    var
        NotificationQueue: Record "Notification Queue";
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        NotificationQueue.SetCurrentKey("Entry No.");
        NotificationQueue.SetAscending("Entry No.", true);
        Rec.Validate("Entry No.", FindRecordManagement.GetLastEntryIntFieldValue(NotificationQueue, NotificationQueue.FieldNo("Entry No.")) + 1);
    end;

    #endregion
    #region General Functions
    procedure ActivateNotificationRecipientGroup(var NotificationRecipientHeader: Record "Notification Recipient Header"; ShowNotification: Boolean)
    begin
        this.PreValidateActivateNotificationRecipientGroup(NotificationRecipientHeader);
        NotificationRecipientHeader.Validate(Status, NotificationRecipientHeader.Status::Certified);
        NotificationRecipientHeader.Modify(true);
        if ShowNotification then
            Message('Notification Recipient Group %1 has been activated', NotificationRecipientHeader.Code);
    end;

    local procedure PreValidateActivateNotificationRecipientGroup(var NotificationRecipientHeader: Record "Notification Recipient Header")
    var
        TempErrorMessageRec: Record "Error Message" temporary;
        NotificationRecipientLine: Record "Notification Recipient Line";
        NotificationRecipientGroupMissingErrorLbl: Label 'There are no Notification Recipient Lines for Notification Recipient Group %1', Comment = '%1 = Notification Recipient Group Code';
    begin
        NotificationRecipientLine.SetRange(Code, NotificationRecipientHeader.Code);
        if NotificationRecipientLine.IsEmpty() then
            TempErrorMessageRec.LogMessage(
                NotificationRecipientHeader,
                NotificationRecipientHeader.FieldNo(Code),
                TempErrorMessageRec."Message Type"::Error,
                StrSubstNo(NotificationRecipientGroupMissingErrorLbl, NotificationRecipientHeader.Code));
        if NotificationRecipientLine.FindSet(false) then
            repeat
                TempErrorMessageRec.LogIfEmpty(NotificationRecipientLine, NotificationRecipientLine.FieldNo("E-Mail"), TempErrorMessageRec."Message Type"::Error);
            until NotificationRecipientLine.Next() = 0;
        if TempErrorMessageRec.HasErrors(false) then
            TempErrorMessageRec.ShowErrorMessages(true);
    end;

    procedure DeactivateNotificationRecipientGroup(var NotificationRecipientHeader: Record "Notification Recipient Header"; ShowNotification: Boolean)
    begin
        this.PreValidateDeactivateRecipientGroup(NotificationRecipientHeader);
        NotificationRecipientHeader.Validate(Status, NotificationRecipientHeader.Status::Open);
        NotificationRecipientHeader.Modify(true);
        if ShowNotification then
            Message('Notification Recipient Group %1 has been deactivated', NotificationRecipientHeader.Code);
    end;

    local procedure PreValidateDeactivateRecipientGroup(var NotificationRecipientHeader: Record "Notification Recipient Header")
    begin
        this.CheckIfNotificatioNRecipientGroupIsUsed(NotificationRecipientHeader);
    end;

    local procedure CheckIfNotificatioNRecipientGroupIsUsed(var NotificationRecipientHeader: Record "Notification Recipient Header")
    var
        NotificationFlowLine: Record "Notification flow line";
        NotificationRecipientHeaderInUseErrorLbl: Label 'There are Notification Flows Configured with this Notification Recipient Group %1. Cannot Delete the Notification Recipient Group', Comment = '%1 = Notification Recipient Group Code';
    begin
        NotificationFlowLine.SetRange("Recipient Code", NotificationRecipientHeader.Code);
        NotificationFlowLine.CalcFields(Active);
        NotificationFlowLine.SetRange(Active, true);
        if NotificationFlowLine.IsEmpty() then
            exit;
        Error(NotificationRecipientHeaderInUseErrorLbl, NotificationRecipientHeader.Code);
    end;

    procedure ActivateNotificationFlow(var Rec: Record "Notification Flow Header")
    begin
        this.PreValidateNotificationFlow(Rec);
        Rec.Validate("Active", true);
        Rec.Modify(true);
    end;

    procedure DeactivateNotificationFlow(var Rec: Record "Notification Flow Header")
    begin
        Rec.Validate("Active", false);
        Rec.Modify(true);
    end;

    procedure PreValidateNotificationFlow(var Rec: Record "Notification Flow Header")
    var
        TempErrorMessageRec: Record "Error Message" temporary;
        NotificationFlowLineRec: Record "Notification Flow Line";
        NotificationFlowLinesMissingErrorLbl: Label 'There are no Notification Flow Lines for Notification Flow %1', Comment = '%1 = Notification Flow No.';
    begin
        TempErrorMessageRec.LogIfEmpty(Rec, Rec.FieldNo("Table ID"), TempErrorMessageRec."Message Type"::Error);
        TempErrorMessageRec.LogIfEmpty(Rec, Rec.FieldNo("Field ID"), TempErrorMessageRec."Message Type"::Error);

        NotificationFlowLineRec.SetRange("No.", Rec."No.");
        if NotificationFlowLineRec.IsEmpty then
            TempErrorMessageRec.LogMessage(
                NotificationFlowLineRec,
                NotificationFlowLineRec.FieldNo("No."),
                TempErrorMessageRec."Message Type"::Error,
                StrSubstNo(NotificationFlowLinesMissingErrorLbl, Rec."No."));
        if NotificationFlowLineRec.FindSet(false) then
            repeat
                TempErrorMessageRec.LogIfLessThan(NotificationFlowLineRec, NotificationFlowLineRec.FieldNo("End Range"), TempErrorMessageRec."Message Type"::Error, NotificationFlowLineRec."Start Range");
                // TempErrorMessageRec.LogIfEqualTo(NotificationFlowLineRec, NotificationFlowLineRec.FieldNo("End Range"), TempErrorMessageRec."Message Type"::Error, NotificationFlowLineRec."Start Range");
                if NotificationFlowLineRec."Notification Group" = NotificationFlowLineRec."Notification Group"::"Recipient Group" then
                    TempErrorMessageRec.LogIfEmpty(NotificationFlowLineRec, NotificationFlowLineRec.FieldNo("Recipient Code"), TempErrorMessageRec."Message Type"::Error);
                if NotificationFlowLineRec."Notification Group" = NotificationFlowLineRec."Notification Group"::"Field Group" then begin
                    //TempErrorMessageRec.LogIfEmpty(NotificationFlowLineRec, NotificationFlowLineRec.FieldNo("Notification Recipient Type"), TempErrorMessageRec."Message Type"::Error);
                    TempErrorMessageRec.LogIfEmpty(NotificationFlowLineRec, NotificationFlowLineRec.FieldNo("Field ID"), TempErrorMessageRec."Message Type"::Error);
                end;
                TempErrorMessageRec.LogIfLessThan(NotificationFlowLineRec, NotificationFlowLineRec.FieldNo(Frequency), TempErrorMessageRec."Message Type"::Error, 1);
            until NotificationFlowLineRec.Next() = 0;

        if TempErrorMessageRec.HasErrors(false) then
            TempErrorMessageRec.ShowErrorMessages(true);
    end;

    procedure GetDateTimeForMailSchedule(var Rec: Record "Notification Flow Line"; PreviousMailScheduledDateTime: DateTime): DateTime
    var
        NotficationSetup: Record "Business Notification Setup";
    begin
        NotficationSetup.Get();
        exit(PreviousMailScheduledDateTime + Round(((NotficationSetup."End Time" - NotficationSetup."Start Time") / Rec.Frequency), 1, '='));
    end;

    procedure InsertNotifyQueue(NotificationFlowCode: Code[20]; var NotifiyFlowLine: Record "Notification flow line"; var RecordRef: RecordRef)
    var
        EmployeeRec: record "Employee";
        NotificationHeader: Record "Notification Flow Header";
        NotificationQueue: Record "Notification Queue";
        SalesPurchaserRec: record "Salesperson/Purchaser";
        UserRec: record "User";
        //RecRef: RecordRef;
        FldRef: FieldRef;
        MailScheduledDateTime: DateTime;
        FrequencyCount: Integer;
        FieldValue: Text;
    begin
        NotificationHeader.Get(NotificationFlowCode);
        FrequencyCount := 1;
        MailScheduledDateTime := this.GetFirstMailScheduledDateTime();
        repeat
            NotificationQueue.Init();
            NotificationQueue.Validate("Notification Workflow Code", NotificationFlowCode);
            NotificationQueue.Validate("Line No.", NotifiyFlowLine."Line No.");
            if FrequencyCount <> 1 then
                MailScheduledDateTime := this.GetDateTimeForMailSchedule(NotifiyFlowLine, MailScheduledDateTime);
            NotificationQueue.Validate("Mail Scheduled DateTime", MailScheduledDateTime);
            NotificationQueue.Validate("Range Name", NotifiyFlowLine."Range Name");
            NotificationQueue.Validate("User Group", NotifiyFlowLine."Recipient Code");
            NotificationQueue.Validate("Content", NotifiyFlowLine.Content);
            NotificationQueue.Validate("Table No.", NotificationHeader."Table ID");
            NotificationQueue.Validate("Record Id", RecordRef.RecordId);
            NotificationQueue.Validate("Notification Group", NotifiyFlowLine."Notification Group");
            NotificationQueue.Validate("Notification Recipient Type", NotifiyFlowLine."Notification Recipient Type");
            case NotifiyFlowLine."Notification Recipient Type" of
                NotifiyFlowLine."Notification Recipient Type"::User:
                    begin

                        FldRef := RecordRef.Field(NotifiyFlowLine."Field ID");
                        FieldValue := FldRef.Value;
                        NotificationQueue.Validate("Notification Recipient", FieldValue);
                    end;
                NotifiyFlowLine."Notification Recipient Type"::Employee:
                    begin

                        FldRef := RecordRef.Field(NotifiyFlowLine."Field ID");
                        FieldValue := FldRef.Value;
                        NotificationQueue.Validate("Notification Recipient", FieldValue);
                    end;
                NotifiyFlowLine."Notification Recipient Type"::"Salespeople/Purchaser":
                    begin

                        FldRef := RecordRef.Field(NotifiyFlowLine."Field ID");
                        FieldValue := FldRef.Value;
                        NotificationQueue.Validate("Notification Recipient", FieldValue);
                    end;
            end;
            NotificationQueue.Insert(true);
            FrequencyCount += 1;
        until NotifiyFlowLine.Frequency < FrequencyCount;
    end;

    procedure GetFirstMailScheduledDateTime(): DateTime
    var
        NotficationSetup: Record "Business Notification Setup";
    begin
        NotficationSetup.Get();
        exit(CreateDateTime(WorkDate(), NotficationSetup."Start Time"));
    end;
    #endregion

    procedure GetReportandLayoutCode(var Reportselections: Record "Report Selections-Notif"; var ReportId: Integer; var LayoutCode: Code[250]; IsAttachment: Boolean)
    begin
        Reportselections.Reset();
        Reportselections.SetRange(Usage, Reportselections.Usage::"Business Notification");
        if IsAttachment then
            Reportselections.SetRange("Use for Email Attachment", true)
        else
            Reportselections.SetRange("Use for Email Body", true);
        if Reportselections.Findfirst() then begin
            if not IsAttachment then
                LayoutCode := Reportselections."Email Body Layout Name"
            else
                LayoutCode := Reportselections."Report Layout Name";
            ReportId := Reportselections."Report ID";
            // if ReportLayoutSelection.Get(ReportId, CompanyName) then;
            ReportLayoutSelection.SetRange("Report ID", ReportId);
            if ReportLayoutSelection.FindFirst() then;
            // if SelectedReportLayoutList.Get(ReportId, Reportselections."Report Layout Name") then
            SelectedReportLayoutList.SetRange("Report ID", ReportId);
            SelectedReportLayoutList.SetRange(Name, Reportselections."Report Layout Name");
            if SelectedReportLayoutList.FindFirst() then
                SetDefaultReportLayoutSelection();
        end;
    end;

    procedure SetDefaultReportLayoutSelection()
    begin
        // Add to TenantReportLayoutSelection table with an Empty Guid.
        AddLayoutSelection();
        // Add to the report layout selection table
        // if ReportLayoutSelection.get(ReportSelection."Report ID", CompanyName) then begin
        //     //ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
        //     // ReportLayoutSelection.Modify(true);
        // end else begin
        //     ReportLayoutSelection."Report ID" := ReportSelection."Report ID";
        //     ReportLayoutSelection."Company Name" := CompanyName;
        //     ReportLayoutSelection."Custom Report Layout Code" := '';
        //     ReportLayoutSelection.Type := ReportLayoutSelection.Type::"Word (built-in)";
        //     ReportLayoutSelection.Insert(true);
        // end;
        //  Message(DefaultLayoutSetTxt, SelectedReportLayoutList."Caption", SelectedReportLayoutList."Report Name");
    end;

    local procedure AddLayoutSelection()
    begin
        TenantReportLayoutSelection.Init();
        TenantReportLayoutSelection."App ID" := SelectedReportLayoutList."Application ID";
        TenantReportLayoutSelection."Company Name" := CompanyName;
        TenantReportLayoutSelection."Layout Name" := SelectedReportLayoutList."Name";
        TenantReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
        TenantReportLayoutSelection."User ID" := EmptyGuid;
        if not TenantReportLayoutSelection.Insert(true) then
            TenantReportLayoutSelection.Modify(true);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Notification flow line", OnAfterValidateEvent, "Notification Group", true, true)]
    local procedure OnBAfterInsertNotificationLine(var Rec: Record "Notification flow line")
    var
        NotificFlowHdr: Record "Notification Flow Header";
    begin
        if NotificFlowHdr.Get(Rec."No.") then
            Rec.Validate("Table ID", NotificFlowHdr."Table ID");
    end;

    var
        SelectedReportLayoutList: Record "Report Layout List";
        ReportLayoutSelection: Record "Report Layout Selection";
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        EmptyGuid: Guid;

}
