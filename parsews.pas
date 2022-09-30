unit parsews;
interface
uses ourtype, ourprocedures;


procedure parsewAtt(s1:string; a:integer; var rec_Att_true: Att; var err_true: boolean);
procedure parsewSotr(s:string; a:integer; var rec_sotr_true: Sotr; var err_true: boolean; TD: data);

procedure read_in1(f1:text; var f2:text; kol_att:byte; arr_Att_true: arr_Att; DZ, TD: data);
procedure read_in2(f3:text; var arr_att_true: arr_Att; var kol_att:byte);


implementation

//парсевка строк в файле in2
procedure parsewAtt(s1:string; a:integer; var rec_Att_true: Att; var err_true: boolean);
var
  i,q,j: integer;
  k: string;
  err, PA2:byte;
  
begin
  q:=0; //счетчик полей
  k:=''; //строка которая сохраняет поле
  s1:=s1+' ';
  i:= 1;
  PA2:= 0;
  while (i <= length(s1)) and (q < 3)  do begin
    if s1[i]<>' ' 
        then k:=k+s1[i]
        else if k='' then begin
          if q=0 then begin  
          writeln('Ошибка в файле in2,строка пустая');
          q:=11;
          end else begin
          writeln('Ошибка в файле in2 в строке' ,a, 'между полями ' ,q,' и ',q+1, ' больше одного пробела');
          q:=11;
          end
          
        end else
        begin
          inc(q);
          case q of
            1:  begin              
                    check_fam_or_prof(k,err,j);
                    case err of
                      0: rec_Att_true.Prof := k;
                      1: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - длина поля "Профессия" не должна превышать 20 символов.');
                              q:=11;
                         end;
                      2: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - ошибка в первой букве профессии. Первая буква должна быть заглавной латинской.');
                              q:=11;
                         end;
                      3: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - в профессии запрещенный символ: ' + k[j] + ', номер символа: ' + j + '. Используйте для записи фамилии только прописные латинские буквы');
                              q:=11;
                         end;
                    end;
                end;
            2: begin 
                   check_PA(k, err, PA2);
                   case err of
                     0: rec_Att_true.PA := PA2;
                     1: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - длина поля "Периодичность аттестации" должна быть 2 символа.');
                              q:=11;
                        end;
                     2: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - в поле "Периодичность аттестации" замечен недопустимый символ, используйте для ввода цифры.');
                              q:=11;
                        end;
                     3: begin
                              writeln('Ошибка в файле in2 в строке ', a, ' - ' , k, ' - в поле "Периодичность аттестации" встречено недопустимое значение. Значение должно соответствовать (12..36).');
                              q:=11;
                        end;
                   end;
             end;
         end; 
         k:='';
        end;
       i:=i+1; 
    end;
    if (q = 0) then begin
                          writeln('Ошибка в файле in2 в строке ', a, ' - пустая строка.');
                          err_true:=true;
                    end 
               else if (q > 0) and (q < 2) 
                        then begin
                                  writeln('Ошибка в файле in2 в строке ', a, ' - недостаточное количество данных.');
                                  err_true:=true;
                             end
                        else if (q > 2) and (q <> 11)
                                      then begin
                                                writeln('Ошибка в файле in2 в строке ', a, ' - переизбыток количества данных.');
                                                err_true:=true;
                                            end
                                      else if (q = 11) then err_true:=true;
end;






  //работа с файлом профессий
procedure read_in2(f3:text; var arr_att_true: arr_Att; var kol_att:byte);
var a, flag, jj: byte;
    err_true:boolean;
    s1: string;
    rec_Att_true: Att;
begin
  while not eof(f3) and (a < n) do 
  begin
    err_true := false;
    readln(f3, s1);
    a := a + 1;
    parsewAtt(s1, a, rec_Att_true, err_true); //парсевка строки
    
    //подсчет верных строк и внесение в массив, проверка на уникальность профессии
    if not err_true 
        then begin 
                 flag:=0; //проверка на уникальность профессии
                 for jj:=1 to kol_att do 
                                if arr_att_true[jj].Prof = rec_att_true.Prof
                                      then begin 
                                                writeln('Ошибка в файле in2 в строке ', a, ' - ', rec_att_true.Prof, ' - такая профессия уже есть.');
                                                flag:=1;
                                      end;
                                if (flag<>1) 
                                            then begin
                                                      inc(kol_att);
                                                      arr_Att_true[kol_att] := rec_Att_true;
                                            end;
              end;           
  end;

  if not eof(f3) then writeln('Ошибка в файле in2 –  файл содержит больше ', N, ' строк. Программа обработает только первые 100 строк' );
end;

//работа с файлом сотрудников, только в том случае если есть верные строки в файле с профессиями
procedure read_in1(f1:text; var f2: text; kol_att:byte; arr_Att_true: arr_Att; DZ, TD: data);
var
  flag, flag2, jj, a, kol_Sotr, kol_SotrAtt: byte;
  rec_Sotr_true: Sotr;
  arr_Sotr_true: arr_Sotr;
  err_true: boolean;
  arr_SotrAtt_true: arr_SotrAtt;
  s: string;
begin
  a := 0;
  if (kol_att <> 0) //если в файле in2 нет верных строк, то файл in1 не будет проверяться
     then begin
            while not eof(f1) and (a < n) do 
            begin
              err_true := false;
              readln(f1, s);
              a := a + 1;
              parsewSotr(s, a, rec_sotr_true, err_true, TD);
    
              //подсчет верных строк и внесение в массив, проверка на уникальность номера паспорта
              if not err_true 
                  then begin
                            flag:=0; //проверка на уникальность номера напспорта
                            for jj:=1 to kol_sotr do 
                                      if arr_sotr_true[jj].ID = rec_sotr_true.ID
                                            then begin 
                                                    writeln('Ошибка в файле in1 в строке ', a, ' - ', rec_sotr_true.ID, ' - такой номер паспорта уже есть.');
                                                    flag:=1;
                                                 end;
                                      if (flag = 0) 
                                            then begin
                                                      flag2:=0; //проверка есть ли профессия сотрудника в справочнике (0 - нет такой профессии. 1 - есть такая профессия)
                                                      for jj:=1 to kol_att do
                                                                if arr_att_true[jj].Prof = rec_sotr_true.Prof
                                                                      then begin
                                                                              inc(kol_sotr);
                                                                              arr_sotr_true[kol_sotr] := rec_sotr_true;
                                                                              flag2:=1;
                                                                           end ;   
                                                     if flag2 = 0 
                                                          then writeln('Ошибка в файле in1 в строке ', a, ' - ', rec_sotr_true.prof, ' - такой профессии в файле in2 не найдено');
                                                 end;                 
                       end;
          end;
  
         if not eof(f1) then writeln('in1 Кол-во строк больше ', N, ' строк');
  //формирование списка сотрудников, которые не прошли аттестации до указанной даты
         if (kol_sotr <> 0) 
              then begin
                        resh(f2,kol_sotr,kol_att,arr_Sotr_true,arr_Att_true, kol_SotrAtt, arr_SotrAtt_true, DZ);   //решение задачи
                        if kol_SotrAtt = 0 
                              then writeln(f2, 'До указанной даты заседания ', DZ.dd, '.', DZ.mm, '.', DZ.yyyy,' нет сторудников, которые подлежат аттестации')
                              else begin
                                      sort(arr_SotrAtt_true, kol_SotrAtt);         //сортировка
                                      writeln(f2, 'До указанной даты заседания ', DZ.dd, '.', DZ.mm, '.', DZ.yyyy,' данные сотрудники не прошли аттестацию');
                                      printTrue(f2,kol_SotrAtt,arr_SotrAtt_true);  //вывод в файл 2 верных строк
                                      writeln('Программа завершила работу');
                                   end;
                   end
              else writeln('В файле in1 нет корректных строк');
        end
    else writeln('В файле in2 нет корректных строк');
end;


end.