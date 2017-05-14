unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Menus, ComCtrls, MaskEdit, Spin, AsyncProcess, Windows, registry,
  process;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    MenuItem2: TMenuItem;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    Process1: TProcess;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    StaticText1: TStaticText;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TrayIcon1: TTrayIcon;
    procedure AsyncProcess1ReadData(Sender: TObject);
    procedure AsyncProcess1Terminate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
  IsSingleInstance('MsWinZonesCacheCounterMutexA0');
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

procedure TForm1.AsyncProcess1ReadData(Sender: TObject);
var
  s: string;
  b: dword;
begin
  s := '';
  b := Process1.Output.NumBytesAvailable;
  if b >0 then begin
      setlength(s, b);
      Process1.Output.Read(s[1], b);
      Memo2.Text := Memo2.Text + s;
  end;
end;

procedure TForm1.AsyncProcess1Terminate(Sender: TObject);
begin
end;

procedure TForm1.Button2Click(Sender: TObject);
var str: TStringList;
begin
  Process1.Options := [poUsePipes, poStderrToOutPut];
  Process1.ShowWindow := swoHIDE;
  Process1.CurrentDirectory := ExtractFilePath(Application.ExeName);
  Process1.Executable:='smb_ms17_010.exe';
  Process1.Parameters.Text := SpinEdit1.Text + '.' +
                        SpinEdit2.Text + '.' +
                        SpinEdit3.Text + '.' +
                        SpinEdit4.Text;

  Process1.Execute;
  Process1.WaitOnExit;

  Memo2.Lines.BeginUpdate;
  if Process1.ExitStatus = 1 then begin
      Memo2.Text:='มีข้อผิดพลาดระหว่างการตรวจสอบ';
  end else if Process1.ExitStatus = 0 then begin
      Memo2.Text:='ไม่พบช่องโหว่ EternalBlue';
  end else if Process1.ExitStatus = 99 then begin
      Memo2.Text:='ไม่สามารถตรวจสอบได้ เป็นไปได้ว่า SMBv1 ถูกปิดแล้ว';
  end else if Process1.ExitStatus = 100 then begin
      Memo2.Text:='พบช่องโหว่ ETERNALBLUE !!';
  end else if Process1.ExitStatus = 200 then begin
      Memo2.Text:='พบช่องโหว่ ETERNALBLUE และ DoublePulsar !!';
  end;
  Memo2.Text := Memo2.Text + #13#10#13#10;

  str := TStringList.Create;
  str.LoadFromStream(Process1.Output);
  Memo2.Text := Memo2.Text + str.Text;
  str.Free;
  Memo2.Lines.EndUpdate;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=false;
  Application.Minimize;
end;

end.
