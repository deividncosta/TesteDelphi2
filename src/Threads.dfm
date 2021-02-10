object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 299
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object edtNumero: TEdit
    Left = 40
    Top = 32
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 0
  end
  object edtTempo: TEdit
    Left = 167
    Top = 32
    Width = 121
    Height = 21
    NumbersOnly = True
    TabOrder = 1
  end
  object Button1: TButton
    Left = 294
    Top = 30
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ProgressBar1: TProgressBar
    Left = 40
    Top = 59
    Width = 248
    Height = 17
    TabOrder = 3
  end
  object Memo1: TMemo
    Left = 40
    Top = 82
    Width = 248
    Height = 209
    Lines.Strings = (
      'Memo1')
    TabOrder = 4
  end
end
