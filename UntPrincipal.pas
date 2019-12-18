unit UntPrincipal;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Actions,
  System.Rtti,
  System.Bindings.Outputs,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Edit,
  FMX.TabControl,
  FMX.ActnList,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  Fmx.Bind.Editors,
  Fmx.Bind.DBEngExt,

  UntMesa,

  Data.Bind.Components,
  Data.Bind.ObjectScope,
  Data.Bind.EngExt,
  Data.Bind.GenData,
  Data.DB,
  Data.Bind.DBScope,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,

  MultiDetailAppearanceU;

type
  TForm1 = class(TForm)
    lytGeral: TLayout;
    Button1: TButton;
    Button2: TButton;
    Layout1: TLayout;
    flowMesas: TGridLayout;
    tbcMain: TTabControl;
    tbiMesas: TTabItem;
    tbiResumo: TTabItem;
    tbiPagamento: TTabItem;
    actMain: TActionList;
    actChangeTab: TChangeTabAction;
    ToolBar1: TToolBar;
    Button3: TButton;
    lblTituloResumo: TLabel;
    Layout2: TLayout;
    recBack: TRectangle;
    lytNumeros: TLayout;
    lblNumero: TLabel;
    lytTeclado: TLayout;
    grdNumeros: TGridPanelLayout;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    btn5: TButton;
    btn6: TButton;
    btn7: TButton;
    btn8: TButton;
    btn9: TButton;
    btn0: TButton;
    btn00: TButton;
    btnX: TButton;
    lytBotoes: TLayout;
    btnCancelar: TButton;
    btnContinuar: TButton;
    ListView1: TListView;
    Layout3: TLayout;
    Button4: TButton;
    BtnVirgula: TButton;
    BtnLimparTudo: TButton;
    MemPedidos: TFDMemTable;
    MemPedidosID: TIntegerField;
    MemPedidosUNITARIO: TFloatField;
    MemPedidosITEM: TStringField;
    MemPedidosQTD: TIntegerField;
    MemPedidosTOTAL: TFloatField;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    Layout4: TLayout;
    Label2: TLabel;
    lblTotal: TLabel;
    Rectangle1: TRectangle;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnDigitar(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure MemPedidosUNITARIOGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure MemPedidosTOTALGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure MemPedidosQTDGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
  private
    { Private declarations }
    FNumero : Double;
    procedure ClearTables;
    procedure DoClickTable(Sender: TObject);
    procedure ShowTables(const ATables: Integer = 20);
    procedure FillSummary;
    procedure SelectTable;
    procedure ChangeTab(ATabItem: TTabItem; Sender: TObject);
    function GetLabelFrame(AFrame: TFrameMesa): TLabel;
    procedure Summary(const ATable: Integer);
    property  Numero : Double read FNumero write FNumero;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

{ TForm1 }

procedure TForm1.btnCancelarClick(Sender: TObject);
begin
  FNumero := 0;
  lblNumero.Text := 'Valor da Venda';
  ChangeTab(tbiResumo, Sender);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ShowTables;
end;

procedure TForm1.SelectTable;
var
  LMesa : Integer;
begin
  repeat
    MemPedidos.Filter   := EmptyStr;
    MemPedidos.Filtered := False;
    randomize;

    LMesa := Random(4);

    MemPedidos.Filter   := Format('ID=%d', [LMesa]);
    MemPedidos.Filtered := True;
    Summary(LMesa);
  until MemPedidos.Locate('ID', LMesa, []);
end;

procedure TForm1.Summary(const ATable : Integer);
var
  LTotal: Double;
begin
  LTotal := 0.0;
  MemPedidos.First;
  while not MemPedidos.Eof do
  begin
    LTotal := LTotal + MemPedidosTOTAL.AsFloat;
    MemPedidos.Next;
  end;
  lblTotal.Text := Format('R$ %5.2f', [LTotal]);
end;

procedure TForm1.ShowTables(const ATables: Integer = 20);
var
  LThread : TThread;
begin
  LThread :=
    TThread.CreateAnonymousThread(
      procedure ()
      var
        I         : Integer;
        LFrame    : TFrameMesa;
        SizeTable : Double;
        Occuped   : Integer;
      begin
        SizeTable            := (Self.ClientWidth / 4);
        flowMesas.ItemHeight := SizeTable;
        flowMesas.ItemWidth  := SizeTable;
        flowMesas.Visible    := False;

        flowMesas.BeginUpdate;
        for I := 1 to ATables do
        begin
          LFrame                    := TFrameMesa.Create(flowMesas);
          LFrame.Parent             := flowMesas;
          LFrame.Name               := Format('frame%6.6d', [I]);
          LFrame.speNumMesa.OnClick := DoClickTable;
          TThread.Synchronize(
            TThread.CurrentThread,
            procedure ()
            begin
              randomize;
              Occuped := Random(2);
              case Occuped of
                0  :
                  begin
                    LFrame.recMesa.Fill.Color := TAlphaColorRec.Red;
                  end;
                1  :
                  begin
                    LFrame.recMesa.Fill.Color := TAlphaColorRec.Lime;
                  end;
              end;
              LFrame.Tag             := Occuped;
              LFrame.lblNumMesa.Text := Format('%2.2d', [I]);
              LFrame.Width           := SizeTable;
              LFrame.Height          := SizeTable;;
              flowMesas.AddObject(LFrame);
            end
          );
        end;
        TThread.Synchronize(
          TThread.CurrentThread,
          procedure ()
          begin
            flowMesas.EndUpdate;
            flowMesas.Visible := True;
          end
        );
      end
    );
  LThread.FreeOnTerminate := True;
  LThread.Start;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ClearTables;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ChangeTab(tbiMesas, Sender);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ChangeTab(tbiPagamento, Sender);
end;

procedure TForm1.ChangeTab(ATabItem: TTabItem; Sender: TObject);
begin
  actChangeTab.Tab := ATabItem;
  actChangeTab.ExecuteTarget(Sender);
end;

procedure TForm1.ClearTables;
var
  LThread : TThread;
begin
  LThread :=
    TThread.CreateAnonymousThread(
      procedure ()
      var
        I         : Integer;
      begin
        for I := Pred(Self.flowMesas.ControlsCount) downto 0 do
        begin
          Self.flowMesas.BeginUpdate;
          Self.flowMesas.Visible := False;
          if (Self.flowMesas.Controls[I] is TFrameMesa) then
          begin
            TThread.Synchronize(
              TThread.CurrentThread,
              procedure ()
              begin
                (Self.flowMesas.Controls[I] as TFrameMesa).DisposeOf;
              end
            );
          end;

          TThread.Synchronize(
            TThread.CurrentThread,
            procedure ()
            begin
              Self.flowMesas.EndUpdate;
              Self.flowMesas.Visible := True;
            end
          );
        end
      end
    );
  LThread.FreeOnTerminate := True;
  LThread.Start;
end;

function TForm1.GetLabelFrame(AFrame: TFrameMesa): TLabel;
var
  I : Integer;
begin
  for I := 0 to Pred(AFrame.ComponentCount) do
  begin
    if (AFrame.Components[I] is TLabel) then
    begin
      Result := TLabel(AFrame.Components[I]);
      break;
    end;
  end;
end;
procedure TForm1.DoClickTable(Sender: TObject);
var
  Occuped: Integer;
begin
  Occuped := TFrameMesa(TSpeedButton(Sender).Owner).Tag;
  case Occuped of
    0 :
      begin
        ChangeTab(tbiResumo, Sender);
        lblTituloResumo.Text := Format('Resumo da Mesa: %s', [TLabel(GetLabelFrame(TFrameMesa(TSpeedButton(Sender).Owner))).Text]);
        SelectTable;
      end;
    1 : ShowMessage('Essa mesa não possui cliente.');
  end;

end;

procedure TForm1.FillSummary;
begin
  MemPedidos.Active := True;
  //Mesa 01
  MemPedidos.Append;
  MemPedidosID.AsInteger     := 1;
  MemPedidosITEM.AsString    := 'Buffet Individual';
  MemPedidosUNITARIO.AsFloat := 49.90;
  MemPedidosQTD.AsInteger    := 2;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 1;
  MemPedidosITEM.AsString    := 'Regrigerante';
  MemPedidosUNITARIO.AsFloat := 6.27;
  MemPedidosQTD.AsInteger    := 4;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 1;
  MemPedidosITEM.AsString    := 'Café Expresso';
  MemPedidosUNITARIO.AsFloat := 8.49;
  MemPedidosQTD.AsInteger    := 1;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  //Mesa 02
  MemPedidos.Append;
  MemPedidosID.AsInteger     := 2;
  MemPedidosITEM.AsString    := 'Self Service';
  MemPedidosUNITARIO.AsFloat := 29.90;
  MemPedidosQTD.AsInteger    := 1;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 2;
  MemPedidosITEM.AsString    := 'Suco Frutas';
  MemPedidosUNITARIO.AsFloat := 4.00;
  MemPedidosQTD.AsInteger    := 3;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  //Mesa 03
  MemPedidos.Append;
  MemPedidosID.AsInteger     := 3;
  MemPedidosITEM.AsString    := 'Pizza Portuguesa';
  MemPedidosUNITARIO.AsFloat := 89.60;
  MemPedidosQTD.AsInteger    := 1;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 3;
  MemPedidosITEM.AsString    := 'Pizza Calabresa';
  MemPedidosUNITARIO.AsFloat := 69.60;
  MemPedidosQTD.AsInteger    := 1;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 3;
  MemPedidosITEM.AsString    := 'Pizza Doce';
  MemPedidosUNITARIO.AsFloat := 39.60;
  MemPedidosQTD.AsInteger    := 3;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 3;
  MemPedidosITEM.AsString    := 'Pizza Verde';
  MemPedidosUNITARIO.AsFloat := 79.60;
  MemPedidosQTD.AsInteger    := 2;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  //Mesa 04
  MemPedidos.Append;
  MemPedidosID.AsInteger     := 4;
  MemPedidosITEM.AsString    := 'Lanche Kids';
  MemPedidosUNITARIO.AsFloat := 19.60;
  MemPedidosQTD.AsInteger    := 4;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 4;
  MemPedidosITEM.AsString    := 'Big Lanche';
  MemPedidosUNITARIO.AsFloat := 29.60;
  MemPedidosQTD.AsInteger    := 2;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;

  MemPedidos.Append;
  MemPedidosID.AsInteger     := 4;
  MemPedidosITEM.AsString    := 'Café Expresso';
  MemPedidosUNITARIO.AsFloat := 8.49;
  MemPedidosQTD.AsInteger    := 1;
  MemPedidosTOTAL.AsFloat    := MemPedidosUNITARIO.AsFloat * MemPedidosQTD.AsInteger;
  MemPedidos.Post;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FNumero := 0;
  tbcMain.ActiveTab := tbiMesas;
  tbcMain.TabPosition := TTabPosition.None;
  FillSummary;
end;

procedure TForm1.MemPedidosQTDGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Format('Qtde Consumida: %2.2d', [Sender.AsInteger]);
end;

procedure TForm1.MemPedidosTOTALGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Format('Vlr. Total R$: %5.2f', [Sender.AsFloat]);
end;

procedure TForm1.MemPedidosUNITARIOGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Format('Vlr. Unitário R$: %4.2f', [Sender.AsFloat]);
end;

procedure TForm1.OnDigitar(Sender: TObject);
var
  LConteudo : string;
begin
  if FNumero = 0
  then LConteudo := EmptyStr
  else LConteudo := lblNumero.Text;

  if TButton(Sender).Text.Equals('X') then
  begin
    LConteudo := Copy(LConteudo, 1, Length(LConteudo)-1);
    if LConteudo.Equals(EmptyStr) then
    begin
      lblNumero.Text := 'Valor da Venda';
      FNumero        := 0;
      exit;
    end;
  end
  else if TButton(Sender).Text.Equals('XX') then
  begin
    lblNumero.Text := 'Valor da Venda';
    FNumero        := 0;
    exit;
  end
  else
    LConteudo := LConteudo + TButton(Sender).Text;

  lblNumero.Text := LConteudo;
  FNumero        := LConteudo.ToDouble;
end;

end.
