object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Test DB Connection'
  ClientHeight = 239
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 56
    Top = 24
    Width = 137
    Height = 49
    Caption = 'Connect DB'
    TabOrder = 0
    OnClick = Button1Click
  end
  object DBGrid1: TDBGrid
    Left = 56
    Top = 88
    Width = 320
    Height = 120
    DataSource = DataSource1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Button2: TButton
    Left = 239
    Top = 24
    Width = 137
    Height = 49
    Caption = 'Open Query'
    TabOrder = 2
    OnClick = Button2Click
  end
  object DataSource1: TDataSource
    Left = 216
    Top = 128
  end
end
