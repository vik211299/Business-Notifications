page 83009 "Notification Flow Card"
{
    Caption = 'Notification Flow Card';
    PageType = Card;
    SourceTable = "Notification Flow Header";
    RefreshOnActivate = true;
    ApplicationArea = all;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = not Rec.Active;
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field.';
                    trigger OnValidate()
                    var
                        NotificationFlowCard: page "Notification Flow Card";
                    begin
                        if (Rec."Table ID" <> 0) and (Rec."Table ID" <> xRec."Table ID") then begin
                            Clear(Rec."Filter Blob");
                            NotificationFlowCard.SetRecord(Rec);
                            CurrPage.Close();
                            NotificationFlowCard.Run();
                        end;
                    end;

                }
                field("Table Name"; Rec."Table Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field.';
                }
                field("Field ID"; Rec."Field ID")
                {
                    ToolTip = 'Specifies the value of the Field ID field.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Field Name field.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Field Type field.';
                }
                field("Field Threshold"; Rec."Field Threshold")
                {
                    Editable = (Rec."Field Type" = Rec."Field Type"::Integer) or (Rec."Field Type" = Rec."Field Type"::Decimal);
                    ToolTip = 'Specifies the value of the Field Threshold field.';
                    Visible = false;
                }
                field(TableFilter; this.GlobalFilterText)
                {
                    Caption = 'Table Filter';
                    ToolTip = 'Specifies the value of the Filter field.';
                    MultiLine = true;
                    Editable = false;
                    trigger OnValidate()
                    begin
                        Error('');
                    end;

                    trigger OnAssistEdit()
                    begin
                        if Rec.Active then
                            exit;
                        this.GetFilterFromFilterBuilder();
                    end;
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies the value of the Active field.';
                }
                field("Page ID"; Rec."Page ID")
                {
                    ToolTip = 'Specifies the value of the Page ID field.';
                }
                field(Header; Rec.Header)
                {
                    ToolTip = 'Specifies the value of the Header field.';
                }
                field(Footer; Rec.Footer)
                {
                    ToolTip = 'Specifies the value of the Footer field.';
                }
            }
            part("Notification Flow Subform"; "Notification Flow Subform")
            {
                Editable = not Rec.Active;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Process)
            {
                actionref(EnableNotificationFlow; "Activate Notification Flow")
                {
                }
                actionref(DisableNotificationFlow; "Deactivate Notification Flow")
                {
                }
                actionref(SetLayoutF; "Set Layout")
                { }
                actionRef(NotificationSubject_Promoted; NotificationSubject)
                {
                }

            }
        }
        area(Processing)
        {
            action("Activate Notification Flow")
            {
                Image = Approve;
                ToolTip = 'Activates Notification Flow';
                Enabled = not Rec.Active;
                Visible = not Rec.Active;
                trigger OnAction()
                var
                    BusinessNotificationMgmt: Codeunit "Business Notification Mgmt.";
                begin
                    BusinessNotificationMgmt.ActivateNotificationFlow(Rec);
                end;
            }
            action("Deactivate Notification Flow")
            {
                Image = Reject;
                ToolTip = 'Deactivates Notification Flow';
                Enabled = Rec.Active;
                Visible = Rec.Active;
                trigger OnAction()
                var
                    BusinessNotificationMgmt: Codeunit "Business Notification Mgmt.";
                begin
                    BusinessNotificationMgmt.DeactivateNotificationFlow(Rec);
                    CurrPage.Editable(true);
                    CurrPage.Update(true);
                end;
            }
            action("Set Layout")
            {
                Enabled = not Rec.Active;
                Visible = false;
                Caption = 'Mail Body';
                Image = Report;
                ApplicationArea = All;
                RunObject = page "Report Selection - Notif";
                RunPageLink = "Notification No." = field("No."), "Notification Line No." = const(0);
            }
            action(NotificationSubject)
            {
                ApplicationArea = all;
                Caption = 'Notification Subject';
                Image = Email;
                Visible = false;
                RunObject = page "Notification Subject page";
                RunPageLink = "Notification No." = field("No."), "Table ID" = field("Table ID"), "Notification Line No." = const(0);
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        this.GetFilterFromFilterBlob();
    end;

    local procedure GetFilterFromFilterBuilder()
    var
        AllObjectsWithCaption: Record AllObjWithCaption;
        FilterPageBuilderPage: FilterPageBuilder;
        OutStream: OutStream;
    begin

        this.GetFilterFromFilterBlob();
        FilterPageBuilderPage.AddTable(Rec."Table Name", Rec."Table ID");
        if this.GlobalFilterText <> '' then
            FilterPageBuilderPage.SetView(Rec."Table Name", this.GlobalFilterText);
        AllObjectsWithCaption.Get(AllObjectsWithCaption."Object Type"::Table, Rec."Table ID");
        FilterPageBuilderPage.PageCaption := AllObjectsWithCaption."Object Caption";
        if FilterPageBuilderPage.RunModal() then begin
            Rec."Filter Blob".CreateOutStream(OutStream);
            OutStream.WriteText(FilterPageBuilderPage.GetView(Rec."Table Name"));
            Rec.Modify(true);
        end;
        this.GetFilterFromFilterBlob();
    end;

    local procedure GetFilterFromFilterBlob()
    var
        InStream: InStream;
    begin
        Rec.CalcFields("Filter Blob");
        if not Rec."Filter Blob".HasValue() then
            exit;
        Rec."Filter Blob".CreateInStream(InStream);
        InStream.ReadText(this.GlobalFilterText);
    end;

    var
        GlobalFilterText: Text;
}
