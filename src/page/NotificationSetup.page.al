page 83111 "Custom Notification Setup"
{
    PageType = Card;
    SourceTable = "Business Notification Setup";
    ApplicationArea = All;
    Caption = 'Business Notification Flow Setup';
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                }
                field("End Time"; Rec."End Time")
                {
                    ApplicationArea = All;
                }
                // Add more fields as needed
            }
        }
    }

    actions
    {
        area(processing)
        {
            // Add actions if needed
        }
    }
}