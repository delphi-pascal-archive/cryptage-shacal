program PrgSHACAL;

uses
  Forms,
  CryptUnit in 'CryptUnit.pas' {CryptForm},
  Wcrypt2 in 'Wcrypt2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCryptForm, CryptForm);
  Application.Run;
end.
