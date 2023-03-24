unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox_StencilDoubleSided: TCheckBox;
    CheckBox_VAT: TCheckBox;
    Edit_Count: TEdit;
    Edit_width: TEdit;
    Edit_height: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label4: TLabel;
    Label_Beauti_HD6L: TLabel;
    Label9: TLabel;
    Label_Beauti_HD2L: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label_Beauti_Budget2L: TLabel;
    Label5: TLabel;
    Label_Beauti_Blitz2L: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label_Beauti_HD4L: TLabel;
    Memo1: TMemo;
    RadioBtn_DE_Post: TRadioButton;
    RadioBtn_DE_UPS: TRadioButton;
    RadioBtn_DE_UPS_express: TRadioButton;
    RadioBtn_INT_Post: TRadioButton;
    RadioBtn_INT_UPS: TRadioButton;
    RadioBtn_INT_UPS_express: TRadioButton;
    RadioBtn_NoStencil: TRadioButton;
    RadioBtn_Stencil: TRadioButton;
    RadioBtn_StencilRapid: TRadioButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

function EstimateArrival(BusinessDays:Integer):TDate;
function EasterSunday(Year4digit:word):TDate;
function IsGermanHolyday(date:TDate):boolean;

var
  Form1: TForm1;

implementation

{$R *.lfm}
uses DateUtils;


const
   {prices in euro (excl VAT),
    22.03.2023
    https://community.aisler.net/t/our-simple-pricing/102
    }
   Beauti_Budget2L_JobFee:double = 12.0;  { 2022: 6.0  }
   Beauti_Budget2L_sqcm:double   = 0.042;
   Beauti_Blitz2L_JobFee:double  = 16.0;  { 2022: 12.0 }
   Beauti_Blitz2L_sqcm:double    = 0.084;
   Beauti_HD2L_JobFee:double     = 12.0;  { 2022: 6.0  }
   Beauti_HD2L_sqcm:double       = 0.084;
   Beauti_HD4L_JobFee:double     = 12.0;  { 2022: 6.0  }
   Beauti_HD4L_sqcm:double       = 0.117;
   Beauti_HD6L_JobFee:double     = 12.0;  { since Dec. 2022 }
   Beauti_HD6L_sqcm:double       = 0.146;

   VAT_DE:double                     = 0.19;
   Shipping_UPS_costs:double         = 17.85;
   Shipping_UPS_express_costs:double = 23.80;

   Stellar_Stencil_JobFee:double     = 5.0;
   Stellar_Stencil_sqcm:double       = 0.095;
   Stellar_Stencil_rapid:double      = 8.40;  { 10.00 / (1.0 + VAT_DE) }

   {multiple number of PCBs}
   Beauti_multiple:Integer       = 3;

{
   Amazing_Assembly:Integer         = 8;
}

   {delivery days}
   Beauti_Budget2L_PCB:Integer      = 10;
   Beauti_Blitz2L_PCB:Integer       = 2;
   Beauti_HD2L_PCB:Integer          = 5;
   Beauti_HD4L_PCB:Integer          = 7;
   Beauti_HD6L_PCB:Integer          = 10;
   General_Dispatch:Integer         = 1;
   Shipping_Regular_DE:Integer      = 2;
   Shipping_Regular_DE_UPS:Integer  = 2;
   Shipping_Express_DE_UPS:Integer  = 1;
   Shipping_Regular_Int:Integer     = 20;
   Shipping_Regular_Int_UPS:Integer = 20; { undefined, as per country. }
   Shipping_Express_Int_UPS:Integer = 3;


procedure TForm1.Button1Click(Sender: TObject);
var w,h,sqcm:double;
    n:integer;
    days,shipping:Integer;
    fs:TFormatSettings;
    sum,tmp,stencil:double;
    arrival:TDate;
begin
  fs:=FormatSettings;
  fs.DecimalSeparator:='.';

  w:=StrToFloat(StringReplace(Edit_width.Text , ',','.',[rfReplaceAll]),fs);
  h:=StrToFloat(StringReplace(Edit_height.Text, ',','.',[rfReplaceAll]),fs);
  sqcm :=  (w*h)*0.01;

  n:=StrToInt  (StringReplace(Edit_count.Text , ',','.',[rfReplaceAll]));
  while(n mod Beauti_multiple) <> 0 do
     inc(n);

  { shipping time }
       if RadioBtn_DE_Post.Checked then           shipping := Shipping_Regular_DE
  else if RadioBtn_DE_UPS.Checked then            shipping := Shipping_Regular_DE_UPS
  else if RadioBtn_DE_UPS_express.Checked then    shipping := Shipping_Express_DE_UPS
  else if RadioBtn_INT_Post.Checked then          shipping := Shipping_Regular_Int
  else if RadioBtn_INT_UPS.Checked then           shipping := Shipping_Regular_Int_UPS
  else if RadioBtn_INT_UPS_express.Checked then   shipping := Shipping_Express_Int_UPS
  else                                            shipping := Shipping_Regular_DE;
  days := General_Dispatch + shipping;

  { shipping costs }
       if RadioBtn_DE_UPS.Checked then            tmp := Shipping_UPS_costs
  else if RadioBtn_INT_UPS.Checked then           tmp := Shipping_UPS_costs
  else if RadioBtn_DE_UPS_express.Checked then    tmp := Shipping_UPS_express_costs
  else if RadioBtn_INT_UPS_express.Checked then   tmp := Shipping_UPS_express_costs
  else                                            tmp := 0; { default: free shipping. }

  { stencil }
  if RadioBtn_Stencil.Checked or RadioBtn_StencilRapid.Checked then
     begin
     stencil := Stellar_Stencil_JobFee + sqcm*Stellar_Stencil_sqcm;
     if CheckBox_StencilDoubleSided.Checked then
        stencil *= 2.0;
     if RadioBtn_StencilRapid.Checked then
        stencil += Stellar_Stencil_rapid;
     tmp += stencil;
     end;


  { beauty 2-layer}
  sum := tmp;
  sum += Beauti_Budget2L_JobFee + sqcm*Beauti_Budget2L_sqcm * n;
  arrival := EstimateArrival(days + Beauti_Budget2L_PCB);
  if CheckBox_VAT.checked then
     sum *= (1.0 + VAT_DE);
  Label_Beauti_Budget2L.Caption := FloatToStrF(sum,ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_Budget2L_PCB) + ' working days: ' + DateToStr(arrival) + ')';

  { beauty 2-layer express}
  sum := tmp;
  sum += Beauti_Blitz2L_JobFee + sqcm*Beauti_Blitz2L_sqcm * n;
  arrival := EstimateArrival(days + Beauti_Blitz2L_PCB);
  if CheckBox_VAT.checked then
     sum *= (1.0 + VAT_DE);
  Label_Beauti_Blitz2L.Caption := FloatToStrF(sum,ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_Blitz2L_PCB) + ' working days: ' + DateToStr(arrival) + ')';

  { beauty HD 2-layer}
  sum := tmp;
  sum += Beauti_HD2L_JobFee + sqcm*Beauti_HD2L_sqcm * n;
  arrival := EstimateArrival(days + Beauti_HD2L_PCB);
  if CheckBox_VAT.checked then
     sum *= (1.0 + VAT_DE);
  Label_Beauti_HD2L.Caption := FloatToStrF(sum,ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_HD2L_PCB) + ' working days: ' + DateToStr(arrival) + ')';

  { beauty HD 4-layer}
  sum := tmp;
  sum += Beauti_HD4L_JobFee + sqcm*Beauti_HD4L_sqcm * n;
  arrival := EstimateArrival(days + Beauti_HD4L_PCB);
  if CheckBox_VAT.checked then
     sum *= (1.0 + VAT_DE);
  Label_Beauti_HD4L.Caption := FloatToStrF(sum,ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_HD4L_PCB) + ' working days: ' + DateToStr(arrival) + ')';

  { beauty HD 6-layer}
  sum := tmp;
  sum += Beauti_HD6L_JobFee + sqcm*Beauti_HD6L_sqcm * n;
  arrival := EstimateArrival(days + Beauti_HD6L_PCB);
  if CheckBox_VAT.checked then
     sum *= (1.0 + VAT_DE);
  Label_Beauti_HD6L.Caption := FloatToStrF(sum,ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_HD6L_PCB) + ' working days: ' + DateToStr(arrival) + ')';

  EstimateArrival(13);
end;

function DayOfTheWeek(Day:TDate):Integer;
begin
  { DayOfWeek returns the day of the week from DateTime.
    Sunday is counted as day 1, Saturday is counted as day 7. }
  Result := DayOfWeek(Day) - 1;
  if Result = 0 then
     Result := 7;
end;

function EstimateArrival(BusinessDays:Integer):TDate;
var
  NextDay:TDate;
begin
  NextDay := ceil(now()); { tomorrow 0:00 }

  { skip weekends for begin }
  if DayOfTheWeek(NextDay) = 6 then {Saturday, next is Monday.}
     NextDay += 2.0
  else if DayOfTheWeek(NextDay) = 7 then {Sunday, next is Monday.}
     NextDay += 1.0;

  while(BusinessDays > 0) do
     begin
     NextDay += 1.0;
     if DayOfTheWeek(NextDay) > 5 then
        continue;
     if IsGermanHolyday(NextDay) then
        continue;
     dec(BusinessDays);
     end;

  Result := NextDay;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  memo1.lines.add('This tool *estimates* prices and shipping time, acc. to the informations on the aisler.net webpage.');
  memo1.lines.add('It may or may not calculate as expected and is intended to give an rough overview of ordering or');
  memo1.lines.add('design possibilities. It is my private tool and just shared with others.');
  memo1.lines.add('Use at this tool at Your Own Risk. If you find more precise estimations, based on formulas and');
  memo1.lines.add('its references, you may create an github issue. Similarly, this code might be compiled on Linux');
  memo1.lines.add('as well. Project page is https://github.com/wirbel-at-vdr-portal/aisl_PCB_costs');
  memo1.lines.add('--wirbel');
  memo1.lines.add('');
  memo1.lines.add('');
  memo1.lines.Add('Selecting shipping other than default may cause extra costs.');
  memo1.lines.add('');
  memo1.lines.add('Beautiful Budget 2L   : width:0.20,  spacing:0.15  drill=0.3, milling:2.4, slots:n');
  memo1.lines.add('Beautiful Blitz  2L   : width:0.20,  spacing:0.15  drill=0.3, milling:2.4, slots:n');
  memo1.lines.add('Beautiful HD  2L/4L/6L: width:0.125, spacing:0.125 drill=0.2, milling:1.6, slots:y');
  memo1.lines.add('');
  memo1.ReadOnly:=true;
end;



{ algo: Carl Friedrich Gauß }
function EasterSunday(Year4digit:word):TDate;
var
  a,b,c,d,e,offset:Integer;
  NewYear:TDate;
begin
  a := Year4digit mod 19;
  b := Year4digit mod 4;
  c := Year4digit mod 7;
  d := (a * 19 + 24) mod 30;
  e := (b * 2 + c * 4 + d * 6 + 5) mod 7;
  offset := 22 + d + e;
  NewYear := EncodeDate(Year4digit,1,1);
  EasterSunday := NewYear + offset;
end;

function IsGermanHolyday(date:TDate):boolean;
var
  year,month,day:word;

  Neujahr,
  Maifeiertag,
  TagDerDeutschenEinheit,
  Allerheiligen,
  ErsterWeihnachtstag,
  ZweiterWeihnachtstag,
  OsterSonntag,
  Rosenmontag,
  Fastnachtsdienstag,
  Karfreitag,
  Ostermontag,
  Himmelfahrt,
  Pfingstsonntag,
  Pfingstmontag,
  Fronleichnam :TDate;
begin
  Result := true;
  DecodeDate(date,year,month,day);

  Neujahr := EncodeDate(year,1,1); { 1.January }
  if IsSameDay(date, Neujahr) then exit;

  Maifeiertag := EncodeDate(year,5,1); { 1.May }
  if IsSameDay(date, Maifeiertag) then exit;

  TagDerDeutschenEinheit := EncodeDate(year,10,3); { 3.October }
  if IsSameDay(date, TagDerDeutschenEinheit) then exit;

  Allerheiligen := EncodeDate(year,11,1); { 1.November }
  if IsSameDay(date, Allerheiligen) then exit;

  ErsterWeihnachtstag := EncodeDate(year,12,25); { 25.December }
  if IsSameDay(date, ErsterWeihnachtstag) then exit;

  ZweiterWeihnachtstag := EncodeDate(year,12,26); { 26.December }
  if IsSameDay(date, ZweiterWeihnachtstag) then exit;

  { OsterSonntag = first sunday after first full moon after
    beginning of spring (21. March) }
  OsterSonntag := EasterSunday(year);
  if IsSameDay(date, OsterSonntag) then exit;

  Rosenmontag := OsterSonntag - 48.0; { 48 days before easter sunday }
  if IsSameDay(date, Rosenmontag) then exit;

  Fastnachtsdienstag  := OsterSonntag - 47.0; { 47 days before easter sunday }
  if IsSameDay(date, Fastnachtsdienstag) then exit;

  Karfreitag := OsterSonntag -  2.0; { 2 days before easter sunday }
  if IsSameDay(date, Karfreitag) then exit;

  Ostermontag := OsterSonntag +  1.0; { 1 day after easter sunday }
  if IsSameDay(date, Ostermontag) then exit;

  Himmelfahrt := OsterSonntag + 39.0; { 39 days after easter sunday }
  if IsSameDay(date, Himmelfahrt) then exit;

  Pfingstsonntag := OsterSonntag + 49.0; { 49 days after easter sunday }
  if IsSameDay(date, Pfingstsonntag) then exit;

  Pfingstmontag := OsterSonntag + 50.0; { 50 days after easter sunday }
  if IsSameDay(date, Pfingstmontag) then exit;

  Fronleichnam := OsterSonntag + 60.0; { 60 days after easter sunday }
  if IsSameDay(date, Fronleichnam) then exit;

  Result := false;
end;

end.

