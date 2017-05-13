unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Menus, Windows, registry;

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
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
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
var r: TRegistry;
begin
  r := TRegistry.Create;
  try
    r.RootKey := HKEY_LOCAL_MACHINE;
    if r.OpenKey('\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', false) then begin
        r.WriteInteger('SMB1', 0);
    end else begin
      ShowMessage('Disabling SMB version 1. Please run again as Administrator');
    end;
  finally
    r.Free;
  end;
  IsSingleInstance('MsWinZonesCacheCounterMutexA');
  TrayIcon1.Visible := True;
end;

procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
  if Form1.WindowState = wsMinimized then begin
      form1.WindowState := wsNormal;
      form1.Hide;
      Form1.ShowInTaskBar := stNever;
  end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  Form1.Show;
  Form1.ShowInTaskBar := stDefault;
  Application.Restore;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=false;
  Application.Minimize;
end;

end.
