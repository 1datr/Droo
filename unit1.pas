unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls, MaskEdit, ComCtrls, IniPropStorage, LCLclasses, LCLtype,
  LCLproc, Process;

type

  { TForm1 }

  TForm1 = class(TForm)
    AdminLogin: TLabeledEdit;
    AdminEmail: TLabeledEdit;
    AdminPassw: TMaskEdit;
    Button1: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    ConfigManager: TIniPropStorage;
    Label1: TLabel;
    DBName: TLabeledEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    host: TLabeledEdit;
    PBMakeSite: TProgressBar;
    SiteLang: TLabeledEdit;
    Modulelist: TMemo;
    BeforeExec: TMemo;
    IniOpenDialog: TOpenDialog;
    IniSaveDialog: TSaveDialog;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    serverspath: TLabeledEdit;
    nesteddir: TLabeledEdit;
    LblConfig: TLabel;
    SiteName: TLabeledEdit;
    DBPrefix: TLabeledEdit;
    DBUser: TLabeledEdit;
    DBServer: TLabeledEdit;
    MainMenu1: TMainMenu;
    DBPassw: TMaskEdit;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    StatusBar1: TStatusBar;
    ToggleBox1: TToggleBox;
    procedure Button1Click(Sender: TObject);
    procedure ConfigManagerRestoreProperties(Sender: TObject);
    procedure ConfigManagerRestoringProperties(Sender: TObject);
    procedure ConfigManagerSavingProperties(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure GroupBox4Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
  private
    { private declarations }
    procedure FillControls;       // fill all controlls
    procedure FillIni;            // fill inifile manager fields
    function CheckConfig: boolean;
    procedure RunSomeScript(script: widestring);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
//  self.ConfigManager.
  ConfigManager.IniFileName:='Droo.ini';
  FillControls;
end;

procedure TForm1.GroupBox1Click(Sender: TObject);
begin

end;

procedure TForm1.GroupBox4Click(Sender: TObject);
begin

end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  If self.IniOpenDialog.Execute then
     begin
     ConfigManager.IniFileName:=IniOpenDialog.FileName;
     FillControls;
     end;
end;

procedure TForm1.ConfigManagerRestoringProperties(Sender: TObject);
begin
     ConfigManager.IniFileName:='Droo.ini';
     FillControls;
end;

procedure TForm1.ConfigManagerRestoreProperties(Sender: TObject);
begin

end;

function TForm1.CheckConfig: boolean;
begin
  if (host.Text='')   then
     begin
     Application.MessageBox('Введите параметр хост','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else if(DBServer.Text='') then
     begin
     Application.MessageBox('Введите параметр Сервер БД','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else if(serverspath.Text='') then
     begin
     Application.MessageBox('Введите параметр директория сервера','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else if(DBUser.Text='') then
     begin
     Application.MessageBox('Введите параметр пользователь БД','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else if(DBName.Text='') then
     begin
     Application.MessageBox('Введите параметр имя БД','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else if(SiteLang.Text='') then
     begin
     Application.MessageBox('Введите параметр язык','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else if(AdminPassw.Text='') then
     begin
     Application.MessageBox('Пароль администратора не должен быть пустым','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else if(DBprefix.Text='') then
     begin
     Application.MessageBox('Введите параметр префикс таблиц БД','Не готово к пуску',MB_ICONWARNING);
     Result:=false;
     end
  else
     Result:=true;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  P_init: TProcess;
  buttonSelected : Integer;
begin
  if CheckConfig then
  begin

     if(nesteddir.Text<>'')then
     begin
        // схема под денвер
       // Chdir(serverspath.Text);
        if FileExists(serverspath.Text+'\'+host.Text)  then
        begin
           // Отображение диалога с подтверждением
           buttonSelected := MessageDlg('Такой сайт уже есть. Заменить его?',mtError, mbOKCancel, 0);

           // удалить папку чтобы качать по новой
           if buttonSelected = mrOK     then
              RmDir(host.Text);
        end;
        if not FileExists(host.Text)  then
           begin
           PBMakeSite.Max:=100;
           PBMakeSite.Visible:=true;
           // качнуть друпал
           PBMakeSite.Position:=2;
           RunSomeScript(BeforeExec.Text+char(10)+char(13)
           +'cd '+serverspath.Text+char(10)+char(13)
           +'md '+host.Text+char(10)+char(13)
           +'cd '+host.Text+char(10)+char(13)
           +'drush dl --drupal-project-rename='+nesteddir.Text);
           // качнуть модули
           PBMakeSite.Position:=27;
           RunSomeScript(BeforeExec.Text+char(10)+char(13)
           +'cd '+serverspath.Text+char(10)+char(13)
           +'cd '+host.Text+char(10)+char(13)
           +'cd '+nesteddir.Text+char(10)+char(13)
           +'drush dl '+Modulelist.Text);
           // установка сайта
           PBMakeSite.Position:=52;
           RunSomeScript(BeforeExec.Text+char(10)+char(13)
           +'cd '+serverspath.Text+char(10)+char(13)
           +'cd '+host.Text+char(10)+char(13)
           +'cd '+nesteddir.Text+char(10)+char(13)
           +'drush site-install --db-url=mysql://'+DBUser.Text+':'+DBPassw.Text+
           '@'+DBServer.Text+'/'+DBName.Text+' --db-prefix='+DBPrefix.Text+
           ' --account-mail='+AdminEmail.Text+' --account-name='+AdminLogin.Text+
           ' --account-pass='+AdminPassw.Text+' --site-mail='+AdminEmail.Text+' --locale='+SiteLang.Text);
           // енейбл модулей из списка
           PBMakeSite.Position:=77;
           RunSomeScript(BeforeExec.Text+char(10)+char(13)
           +'cd '+serverspath.Text+char(10)+char(13)
           +'cd '+host.Text+char(10)+char(13)
           +'cd '+nesteddir.Text+char(10)+char(13)
           +'drush en '+Modulelist.Text);

           PBMakeSite.Visible:=false;
           end;
     end
     else        //
     begin

     end;
  {                       vf gjl
     P := TProcess.Create(nil);

     P.CommandLine := 'cd '+serverspath.Text;
     P.Options := [poUsePipes];
     //WriteLn('-- executing --');
     P.Execute;

     P.CommandLine := 'md '+host.Text;
     P.Execute;  }
  end;
end;

procedure TForm1.ConfigManagerSavingProperties(Sender: TObject);
begin

end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  If IniSaveDialog.Execute then
     begin
     FillIni;
     ConfigManager.IniFileName:=IniSaveDialog.FileName;
     ConfigManager.Save;
     self.LblConfig.Caption:=self.ConfigManager.IniFileName;
     end;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
    FillIni;
    ConfigManager.Save;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  self.Close;
end;

procedure TForm1.ToggleBox1Change(Sender: TObject);
begin
  If SelectDirectoryDialog.Execute then
     serverspath.Text:=SelectDirectoryDialog.FileName;
end;
// Запустить скрипт
procedure TForm1.RunSomeScript(script: widestring);
var f: TextFile; // Текстовая переменная
    P_init: TProcess;
begin
     //{$IFDEF WIN32}
     AssignFile(f,'temp.bat');
     rewrite(f);         // создаем файла
     writeln(f, script); // Сохраняем введённую информацию в файл
     CloseFile(f); // Закрываем файл

     P_init := TProcess.Create(nil);
     P_init.CommandLine := 'temp.bat';
           //P_init.Executable:='cmd';
     P_init.Options := [poWaitOnExit];
     P_init.Execute;
     DeleteFile('temp.bat');
     //{$ENDIF}
end;

procedure TForm1.FillControls;
begin
     self.LblConfig.Caption:=self.ConfigManager.IniFileName;

     serverspath.Text:=self.ConfigManager.StoredValue['ServDir'];
     nesteddir.Text:=self.ConfigManager.StoredValue['NestedDir'];
     Modulelist.Text:=self.ConfigManager.StoredValue['Modulelist'];
     BeforeExec.Text:=self.ConfigManager.StoredValue['CodeBefore'];

     DBServer.Text:=self.ConfigManager.StoredValue['DBServer'];
     DBUser.Text:=self.ConfigManager.StoredValue['DBUser'];
     DBPassw.Text:=self.ConfigManager.StoredValue['DBPassw'];
     DBName.Text:=self.ConfigManager.StoredValue['DBName'];
     DBPrefix.Text:=self.ConfigManager.StoredValue['DBprefix'];

     SiteName.Text:=self.ConfigManager.StoredValue['SiteName'];
     SiteLang.Text:=self.ConfigManager.StoredValue['SiteLang'];
     AdminLogin.Text:=self.ConfigManager.StoredValue['AdminLogin'];
     AdminPassw.Text:=self.ConfigManager.StoredValue['AdminPassw'];
     AdminEmail.Text:=self.ConfigManager.StoredValue['AdminEmail'];
end;

procedure TForm1.FillIni;
begin
     self.ConfigManager.StoredValue['ServDir']:=serverspath.Text;
     self.ConfigManager.StoredValue['NestedDir']:=nesteddir.Text;
     self.ConfigManager.StoredValue['Modulelist']:=Modulelist.Text;
     self.ConfigManager.StoredValue['CodeBefore']:=BeforeExec.Text;

     self.ConfigManager.StoredValue['DBServer']:=DBServer.Text;
     self.ConfigManager.StoredValue['DBUser']:=DBUser.Text;
     self.ConfigManager.StoredValue['DBPassw']:=DBPassw.Text;
     self.ConfigManager.StoredValue['DBName']:=DBName.Text;
     self.ConfigManager.StoredValue['DBprefix']:=DBPrefix.Text;

     self.ConfigManager.StoredValue['SiteName']:=SiteName.Text;
     self.ConfigManager.StoredValue['SiteLang']:=SiteLang.Text;
     self.ConfigManager.StoredValue['AdminLogin']:=AdminLogin.Text;
     self.ConfigManager.StoredValue['AdminPassw']:=AdminPassw.Text;
     self.ConfigManager.StoredValue['AdminEmail']:=AdminEmail.Text;
end;

end.

