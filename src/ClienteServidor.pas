unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB;

type
  TServidor = class
  private
    FPath: AnsiString;
  public
    constructor Create;
    //Tipo do par�metro n�o pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: AnsiString;
    FServidor: TServidor;
    function InitDataset: TClientDataset;
    procedure ExcluirAnteriores(const ID: Integer);
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils, System.Threading;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  LTask: ITask;
begin
  cds := InitDataset;
  LTask := TTask.Create(procedure
  begin
      ProgressBar.Min := 0;
      ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
    for var i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      TThread.Synchronize(TThread.Current, procedure
      begin
        cds.Append;
        TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
        cds.Post;

        {$REGION Simula��o de erro, n�o alterar}
        try
          if i = (QTD_ARQUIVOS_ENVIAR/2) then
            FServidor.SalvarArquivos(NULL);
          {$ENDREGION}
        except
          ExcluirAnteriores(I);
        end;
      end);
    end;
  end);
  LTask.Start;
  FServidor.SalvarArquivos(cds.Data);
  ProgressBar.Position := 0;
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  cds: TClientDataset;
  Mem: TStream;
  LTask: ITask;
begin
  cds := InitDataset;
  LTask := TTask.Create(procedure
  begin
    ProgressBar.Min := 0;
    ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
    for var i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      TThread.Synchronize(TThread.Current, procedure
      begin
        ProgressBar.Position := ProgressBar.Position + 1;
        cds.Append;
        Mem := TFileStream.Create(FPath, fmOpenRead or fmShareDenyNone);
        TBlobField(cds.FieldByName('arquivo')).LoadFromStream(Mem);
        FreeMem(TField(cds.FieldByName('arquivo')).FieldAddress('PDF'));
        cds.Post;
        Mem.Free;
      end);
    end
  end);
  LTask.Start;

  FServidor.SalvarArquivos(cds.Data);
  ProgressBar.Position := 0;
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  Mem: TStream;
  LTask: ITask;
begin
  cds := InitDataset;
  LTask := TTask.Create(procedure
  begin
    ProgressBar.Min := 0;
    ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
    for var i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      TThread.Synchronize(TThread.Current, procedure
      begin
        ProgressBar.Position := ProgressBar.Position + 1;
        cds.Append;
        Mem := TFileStream.Create(FPath, fmOpenRead or fmShareDenyNone);
        TBlobField(cds.FieldByName('arquivo')).LoadFromStream(Mem);
        FreeMem(TField(cds.FieldByName('arquivo')).FieldAddress('PDF'));
        cds.Post;
        Mem.Free;
      end);
    end
  end);
  LTask.Start;

  FServidor.SalvarArquivos(cds.Data);
  ProgressBar.Position := 0;
end;

procedure TfClienteServidor.ExcluirAnteriores(const ID: Integer);
var
  I: Integer;
begin
  for I := ID downto 0 do
    if FileExists(FPath + I.ToString + '.pdf') then
      DeleteFile(FPath + I.ToString + '.pdf');
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    cds := TClientDataset.Create(nil);
    cds.Data := AData;

    {$REGION Simula��o de erro, n�o alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;

    while not cds.Eof do
    begin
      FileName := FPath + cds.RecNo.ToString + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);

      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;

    Result := True;
  except
    Result := False;
    raise;
  end;
end;

end.

