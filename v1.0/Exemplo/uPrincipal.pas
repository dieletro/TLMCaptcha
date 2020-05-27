unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  System.Generics.Collections, Vcl.Samples.Spin, System.Math, TLMCaptcha.Base,
  TLMCaptcha.Impl;

type
  TForm3 = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    Button1: TButton;
    spDificuldade: TSpinEdit;
    spNumCaracter: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    spTamanho: TSpinEdit;
    cbDistorcer: TCheckBox;
    cbMargens: TCheckBox;
    cbMultiCores: TCheckBox;
    Button2: TButton;
    Label4: TLabel;
    spAngulo: TSpinEdit;
    ComboBox1: TComboBox;
    Button3: TButton;
    txtValidar: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    spLarguraBorda: TSpinEdit;
    MyCaptcha: TCaptchaGenerator;
    Label7: TLabel;
    lblDivSize: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure ValidarCharSetMode;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  OAuth : String;
implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
begin
  with MyCaptcha do
  Begin
    Captcha := image1;
    NumeroDeCaracteres := spNumCaracter.Value;
    TamanhoCaptcha := spTamanho.Value;
    NivelDificuldade := spDificuldade.Value;
    AnguloDistCaracter := spAngulo.Value;
    LarguraBorda := spLarguraBorda.Value;

    ValidarCharSetMode;

    MultiCores := cbMultiCores.Checked;
    UsarMargens := cbMargens.Checked;
    Distorcao := cbDistorcer.Checked;

    OAuth := Gerar_imagem_captcha(image1).character;

    lblDivSize.Caption := DivSize.ToString;
  End;
end;

procedure TForm3.Button2Click(Sender: TObject);
var
 AFile: String;
begin
  try
    try
      AFile := ExtractFilePath(Application.ExeName)+'..\..\img\MyCaptcha.png';
      Image1.Picture.Bitmap.SaveToFile(AFile);
      Image1.Refresh;
    except on E: Exception do
      E.Message := 'Falha ao Salvar o arquivo '+E.Message;
    end;
  finally
    Showmessage('Arquivo salvo com sucesso em : '+AFile);
  end;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
  if txtValidar.Text = OAuth then
    ShowMessage('Parabéns, você acertou a combinação dos caracteres!')
  else
  Begin
    ShowMessage('O valor fornecido não corresponde!');
    //Gerar novo código
    OAuth := MyCaptcha.Gerar_imagem_captcha(image1).character;
  End;
end;

procedure TForm3.ComboBox1Change(Sender: TObject);
begin
  ValidarCharSetMode;
end;

procedure TForm3.ValidarCharSetMode;
begin
  with MyCaptcha do
  Begin
    case ComboBox1.ItemIndex of
      0: CharSetMODE := cmNUM;
      1: CharSetMODE := cmHEX;
      2: CharSetMODE := cmASCII_UPPER;
      3: CharSetMODE := cmASCII_LOWER;
      4: CharSetMODE := cmALL;
    End;
  end;
End;
end.
