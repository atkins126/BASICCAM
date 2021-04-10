unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  {DirectShow ����� ActiveX ��� �߰�}
  Winapi.ActiveX, Winapi.DirectShow9, DSUtils, uBaseDShow, Vcl.StdCtrls;

type
  TCamDShow = class(TBaseDShow)
  private
    Cam: IBaseFilter;
    VideoRender: IBaseFilter;
  protected
  public
    constructor Create(Screen:TPanel);
    destructor Destroy;override;
    function MakeBaseFilter:HRESULT;
    function ReleaseBaseFilter:HRESULT;
    function ConnectBaseFilter:HRESULT;
    procedure Run;
    procedure Stop;
end;

  TfrmMain = class(TForm)
    paScreen: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CamDShow :TCamDShow;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  if not Assigned(CamDShow) then begin
    CamDShow := TCamDShow.Create(paScreen);
  end;
  CamDShow.Run;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  CamDShow.Stop;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin

end;

{ TCamDShow }

function TCamDShow.ConnectBaseFilter: HRESULT;
var
  InPin : IPin;
  OutPin : IPin;
  hr : HRESULT;
begin
  Result := S_OK;
  FindPinOnFilter(Cam,PINDIR_OUTPUT,OutPin); //Cam���� ù��° ������� ����.
  FindPinOnFilter(VideoRender,PINDIR_InPUT,InPin); //���������� ù��° �Է����� ����.
  hr := FilterGraph.Connect(OutPin,InPin); //���ͱ׷����� �ΰ��� ���� �����Ѵ�.
  if hr <> S_OK then Result := S_FALSE;
  hr := S_OK;
  OutPin := NIL;
  InPin := NIL;
  if Result = S_FALSE then ShowMessage('ConnectBaseFilter is Failed');
end;

constructor TCamDShow.Create(Screen: TPanel);
begin
  inherited Create;
  MakeBaseFilter;
  ConnectBaseFilter;
  VideoWindow.put_Owner(OAHWND(Screen.Handle));
  VideoWindow.put_WindowStyle(WS_CHILD or WS_CLIPSIBLINGS);
  VideoWindow.put_Width(640);
  VideoWIndow.put_Height(480);
  VideoWindow.put_Top(0);
  VideoWindow.put_Left(0);
end;

destructor TCamDShow.Destroy;
begin
  ReleaseBaseFilter;
  inherited Destroy;
end;

function TCamDShow.MakeBaseFilter: HRESULT;
begin
  Result := S_OK;
  Cam := GetCamFilter; //ī�޶� ���...
  FilterGraph.AddFilter(Cam,'Cam Filter'); //ī�޶� ����Ѵ�.
  if Cam = nil then Result := S_FALSE;
  CreateFilter(CLSID_VideoRenderer,VideoRender); //���� �������� ���...
  FilterGraph.AddFilter(VideoRender,'VdRenderFilter'); //���� �������� ����Ѵ�.
  if VideoRender = nil then Result := S_FALSE;
  if Result = S_FALSE then ShowMessage('MakeBaseFilter is Failed');
end;

function TCamDShow.ReleaseBaseFilter: HRESULT;
begin
  if Assigned(MediaControl) then MediaControl.Stop;
  FilterGraph.RemoveFilter(Cam);
  FilterGraph.RemoveFilter(VideoRender);
  While Assigned(Cam) do Cam := nil;
  While Assigned(VideoRender) do VideoRender := nil;
  Result := S_OK;
end;

procedure TCamDShow.Run;
begin
  if Assigned(MediaControl) then MediaControl.Run;
end;

procedure TCamDShow.Stop;
begin
  if Assigned(MediaControl) then MediaControl.Stop;
end;

end.
