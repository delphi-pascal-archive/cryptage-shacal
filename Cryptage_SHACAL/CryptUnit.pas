unit CryptUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TCryptForm = class(TForm)
    LblPassword: TLabel;
    LblData: TLabel;
    EdtData: TEdit;
    LblCryptValue: TLabel;
    EdtCrypt: TEdit;
    BtnTest: TButton;
    BtnCancel: TButton;
    LblDecrypt: TLabel;
    EdtEncrypt: TEdit;
    EdtPassword: TEdit;
    LblHash: TLabel;
    EdtHash: TEdit;
    BtnHash: TButton;
    procedure BtnCryptClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnHashClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  CryptForm: TCryptForm;
const
  NUMBER_ENCRYPT_PASSWORD='´¸•ç¿›]';
  API_ERR='#Error';

implementation

{$R *.dfm}

uses  Wcrypt2;

function EncryptDecryptData(sData, sPassword: string; ToCrypt: Boolean): string;
var
  hProv: HCRYPTPROV;
  hHash: HCRYPTHASH;
  hKey: HCRYPTKEY;
  Buffer: PByte;
  Len: DWORD;
  Str: string;
begin

  try
    // Get the handle to the default provider.
    if not Wcrypt2.CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then begin
      ShowMessageFmt('L''erreur n°%d s''est produite lors de l''appel' + #13 +
                     'de l''API ' + #171 + ' CryptAcquireContext ' + #187 + ' .', [GetLastError()]);
      Exit;
    end;
    // Create hash-object by SHA1 algorithm
    if not Wcrypt2.CryptCreateHash(hProv, CALG_SHA1, 0, 0, @hHash) then begin
      ShowMessageFmt('L''erreur n°%d s''est produite lors de l''appel' + #13 +
                     'de l''API ' + #171 + ' CryptCreateHash ' + #187 + ' .', [GetLastError()]);
      Result:=API_ERR;
      Exit;
    end;
    // Create hash from password
    if not Wcrypt2.CryptHashData(hHash, @sPassword[1], Length(sPassword), 0) then begin
      ShowMessageFmt('L''erreur n°%d s''est produite lors de l''appel' + #13 +
                     'de l''API ' + #171 + ' CryptHashData ' + #187 + ' .', [GetLastError()]);
      Result:=API_ERR;
      Exit;
    end;
    // Create key from hash by RC4 algorithm
    if not Wcrypt2.CryptDeriveKey(hProv, CALG_RC4, hHash, 0, @hKey) then begin
      ShowMessageFmt('L''erreur n°%d s''est produite lors de l''appel' + #13 +
                     'de l''API ' + #171 + ' CryptDeriveKey ' + #187 + ' .', [GetLastError()]);
      Result:=API_ERR;
      Exit;
    end;

    Len:=Length(sData);
    // Allocate buffer to read data
    GetMem(Buffer, Len);
    move(sData[1], buffer^, Len);

    if ToCrypt then
        // Encrypt buffer
        CryptEncrypt(hKey, 0, True, 0, Buffer, @Len, Len)
    else
      // Decrypt buffer
      CryptDecrypt(hKey, 0, True, 0, Buffer, @Len);

    SetLength(Str, Len);
    Move(Buffer^, Str[1], Len);

    // Free up memory
    FreeMem(Buffer, Len);

    Result:=Str;
  finally
    if (hKey<>0) then Wcrypt2.CryptDestroyKey(hKey);
    if (hHash<>0) then Wcrypt2.CryptDestroyHash(hHash);
    if (hProv<>0) then Wcrypt2.CryptReleaseContext(hProv, 0);
  end;
end;
(******************************************************************************)
function EncryptData(sData, sPassword: string): string;
var
  sEncrypted, sTempPassword: string;
  iEncryptionCount: integer;

  function EncryptNumber: string;
  var
    i: integer;
    sNumber: string;
  begin
    Result:=EmptyStr;
    sNumber:=IntToStr(iEncryptionCount);
    sNumber:=Copy('00000000', 1, 8 - Length(sNumber)) + sNumber;
    for i:=1 to 8 do
      Result:=Result + Chr(Ord(NUMBER_ENCRYPT_PASSWORD[i]) + StrToInt(sNumber[i]));
  end;

begin

  // Try first encryption
  iEncryptionCount:=0;
  sTempPassword:=sPassword + IntToStr(iEncryptionCount);
  sEncrypted:=EncryptDecryptData(sData, sTempPassword, True);

  // Catch the error data encryption
  if (sEncrypted=API_ERR) then Exit;

  // Repeat until all the characters #0, #9, #10, and #13 will
  // no longer appear in the expression encrypted.
  while (Pos(Chr(0),sEncrypted)<>0) or (Pos(Chr(9),sEncrypted)<>0) or
        (Pos(Chr(10),sEncrypted)<>0) or (Pos(Chr(13),sEncrypted)<>0) do begin
    // Try the next password
    Inc(iEncryptionCount);
    sTempPassword:=sPassword + IntToStr(iEncryptionCount);
    sEncrypted:=EncryptDecryptData(sData, sTempPassword, True);

    // Set a maximum number of test encryption
    if (iEncryptionCount=99999999) then begin
      ShowMessage('Processus de chiffrement interrompu. Le nombre maximum d''itérations a été atteint.');
      Exit;
    end
  end;

  // Build encrypted string, starting with number of encryption iterations
  Result:=EncryptNumber + sEncrypted;
end;
(******************************************************************************)
function DecryptData(sData, sPassword: string): string;
var
  sTempPassword: string;
  iEncryptionCount: integer;

  function DecryptNumber: integer;
  var
    sNumber: string;
    i: integer;
  begin
    Result:=0;
    sNumber:=Copy(sData, 1, 8);
    for i:=1 to 8 do
      Result:=(10 * Result) + (Ord(sNumber[i]) - Ord(NUMBER_ENCRYPT_PASSWORD[i]));
  end;

begin
  // When encrypting we may have gone through a number of iterations
  // How many did we go through?
  iEncryptionCount:=DecryptNumber;

  // Start with the last password and work back
  sTempPassword:=sPassword + IntToStr(iEncryptionCount);

  Result:=EncryptDecryptData(Copy(sData, 9, Length(sData) - 8), sTempPassword, False);
end;
(******************************************************************************)
function HashBytes(const sText: String): String;
var
  hCryptProvider: HCRYPTPROV;
  hHash: HCRYPTHASH;
  bHash: array[0..20] of Byte;
  dwHashLen: DWORD;
  pbContent: PByte;
  i: Integer;
begin
  dwHashLen:=20;
  pbContent:=Pointer(PChar(sText));

  // Initialization
  hHash:=0;Result:= '';

  if Wcrypt2.CryptAcquireContext(@hCryptProvider, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT or CRYPT_MACHINE_KEYSET) then
  begin
    if Wcrypt2.CryptCreateHash(hCryptProvider, CALG_SHA1, 0, 0, @hHash) then
      if Wcrypt2.CryptHashData(hHash, pbContent, Length(sText), 0) then
        if Wcrypt2.CryptGetHashParam(hHash, HP_HASHVAL, @bHash[0], @dwHashLen, 0) then
          for i:=0 to dwHashLen - 1 do
            //Result:= Result + IntToStr(bHash[i]);
            Result:=Result + Format('%.2x', [bHash[i]]);

     if (hHash<>0) then CryptDestroyHash(hHash);
    CryptReleaseContext(hCryptProvider, 0);
  end;
end;
(******************************************************************************)
procedure TCryptForm.BtnHashClick(Sender: TObject);
begin
  (*** Hash Bytes ***)
  if (EdtData.Text<>EmptyStr) then
    EdtHash.Text:=HashBytes(EdtData.Text)
end;

procedure TCryptForm.BtnCryptClick(Sender: TObject);
begin
  EdtCrypt.Text:=EmptyStr;EdtEncrypt.Text:=EmptyStr;

  (*** Encrypt, decrypt Data ***)
  if (EdtData.Text<>EmptyStr) then
    EdtCrypt.Text:=EncryptData(EdtData.Text, EdtPassword.Text);
  if (EdtCrypt.Text<>EmptyStr) then
    EdtEncrypt.Text:=DecryptData(EdtCrypt.Text,EdtPassword.Text);
end;

procedure TCryptForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

end.
