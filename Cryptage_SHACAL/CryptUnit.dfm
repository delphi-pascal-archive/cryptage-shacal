object CryptForm: TCryptForm
  Left = 254
  Top = 134
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Cryptage SHACAL'
  ClientHeight = 217
  ClientWidth = 498
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 120
  TextHeight = 17
  object LblPassword: TLabel
    Left = 280
    Top = 8
    Width = 85
    Height = 17
    Caption = 'Mot de passe:'
  end
  object LblData: TLabel
    Left = 8
    Top = 8
    Width = 103
    Height = 17
    Caption = 'Chaine a chiffrer:'
  end
  object LblCryptValue: TLabel
    Left = 8
    Top = 64
    Width = 94
    Height = 17
    Caption = 'Chaine chiffree:'
  end
  object LblDecrypt: TLabel
    Left = 280
    Top = 64
    Width = 107
    Height = 17
    Caption = 'Chaine dechiffrer:'
  end
  object LblHash: TLabel
    Left = 8
    Top = 120
    Width = 63
    Height = 17
    Caption = 'Signature:'
  end
  object EdtPassword: TEdit
    Left = 280
    Top = 32
    Width = 209
    Height = 25
    TabOrder = 1
    Text = '< Your password >'
  end
  object EdtData: TEdit
    Left = 8
    Top = 32
    Width = 209
    Height = 25
    TabOrder = 0
    Text = '< Your plain text >'
  end
  object EdtCrypt: TEdit
    Left = 8
    Top = 88
    Width = 209
    Height = 25
    ReadOnly = True
    TabOrder = 2
  end
  object BtnTest: TButton
    Left = 8
    Top = 184
    Width = 209
    Height = 25
    Caption = 'Chiffrer - Dechiffrer'
    TabOrder = 6
    OnClick = BtnCryptClick
  end
  object BtnCancel: TButton
    Left = 416
    Top = 184
    Width = 73
    Height = 25
    Caption = 'Exit'
    TabOrder = 7
    OnClick = BtnCancelClick
  end
  object EdtEncrypt: TEdit
    Left = 280
    Top = 88
    Width = 209
    Height = 25
    ReadOnly = True
    TabOrder = 3
  end
  object EdtHash: TEdit
    Left = 8
    Top = 144
    Width = 481
    Height = 25
    ReadOnly = True
    TabOrder = 4
  end
  object BtnHash: TButton
    Left = 224
    Top = 184
    Width = 185
    Height = 25
    Caption = 'Signer'
    TabOrder = 5
    OnClick = BtnHashClick
  end
end
