unit uBaseDShow;

interface

uses
  Winapi.Windows,
  {DirectShow ����� ActiveX ��� �߰�}
  Winapi.ActiveX, Winapi.DirectShow9, DSUtils;

type
  TBaseDShow = class(TObject)
  private
  public
    FilterGraph: IGraphBuilder; // ���ͱ׷����� �������̽� ���� �ϳ�.
    MediaControl: IMediaControl;
    VideoWindow: IVideoWindow;
    constructor Create;
    destructor Destroy; override;
    function CreateFilterGraph(var Graph: IGraphBuilder): Boolean;
    function CreateFilter(const clsid: TGUID; var Filter: IBaseFilter): Boolean;
    function FindPinOnFilter(const Filter: IBaseFilter; const PinDir: TPinDirection; var Pin: IPin): HRESULT;
    function GetCamFilter: IBaseFilter;
  end;

implementation

{ TBaseDShow }

constructor TBaseDShow.Create;
begin
  inherited Create;
  CoInitialize(nil); // COM�� �ʱ�ȭ�Ѵ�.
  CreateFilterGraph(FilterGraph); // ���ͱ׷����� �����Ѵ�.

  FilterGraph.QueryInterface(IID_IMediaControl, MediaControl);
  FilterGraph.QueryInterface(IID_IVideoWindow, VideoWindow);
end;

function TBaseDShow.CreateFilterGraph(var Graph: IGraphBuilder): Boolean;
var
  ID : Integer;
begin
  Result := False;
  if Failed(CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER, IID_IFilterGraph, Graph)) then
    Exit;
  Result := True;
end;

function TBaseDShow.CreateFilter(const clsid: TGUID; var Filter: IBaseFilter): Boolean;
begin
  Result := False;
  if Failed(CoCreateInstance(clsid, NIL, CLSCTX_INPROC_SERVER, IID_IBaseFilter, Filter)) then
    Exit;
  Result := True;
end;

function TBaseDShow.GetCamFilter: IBaseFilter;
var
  SysEnum: TSysDevEnum;
begin
  SysEnum := TSysDevEnum.Create;
  try
    SysEnum.SelectGUIDCategory(CLSID_VideoInputDeviceCategory);
    Result := SysEnum.GetBaseFilter(0)// ���� ù��° ��ġ�� �����´�.
  finally
    SysEnum.Free;
  end;
end;

function TBaseDShow.FindPinOnFilter(const Filter: IBaseFilter; const PinDir: TPinDirection; var Pin: IPin): HRESULT;
var
  IsConnected : Boolean;
  hr: DWORD;
  EnumPin: IEnumPins;
  ConnectedPin: IPin;
  PinDirection: TPinDirection;
begin
  Result := S_False;
  if not Assigned(Filter) then exit;
  hr := Filter.EnumPins(EnumPin);

  if(SUCCEEDED(hr)) then begin
    while (S_OK = EnumPin.Next(1, Pin, nil)) do begin
      //���� ����Ǿ����� ����.
      hr := Pin.ConnectedTo(ConnectedPin);
      if hr = S_OK then begin
        IsConnected := True;
        ConnectedPin := nil;
      end
      else IsConnected := False;

      //���� ������ �˻�
      hr := Pin.QueryDirection(PinDirection);
      //�Ű������� �ɹ���� �����ϰ� ���� ����� ���°� �ƴ϶�� �������� Ż��.
      if (hr = S_OK) and (PinDirection = PinDir)
      and (not IsConnected) then break;

      pin := nil;
    end;

    Result := S_OK;
  end;

  EnumPin := nil;
end;

destructor TBaseDShow.Destroy;
begin
  if Assigned(MediaControl) then MediaControl.Stop; // ���� �������� �ߴ��Ѵ�.
  While Assigned(VideoWindow) do VideoWindow := nil;
  While Assigned(MediaControl) do MediaControl := nil;
  While Assigned(FilterGraph) do FilterGraph := nil; // ���� �׷����� �Ҹ��Ų��.

  CoUninitialize; // COM�� �˴ٿ��Ų��.

  inherited Destroy;
end;

end.
