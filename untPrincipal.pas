unit untPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask,
  Vcl.DBCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, untClasses, System.JSON;

type
  TfrmPrincipal = class(TForm)
    pnBusca: TPanel;
    pnContatos: TPanel;
    GridContatos: TDBGrid;
    btBuscar: TBitBtn;
    edBuscar: TEdit;
    Label11: TLabel;
    btLimpar: TBitBtn;
    btSair: TBitBtn;
    btAnterior: TBitBtn;
    BtNovo: TBitBtn;
    btGravar: TBitBtn;
    pnDados: TPanel;
    edNome: TEdit;
    edLogradouro: TEdit;
    edComplemento: TEdit;
    edNumero: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    edCep: TEdit;
    edCidade: TEdit;
    edSigla_UF: TEdit;
    edIBGE_Cidade: TEdit;
    edIBGE_UF: TEdit;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    edID: TEdit;
    Label21: TLabel;
    btProximo: TBitBtn;
    pnContatosBotoes: TPanel;
    btContatoNovo: TBitBtn;
    btContatoGravar: TBitBtn;
    btContatoLimpar: TBitBtn;
    edNomeContato: TEdit;
    edDataNascimento: TEdit;
    edTelefone: TEdit;
    Label1: TLabel;
    lbNome: TLabel;
    lbDataNascimento: TLabel;
    llbTelefone: TLabel;
    btExcluirCliente: TBitBtn;
    btExcluirContato: TBitBtn;
    bmBuscarNaAPI: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure btBuscarClick(Sender: TObject);
    procedure edBuscarKeyPress(Sender: TObject; var Key: Char);
    procedure btSairClick(Sender: TObject);
    procedure btLimparClick(Sender: TObject);
    procedure btAnteriorClick(Sender: TObject);
    procedure BtNovoClick(Sender: TObject);
    procedure btProximoClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edTelefoneExit(Sender: TObject);
    procedure edDataNascimentoExit(Sender: TObject);
    procedure btContatoNovoClick(Sender: TObject);
    procedure btContatoLimparClick(Sender: TObject);
    procedure edCepExit(Sender: TObject);
    procedure btContatoGravarClick(Sender: TObject);
    procedure btExcluirContatoClick(Sender: TObject);
    procedure btExcluirClienteClick(Sender: TObject);
    procedure bmBuscarNaAPIClick(Sender: TObject);
  private
    { Private declarations }
    pvtCliente: TCliente;
    pvtBuscaCliente: TListaCliente;
    pvtContato: TContato;
    pvtContador: Integer;

    procedure CarregarObjetoTela(prmCOntador: Integer);
    procedure LimparEdits();
    procedure LimparObjetos();
    procedure StatusModuloContato(prmVisible: boolean);
    procedure StatusModuloCliente(prmVisible: boolean);
    procedure StatusEditsNovoContato(prmVisible: boolean);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses untFuncoes, untDataModulo;

procedure TfrmPrincipal.bmBuscarNaAPIClick(Sender: TObject);
begin
  BuscarClienteNaAPI(edBuscar.Text);
end;

procedure TfrmPrincipal.btAnteriorClick(Sender: TObject);
begin
  if pvtContador = 0  then
    Exit;

  if pvtBuscaCliente <> nil then
  begin
    Dec(pvtContador);
    CarregarObjetoTela(pvtContador);
  end;
end;

procedure TfrmPrincipal.btContatoGravarClick(Sender: TObject);
begin
  if GravarContato(pvtCliente.ID, edNomeContato.Text, edDataNascimento.Text, edTelefone.Text) then
  begin
    ShowMessage('Contato gravado com sucesso!');
    btContatoLimparClick(nil);
    StatusEditsNovoContato(false);
    DataModule2.qryContato.Close;
    DataModule2.qryContato.Parameters.ParamByName('prmIDCLiente').Value := pvtCliente.ID;
    DataModule2.qryContato.Open;
    btContatoLimpar.Visible := False;
    btContatoGravar.Visible := False;
  end
  else
    ShowMessage('O Contato n�o foi gravado')
end;

procedure TfrmPrincipal.btContatoLimparClick(Sender: TObject);
begin
  edNomeContato.Clear;
  edTelefone.Clear;
  edDataNascimento.Clear;
  pvtContato.Clear;
end;

procedure TfrmPrincipal.btContatoNovoClick(Sender: TObject);
begin
  if not Assigned(pvtCliente) then
  begin
    ShowMessage('Contato s� pode ser criado com o cliente selecionado!');
    Exit;
  end;
  if pvtCliente.ID = 0 then
  begin
    ShowMessage('Contato s� pode ser criado com o cliente salvo!');
    Exit;
  end;
  StatusEditsNovoContato(true);
  NovoContato(pvtCliente.ID, pvtContato);
  edNomeContato.SetFocus;
end;

procedure TfrmPrincipal.btExcluirClienteClick(Sender: TObject);
begin
  if (pvtCliente.ID = 0) or (pvtCliente = nil) then
    ShowMessage('Favor selecionar o Cliente a Excluir')
  else
  begin
    if MessageDlg('Deseja Excluir o Cliente?',mtConfirmation, [mbYes,mbNo],0) = mrYes then
    begin
      if ExcluirCliente(pvtCliente.ID) then
      begin
        ShowMessage('Cliente Exclu�do com Sucesso');
        btBuscarClick(nil);
      end
      else
        ShowMessage('Cliente n�o exclu�do');
    end;
  end;

end;

procedure TfrmPrincipal.btExcluirContatoClick(Sender: TObject);
begin
  if DataModule2.qryContato.RecordCount = 0 then
  begin
    ShowMessage('N�o h� contato para excluir!');
    Exit
  end;

  if  MessageDlg('Deseja Excluir o Contato?',mtConfirmation, [mbYes,mbNo],0) = mrYes then
  begin
    if ExcluirContato(DataModule2.qryContato.FieldByName('ID').Value, pvtCliente.ID) then
      ShowMessage('Contato Exclu�do com Sucesso')
    else
      ShowMessage('Contato n�o exclu�do');
    DataModule2.qryContato.Close;
    DataModule2.qryContato.Open;
  end;
end;

procedure TfrmPrincipal.btProximoClick(Sender: TObject);
begin
  try
    if pvtContador = pvtBuscaCliente.Count-1  then
      Exit;

    if pvtBuscaCliente <> nil then
    begin
      Inc(pvtContador);
      CarregarObjetoTela(pvtContador);
    end;
  except

  end;
end;

procedure TfrmPrincipal.btBuscarClick(Sender: TObject);
var
  LocTamanho: Integer;
  LocNome: String;
begin
  if edBuscar.Text = '' then
  begin
    ShowMessage('Buscas vazias n�o s�o permitidas!'+#13+'Favor digitar ao menos uma letra!');
    edBuscar.SetFocus;
    Exit;
  end;
  try
    if pnContatos.Visible then
    begin
      LocNome := edBuscar.Text;
      btLimparClick(nil);
      edBuscar.Text := LocNome;
    end;
    pvtBuscaCliente := nil;
    pvtBuscaCliente := BuscarNomePOO(edBuscar.Text);
    pvtContador := 0;
    if pvtBuscaCliente <> nil then
      CarregarObjetoTela(pvtContador)
    else
      ShowMessage('A Consulta n�o retornou valores');
  except
    raise Exception.Create('Erro ao consultar Clientes');
  end;
end;

procedure TfrmPrincipal.btGravarClick(Sender: TObject);
begin
  if edNome.Text = '' then
  begin
    ShowMessage('Tem que digitar o nome');
    edNome.SetFocus;
    Exit;
  end;

  if edCep.Text = '' then
  begin
    ShowMessage('Tem que digitar o CEP');
    edCep.SetFocus;
    Exit;
  end;

  if edLogradouro.Text = '' then
  begin
    ShowMessage('Tem que digitar o Logradouro');
    edLogradouro.SetFocus;
    Exit;
  end;

  if edNumero.Text = '' then
  begin
    ShowMessage('Tem que digitar o Numero');
    edNumero.SetFocus;
    Exit;
  end;

  if edCidade.Text = '' then
  begin
    ShowMessage('Tem que digitar a Cidade');
    edCidade.SetFocus;
    Exit;
  end;

  if edSigla_UF.Text = '' then
  begin
    ShowMessage('Tem que digitar o UF');
    edSigla_UF.SetFocus;
    Exit;
  end;

  if edIBGE_UF.Text = '' then
  begin
    ShowMessage('Tem que digitar o UF IBGE');
    edIBGE_UF.SetFocus;
    Exit;
  end;

  if edIBGE_UF.Text = '' then
  begin
    ShowMessage('Tem que digitar o N� IBGE da Cidade');
    edIBGE_Cidade.SetFocus;
    Exit;
  end;

  if GravarCliente(edNome.Text, edCep.Text, edLogradouro.Text, edNumero.Text,   edComplemento.Text,
  edCidade.Text, edSigla_UF.Text, edIBGE_Cidade.Text, edIBGE_UF.Text, 0) then
  begin
    edBuscar.Text := edNome.Text;
    btBuscarClick(nil);
    edBuscar.Clear;
  end;
end;

procedure TfrmPrincipal.btLimparClick(Sender: TObject);
begin
  FecharQryCliente();
  FecharQryContato();
  LimparEdits();
  edBuscar.Clear;
  edBuscar.SetFocus;
  StatusModuloContato(false);
  StatusModuloCliente(false);
end;

procedure TfrmPrincipal.BtNovoClick(Sender: TObject);
begin
  if pnDados.Enabled then
    btLimparClick(nil);
  StatusModuloCliente(true);
  StatusModuloContato(true);
  NovoCliente(pvtCliente);
  edNome.SetFocus;
end;

procedure TfrmPrincipal.btSairClick(Sender: TObject);
begin
  FecharQryCliente();
  FecharQryContato();
  Close;
end;

procedure TfrmPrincipal.CarregarObjetoTela(prmContador: Integer);
begin
  if pvtBuscaCliente <> nil then
  begin
    StatusModuloCliente(true);
    StatusModuloContato(true);
    pvtCliente := TCliente.Create();
    pvtCliente := pvtBuscaCliente.Buscar(pvtContador);
    edNome.Text        := pvtCliente.Nome;
    edLogradouro.Text  := pvtCliente.Logradouro;
    edComplemento.Text := pvtCliente.Complemento;
    edNumero.Text      := pvtCliente.Numero;
    edCep.Text         := pvtCliente.CEP;
    edCidade.Text      := pvtCliente.Cidade;
    edSigla_UF.Text    := pvtCliente.Sigla_UF;
    edIBGE_Cidade.Text := pvtCliente.IBGE_Cidade;
    edIBGE_UF.Text     := pvtCliente.IBGE_UF;
    edID.Text          := pvtCliente.ID.ToString;
    pnDados.Enabled    := True;
    CarregarContatos(pvtCliente.ID.ToString);
    if DataModule2.qryContato.RecordCount > 0 then
      GridContatos.Visible := True;
  end;
end;

procedure TfrmPrincipal.edBuscarKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    btBuscar.Click;
  end;
end;

procedure TfrmPrincipal.edCepExit(Sender: TObject);
var
  LocJsonValue: TJSONValue;
  LocJsonObject: TJSONObject;
begin
  if edCep.Text = '' then
    Exit;

  if not ValidarCep(edCep.Text) then
  begin
    ShowMessage('Cep Inv�lido!');
    edCep.SetFocus;
    Exit;
  end;
  LocJsonValue:= BuscarCep(edCep.Text);
  if LocJsonValue <> nil then
  begin
    try
      LocJsonObject := LocJsonValue as TJSONObject;
      edLogradouro.Text := LocJsonObject.GetValue<string>('logradouro');
      edCidade.Text := LocJsonObject.GetValue<string>('localidade');
      edLogradouro.Text := edLogradouro.Text +' - '+  LocJsonObject.GetValue<string>('bairro');
      edSigla_UF.Text := LocJsonObject.GetValue<string>('uf');
      edIBGE_Cidade.Text := LocJsonObject.GetValue<string>('ibge');
      edIBGE_UF.Text := LocJsonObject.GetValue<string>('uf');
      edNumero.SetFocus;
    except
      edLogradouro.SetFocus;
    end;
  end;
end;

procedure TfrmPrincipal.edDataNascimentoExit(Sender: TObject);
begin
  if edDataNascimento.Text <> '' then
    edDataNascimento.Text := FormatFloat('##/##/####',StrToFloat(edDataNascimento.Text));
end;

procedure TfrmPrincipal.edTelefoneExit(Sender: TObject);
begin
  if edTelefone.Text <> '' then
    edTelefone.Text := FormatFloat('(##) #####-####',StrToFloat(edTelefone.Text));
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  pvtBuscaCliente:= nil;
  pvtCliente:= nil;
  pvtBuscaCliente.Free;
  pvtCliente.Free;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  edBuscar.SetFocus;
end;

//Limpar os Edits do form
procedure TfrmPrincipal.LimparEdits;
begin
  edBuscar.Clear;
  edNome.Clear;
  edLogradouro.Clear;
  edComplemento.Clear;
  edNumero.Clear;
  edCep.Clear;
  edCidade.Clear;
  edSigla_UF.Clear;
  edIBGE_Cidade.Clear;
  edIBGE_UF.Clear;
  edID.Clear;
end;

//Limpar os objetos
procedure TfrmPrincipal.LimparObjetos;
begin
  pvtCliente.Clear;
  pvtBuscaCliente.Clear;
end;

procedure TfrmPrincipal.StatusEditsNovoContato(prmVisible: boolean);
begin
  edNomeContato.Visible := prmVisible;
  edDataNascimento.Visible := prmVisible;
  edTelefone.Visible := prmVisible;
  lbNome.Visible := prmVisible;
  lbDataNascimento.Visible := prmVisible;
  llbTelefone.Visible := prmVisible;
  btContatoGravar.Visible := true;
  btContatoLimpar.Visible := true;
end;

procedure TfrmPrincipal.StatusModuloCliente(prmVisible: boolean);
begin
  pnDados.Visible          := prmVisible;
end;

procedure TfrmPrincipal.StatusModuloContato(prmVisible: boolean);
begin
  pnContatos.Visible := prmVisible;
end;

end.

