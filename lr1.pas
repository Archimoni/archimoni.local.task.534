program lr1;

uses ourtype, ourprocedures, parsews, system;

var
  tekdata: DateTime;
  DZ, TD: data;
  f1, f2, f3: text;
  s: string;
  kol_Att: byte;
  err_true: boolean;
  arr_Att_true: arr_Att;
  
begin
  
  assign(f1, 'in.txt'); reset(f1);
  assign(f3, 'in2.txt'); reset(f3);
  assign(f2, 'outTrue.txt'); rewrite(f2);
  kol_att := 0;
  
  //введение текущей даты
  tekdata:=DateTime.Now;
  TD.dd:=tekdata.Day;
  TD.mm:=tekdata.Month;
  TD.yyyy:=tekdata.Year;
  
  //ввод даты заседания
   repeat
      err_true := false;
      writeln('Здравствуйте! Для начала работы с программой введите дату заседания аттестационной комиссии в формате dd.mm.yyyy, где dd – день, mm – месяц, yyyy – год. Если значения дня и/или месяца меньше 10 припишите перед днём и/или месяцем ноль.');
      readln(s);
      check_DZ(s, DZ, TD, err_true);
   until err_true = false;
 
  //работа с файлом профессий
  read_in2(f3, arr_att_true, kol_att);
  //работа с файлом сотрудников, только в том случае если есть верные строки в файле с профессиями
  read_in1(f1, f2, kol_att, arr_Att_true, DZ, TD);
  
  close(f1);
  close(f2);
  close(f3);
end.