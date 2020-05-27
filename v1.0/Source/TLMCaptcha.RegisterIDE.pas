unit TLMCaptcha.RegisterIDE;

interface

procedure Register;

implementation

uses
  System.Classes,
  TLMCaptcha.Impl;



procedure Register;
begin
  RegisterComponents('LMCODE Segurança', [TCaptchaGenerator]);
end;

end.
