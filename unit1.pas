unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit_Count: TEdit;
    Edit_width: TEdit;
    Edit_height: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label4: TLabel;
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
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioGroup1: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
   {prices in euro, 22.03.2023 }
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
   General_Dispatch:Integer         = 1;
   Shipping_Regular_DE:Integer      = 2;
   Shipping_Regular_DE_UPS:Integer  = 1;
   Shipping_Regular_Int:Integer     = 20;
   Shipping_Regular_Int_UPS:Integer = 3;


procedure TForm1.Button1Click(Sender: TObject);
var w,h:double;
    n:integer;
    days,shipping:Integer;
    fs:TFormatSettings;
begin
  fs:=FormatSettings;
  fs.DecimalSeparator:='.';

  w:=StrToFloat(StringReplace(Edit_width.Text , ',','.',[rfReplaceAll]),fs);
  h:=StrToFloat(StringReplace(Edit_height.Text, ',','.',[rfReplaceAll]),fs);

  n:=StrToInt  (StringReplace(Edit_count.Text , ',','.',[rfReplaceAll]));
  while(n mod Beauti_multiple) <> 0 do
     inc(n);

  if RadioButton2.Checked then        shipping := Shipping_Regular_DE_UPS
  else if RadioButton3.Checked then   shipping := Shipping_Regular_Int
  else if RadioButton4.Checked then   shipping := Shipping_Regular_Int_UPS
  else                                shipping := Shipping_Regular_DE;

  days := General_Dispatch + shipping;

  Label_Beauti_Budget2L.Caption := FloatToStrF((1.0+VAT_DE)*(Beauti_Budget2L_JobFee + (w*h)*0.01*Beauti_Budget2L_sqcm*n),ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_Budget2L_PCB) + ' working days)';
  Label_Beauti_Blitz2L.Caption  := FloatToStrF((1.0+VAT_DE)*(Beauti_Blitz2L_JobFee  + (w*h)*0.01*Beauti_Blitz2L_sqcm *n),ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_Blitz2L_PCB ) + ' working days)';
  Label_Beauti_HD2L.Caption     := FloatToStrF((1.0+VAT_DE)*(Beauti_HD2L_JobFee     + (w*h)*0.01*Beauti_HD2L_sqcm    *n),ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_HD2L_PCB    ) + ' working days)';
  Label_Beauti_HD4L.Caption     := FloatToStrF((1.0+VAT_DE)*(Beauti_HD4L_JobFee     + (w*h)*0.01*Beauti_HD4L_sqcm    *n),ffFixed,10,2) + '€ (' + IntToStr(n) + ' boards, ' + IntToStr(days + Beauti_HD4L_PCB    ) + ' working days)';

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  memo1.lines.add('This tool *estimates* prices and shipping time, acc. to the informations');
  memo1.lines.add('on the aisler.net webpage. Use at this tool at Your Own Risk.');
  memo1.lines.add('');
  memo1.lines.Add('Selecting shipping other that default may cause extra costs.');
  memo1.lines.add('');
  memo1.lines.add('Beautiful Budget 2L: width:0.20,  spacing:0.15  drill=0.3, milling:2.4, slots:n');
  memo1.lines.add('Beautiful Blitz  2L: width:0.20,  spacing:0.15  drill=0.3, milling:2.4, slots:n');
  memo1.lines.add('Beautiful HD  2L/4L: width:0.125, spacing:0.125 drill=0.2, milling:1.6, slots:y');
  memo1.ReadOnly:=true;


end;

end.

