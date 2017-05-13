unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Menus, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    MenuItem2: TMenuItem;
    PopupMenu1: TPopupMenu;
    StaticText1: TStaticText;
    TrayIcon1: TTrayIcon;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

// Code from:
// http://stackoverflow.com/questions/20669917/one-instance-of-app-per-computer-how
function IsSingleInstance(MutexName: string; KeepMutex: boolean = True): boolean;
const
  MUTEX_GLOBAL = 'Global\';

var
  MutexHandel: THandle;
  SecurityDesc: TSecurityDescriptor;
  SecurityAttr: TSecurityAttributes;
  ErrCode: integer;
begin
  InitializeSecurityDescriptor(@SecurityDesc, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@SecurityDesc, True, nil, False);
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.lpSecurityDescriptor := @SecurityDesc;
  SecurityAttr.bInheritHandle := False;

  MutexHandel := CreateMutex(@SecurityAttr, True, PChar(MUTEX_GLOBAL + MutexName));
  ErrCode := GetLastError;

  if {(MutexHandel = 0) or }(ErrCode = ERROR_ALREADY_EXISTS) then
  begin
    Result := False;
    closeHandle(MutexHandel);
  end
  else
  begin
    Result := True;

    if not KeepMutex then
      CloseHandle(MutexHandel);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  IsSingleInstance('MsWinZonesCacheCounterMutexA');
  TrayIcon1.Visible := True;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Application.Minimize;
end;

end.
