unit TLMCaptcha.Base;

interface
uses
  System.Classes;

type
  TLMCaptchaAbstractComponent = class(TComponent)
  private
    FVersion: string;
    FAutor: string;
    FDesenvolvedor: string;
    FDataVersao: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Autor: string read FAutor;
    property Version: string read FVersion;
    property DataVersao: string read FDataVersao;
  end;

implementation

{ TLMCaptchaAbstractComponent }

constructor TLMCaptchaAbstractComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutor := 'Ruan Diego Lacerda Menezes';
  FVersion := '1.0';
  FDataVersao := '27 de Maio de 2020';
end;

destructor TLMCaptchaAbstractComponent.Destroy;
begin
 //
  inherited;
end;

end.
