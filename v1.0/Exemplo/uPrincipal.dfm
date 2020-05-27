object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'LMCaptcha Exemplo'
  ClientHeight = 473
  ClientWidth = 697
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 697
    Height = 344
    Align = alClient
    Picture.Data = {07544269746D617000000000}
    ExplicitLeft = 80
    ExplicitTop = 64
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object Panel1: TPanel
    Left = 0
    Top = 344
    Width = 697
    Height = 129
    Align = alBottom
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 9
      Width = 93
      Height = 13
      Caption = 'N'#237'vel de Dificuldade'
    end
    object Label2: TLabel
      Left = 8
      Top = 38
      Width = 108
      Height = 13
      Caption = 'N'#250'mero de Caracteres'
    end
    object Label3: TLabel
      Left = 8
      Top = 66
      Width = 102
      Height = 13
      Caption = 'Tamanho do Captcha'
    end
    object Label4: TLabel
      Left = 195
      Top = 38
      Width = 109
      Height = 13
      Caption = 'Angulo dos Caracteres'
    end
    object Label5: TLabel
      Left = 195
      Top = 94
      Width = 199
      Height = 13
      Caption = 'Confirme os Caracteres da Imagem acima'
    end
    object Label6: TLabel
      Left = 8
      Top = 94
      Width = 83
      Height = 13
      Caption = 'Largura da Borda'
    end
    object Label7: TLabel
      Left = 195
      Top = 66
      Width = 94
      Height = 13
      Caption = 'Tipo de  Caracteres'
    end
    object lblDivSize: TLabel
      Left = 485
      Top = 14
      Width = 34
      Height = 13
      Caption = 'DivSize'
    end
    object Button1: TButton
      Left = 575
      Top = 6
      Width = 114
      Height = 25
      Caption = 'Gerar'
      TabOrder = 0
      OnClick = Button1Click
    end
    object spDificuldade: TSpinEdit
      Left = 122
      Top = 6
      Width = 57
      Height = 22
      MaxValue = 5
      MinValue = 0
      TabOrder = 1
      Value = 2
    end
    object spNumCaracter: TSpinEdit
      Left = 122
      Top = 34
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 4
    end
    object spTamanho: TSpinEdit
      Left = 122
      Top = 62
      Width = 57
      Height = 22
      MaxValue = 5
      MinValue = 0
      TabOrder = 3
      Value = 2
    end
    object cbDistorcer: TCheckBox
      Left = 195
      Top = 9
      Width = 97
      Height = 17
      Caption = 'Distorcer'
      TabOrder = 4
    end
    object cbMargens: TCheckBox
      Left = 266
      Top = 9
      Width = 82
      Height = 17
      Caption = 'Usar Mergens'
      TabOrder = 5
    end
    object cbMultiCores: TCheckBox
      Left = 361
      Top = 9
      Width = 78
      Height = 17
      Caption = 'Multi Cores'
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object Button2: TButton
      Left = 575
      Top = 37
      Width = 114
      Height = 25
      Caption = 'Salvar Arquivo'
      TabOrder = 7
      OnClick = Button2Click
    end
    object spAngulo: TSpinEdit
      Left = 310
      Top = 35
      Width = 57
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 8
      Value = 0
    end
    object ComboBox1: TComboBox
      Left = 298
      Top = 62
      Width = 111
      Height = 21
      ItemIndex = 0
      TabOrder = 9
      Text = 'N'#250'meros'
      OnChange = ComboBox1Change
      Items.Strings = (
        'N'#250'meros'
        'Hexadecimal'
        'Letras Mai'#250'sculas'
        'Letras Min'#250'sculas'
        'Todos')
    end
    object Button3: TButton
      Left = 575
      Top = 90
      Width = 114
      Height = 22
      Caption = 'Validar'
      TabOrder = 10
      OnClick = Button3Click
    end
    object txtValidar: TEdit
      Left = 405
      Top = 91
      Width = 164
      Height = 21
      TabOrder = 11
    end
    object spLarguraBorda: TSpinEdit
      Left = 122
      Top = 90
      Width = 57
      Height = 22
      MaxValue = 5
      MinValue = 0
      TabOrder = 12
      Value = 2
    end
  end
  object MyCaptcha: TCaptchaGenerator
    DivSize = 160.000000000000000000
    FontSizeMin = 75
    FontSizeMax = 125
    Captcha = Image1
    Left = 296
    Top = 184
  end
end
