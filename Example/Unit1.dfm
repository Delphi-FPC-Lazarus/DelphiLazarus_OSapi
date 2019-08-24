object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'Test'
  ClientHeight = 512
  ClientWidth = 894
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
  object Label1: TLabel
    Left = 640
    Top = 212
    Width = 50
    Height = 13
    Caption = 'Parameter'
  end
  object btnProp: TButton
    Left = 8
    Top = 207
    Width = 140
    Height = 25
    Caption = 'btnProp'
    TabOrder = 0
    OnClick = btnPropClick
  end
  object btnOpenWith: TButton
    Left = 8
    Top = 238
    Width = 140
    Height = 25
    Caption = 'btnOpenWith'
    TabOrder = 1
    OnClick = btnOpenWithClick
  end
  object btnCopyFilsToClipboard: TButton
    Left = 160
    Top = 207
    Width = 140
    Height = 25
    Caption = 'btnCopyFilsToClipboard'
    TabOrder = 2
    OnClick = btnCopyFilsToClipboardClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 878
    Height = 193
    TabOrder = 3
  end
  object btnExec: TButton
    Left = 559
    Top = 207
    Width = 75
    Height = 25
    Caption = 'btnExec'
    TabOrder = 4
    OnClick = btnExecClick
  end
  object edpar: TEdit
    Left = 696
    Top = 207
    Width = 50
    Height = 21
    TabOrder = 5
  end
  object RadioButton1: TRadioButton
    Left = 560
    Top = 241
    Width = 113
    Height = 17
    Caption = 'GetConsoleOutput'
    Checked = True
    TabOrder = 6
    TabStop = True
  end
  object RadioButton2: TRadioButton
    Left = 679
    Top = 241
    Width = 113
    Height = 17
    Caption = 'ExecuteProcess'
    TabOrder = 7
  end
  object btnCopyDirContent: TButton
    Left = 160
    Top = 238
    Width = 140
    Height = 25
    Caption = 'btnCopyDirContent'
    TabOrder = 8
    OnClick = btnCopyDirContentClick
  end
  object btnShellExec: TButton
    Left = 312
    Top = 207
    Width = 140
    Height = 25
    Caption = 'btnShellExec'
    TabOrder = 9
    OnClick = btnShellExecClick
  end
  object btnFileSizeLarge: TButton
    Left = 312
    Top = 238
    Width = 140
    Height = 25
    Caption = 'btnFileSizeLarge'
    TabOrder = 10
    OnClick = btnFileSizeLargeClick
  end
  object memOut: TMemo
    Left = 559
    Top = 264
    Width = 327
    Height = 113
    TabOrder = 11
  end
  object memErr: TMemo
    Left = 559
    Top = 383
    Width = 327
    Height = 113
    TabOrder = 12
  end
  object OpenDialog1: TOpenDialog
    Left = 120
    Top = 320
  end
end
