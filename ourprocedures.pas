unit ourprocedures;
interface
uses ourtype, System;

procedure check_fam_or_prof(k: string; var err:byte; var j: integer);
procedure check_inic(k: string; var err:byte);
procedure check_pol(k: string; var err:byte);

procedure check_day(k: string; var err_d: byte; var d: byte);
procedure check_month(k: string; var err_m: byte; var m: byte);
procedure check_year(k: string; var err_y: byte; var y: word);
procedure check_data(k : string; var err : byte; var d,m : byte; var y: word);
procedure check_old(DPA1, DR1: data; var err: byte);
procedure check_s_TD(TD:data; Sdata:data; var err, flag:byte);
procedure check_DZ(s: string; var DZ:data; TD: data; var err_true:boolean);

procedure check_ID(k: string; var err: byte; var numP: longint);
procedure check_PA(k:string; var err: byte; var PA2: byte);

procedure sort(var arr_SotrAtt_true:arr_SotrAtt; kol_SotrAtt:integer);
procedure printTrue(var f2:text; kol_SotrAtt:byte; arr_SotrAtt_true:arr_SotrAtt);
procedure resh(var f2:text; kol_sotr, kol_att: byte; arr_Sotr_true:arr_Sotr; arr_Att_true:arr_Att; var kol_SotrAtt: byte; var arr_SotrAtt_true: arr_SotrAtt; DZ: data);


implementation

//проверка фамилии или профессии на ошибки
procedure check_fam_or_prof(k: string; var err:byte; var j: integer); 
var
  i: integer;
begin
  j:=0;
  err := 0;
  if length(k)>20 
      then err := 1
      else if  not (k[1] in ['A'..'Z']) 
                    then err := 2
                    else begin
                      i := 2;
                      while i<=length(k)  do
                        begin
                          if  not (k[i] in ['a'..'z', '-']) 
                              then begin 
                                         j := i;
                                         err := 3;
                                   end;
                          inc(i);
                        end;
                    end;
end;

//проверка инициалов на ошибки
procedure check_inic(k: string; var err:byte); 
begin
 err := 0;
 if length(k)<>4 
      then err:=1
      else if not (k[1] in ['A'..'Z']) or not (k[3] in ['A'..'Z'])
                  then err:=2
                  else if (k[2] <> '.') or (k[4] <> '.') 
                          then err:=3;                        
end;

//проверка пола на ошибки
procedure check_pol(k: string; var err:byte); 
begin   
  err := 0;
  if length(k)<>1 
      then err:=1
      else if  not (k = 'M') and not (k = 'F')
                      then err:=2;
end;

procedure check_day(k: string; var err_d: byte; var d: byte); //проверка дня
var err1: integer;
begin
    val(copy(k,1,2), d, err1); //переводим день в число
    if (err1 <> 0)  
        then err_d := 12;
end;

procedure check_month(k: string; var err_m: byte; var m: byte); //проверка месяца
var err1: integer;
begin
    val(copy(k,4,2), m, err1); //переводим день в число
    if (err1 <> 0)  
        then err_m := 22
        else if (m < 1) or (m > 12) then err_m := 21;
end;

procedure check_year(k: string; var err_y: byte; var y: word); //проверка года
var err1: integer;
begin
    val(copy(k,7,4), y, err1); //переводим день в число
    if (err1 <> 0)  
        then err_y := 32;
end;

//проверка всей даты
procedure check_data(k : string; var err : byte; var d,m : byte; var y: word); 
var
  err_d, err_m, err_y : byte;
begin
  err:= 0;
  if length(k)<>10 
      then err:=1
      else if (k[3] <> '.') or (k[6] <> '.') 
              then err := 2
              else begin 
                    check_day(k, err_d, d);   //проверка дня на корректность
                    if err_d <> 0 
                        then err:= err_d
                        else begin
                              check_month(k, err_m, m); //проверка месяца на корректность
                              if err_m <> 0 
                                  then err:= err_m
                                  else begin
                                        check_year(k, err_y, y);  //проверка года на корректность
                                        if err_y <> 0
                                              then err:= err_y
                                              else case m of
                                                      2: if (y mod 4 = 0) or (y mod 100 <> 0) and (y mod 400 = 0) 
                                                                    then if (d < 1) and (d > 29) then err := 102
                                                                    else if (d < 1) and (d > 28) then err := 103;
                                                      4, 6, 9, 11: if (d < 1) and (d > 30) then err :=104;
                                                      else if (d < 1) and (d > 31) then err:=105;
                                                   end;
                                       end;
                              end;
                   end;
end;

//проверка на возраст
procedure check_old(DPA1, DR1: data; var err: byte);
begin
  err:=0;
  if (DR1.yyyy + 18 > DPA1.yyyy)
            then err:=100
            else if (DR1.yyyy + 18 = DPA1.yyyy) and (DR1.mm > DPA1.mm)
                        then err:=100
                        else if (DR1.yyyy + 18 = DPA1.yyyy) and (DR1.mm = DPA1.mm) and (DR1.dd >= DPA1.dd)
                                   then err:=100;
end;

//проверка с текущей датой
procedure check_s_TD(TD:data; Sdata:data; var err, flag:byte);
begin
  case flag of
    1: begin //текущая дата проверяется с датой заседания
          if (Sdata.yyyy < TD.yyyy)
                then err:=200
                else if (Sdata.yyyy = TD.yyyy) and (Sdata.mm < TD.mm)
                        then err:=200
                        else if (Sdata.yyyy = TD.yyyy) and (Sdata.mm = TD.mm) and (Sdata.dd < TD.dd)
                                   then err:=200;
      end;
    2: begin //текущая дата проверяется с датой последней аттестации
          if (Sdata.yyyy > TD.yyyy)
                then err:=200
                else if (Sdata.yyyy = TD.yyyy) and (Sdata.mm > TD.mm)
                        then err:=200
                        else if (Sdata.yyyy = TD.yyyy) and (Sdata.mm = TD.mm) and (Sdata.dd > TD.dd)
                                   then err:=200;
      end;
  end;
end;


//проверка даты заседания
procedure check_DZ(s: string; var DZ:data; TD: data; var err_true:boolean);
var
  err, err_d, err_m, err_y, flag : byte;
begin
  err:= 0;
  if length(s)<> 10 
      then err:=1
      else if (s[3] <> '.') or (s[6] <> '.') 
              then err := 2
              else begin
                      check_day(s, err_d, DZ.dd);//проверка дня на корректность
                      if err_d <> 0 
                          then err:= err_d
                          else check_month(s, err_m, DZ.mm); //проверка месяца на корректность
                      if err_m <> 0 
                          then err:= err_m
                          else check_year(s, err_y, DZ.yyyy);  //проверка года на корректность
                      if err_y <> 0
                          then err:= err_y
                          else begin
                                  flag:=1; 
                                  check_s_TD(TD,DZ,err,flag); //текущая дата проверяется с датой заседания
                                  if err = 0 
                                  then case DZ.mm of 
                                      2: if (DZ.yyyy mod 4 = 0) or (DZ.yyyy mod 100 <> 0) and (DZ.yyyy mod 400 = 0) 
                                            then if (DZ.dd < 1) and (DZ.dd > 29) then err := 102
                                            else if (DZ.dd < 1) and (DZ.dd > 28) then err := 103;
                                      4, 6, 9, 11: if (DZ.dd < 1) and (DZ.dd > 30) then err :=104;
                                      else if (DZ.dd < 1) and (DZ.dd > 31) then err:=105;
                                  end;
                              end;
                    end;          
    //вывод ошибки связанной с датой заседания
    if err <> 0 
          then begin
              err_true:= true;
              case err of
                     1:  writeln('Ошибка при вводе даты заседания - ' , s, ' - Длина даты должна быть 10 символов.'); 
                     2:  writeln('Ошибка при вводе даты заседания - ' , s, ' - Замечен(-ы) недопустимый(-ые) разделитель(-и) используйте в качестве разделителя(-ей) точки.');                            
                     12: writeln('Ошибка при вводе даты заседания(день) - ' , s, ' - Замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');
                     21: writeln('Ошибка при вводе даты заседания - ' , s, ' - В значении месяц встречено недопустимое значение. Значение должно соответствовать (1..12).');                        
                     22: writeln('Ошибка при вводе даты заседания(месяц) - ' , s, ' - Замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');                              
                     32: writeln('Ошибка при вводе даты заседания(год) - ' , s, ' - Замечен(-ы) недопустимый(-ые) символ(-ы) используйте для ввода цифры.');                              
                     102:writeln('Ошибка при вводе даты заседания - ' , s, ' - В значении день встречено недопустимое значение. Для этого месяца ', DZ.mm, ' и этого года ', DZ.yyyy, ' значения должны соответствовать (1..29).');                              
                     103:writeln('Ошибка при вводе даты заседания - ' , s, ' - В значении день встречено недопустимое значение. Для этого месяца ', DZ.mm, ' и этого года ', DZ.yyyy, ' значения должны соответствовать (1..28).');                              
                     104:writeln('Ошибка при вводе даты заседания - ' , s, ' - Встречено недопустимое значение. Для этого месяца ', DZ.mm, ' значения должны соответствовать (1..30).');                              
                     105:writeln('Ошибка при вводе даты заседания - ' , s, ' - Встречено недопустимое значение. Для этого месяца ', DZ.mm, ' значения должны соответствовать (1..31).');                              
                     200:writeln('Ошибка при вводе даты заседания - ' , s, ' -  Дата заседания должна превыщать Текущую дату');                             
                   end;
           end;               
end;


procedure check_ID(k: string; var err: byte; var numP: longint); //проверка номера паспорта
var errP:integer;
begin
  err:=0;
  if length(k) <> 6 
        then err:=1
        else begin
                val(k,numP,errP);
                if errP<>0 then err:=2;
             end;
end;

procedure check_PA(k:string; var err: byte; var PA2: byte); //проверка периодичности аттестации
var err1:integer;
begin
  err:=0;
  if length(k)<>2 then err:=1
                  else begin
                       val(k, PA2, err1);
                       if (err1 <> 0) then err:=2
                                      else if (PA2<12) or (PA2>36) then err:=3;
                  end;
end;


{Полученный список должен быть отсортирован по профессии и включать в себя фамилии и инициалы сотрудников и дату последней аттестации.}

procedure sort(var arr_SotrAtt_true:arr_SotrAtt; kol_SotrAtt:integer);
var c: SotrAtt;
    i, j:integer;
begin
  for i := kol_SotrAtt downto 2 do 
    for j := 1 to kol_SotrAtt-1  do 
        begin
            if arr_SotrAtt_true[j].Prof > arr_SotrAtt_true[j+1].Prof 
                then begin
                      c := arr_SotrAtt_true[j];
                      arr_SotrAtt_true[j] := arr_SotrAtt_true[j+1];
                      arr_SotrAtt_true[j+1] := c; 
                     end;
        end;
end;

procedure printTrue(var f2:text; kol_SotrAtt:byte; arr_SotrAtt_true:arr_SotrAtt);
var 
  ii, v, k: integer;
  ID2: longint;
begin
  //вывод верных строк
  
  for k := 1 to kol_SotrAtt do
    with arr_SotrAtt_true[k] do
    begin
      
      write(f2, Prof); //вывод профессии
      for ii := length(Prof) to 20 do
        write(f2, ' ');
      
      write(f2, Fam, ' '); //вывод фамилии
      for ii := length(Fam) to 20 do
        write(f2, ' ');
      
      write(f2, I:4, ' '); //вывод инициалов
      
      //вывод даты
      if DPA.dd < 10 
            then write(f2, '0', DPA.dd, '.')
            else write(f2, DPA.dd, '.');
      if DPA.mm < 10
            then write(f2, '0', DPA.mm, '.', DPA.yyyy, ' ')
            else write(f2, DPA.mm, '.', DPA.yyyy, ' ');
                        
    
      
      //вывод номера паспорта 099999
      v:=0;
      if (ID = 0) //000000
         then writeln(f2, '000000')
         else if ID < 100000 //099999
                  then begin
                          ID2:=ID; 
                          while ID2 > 0 do //подсчет количества цифр в номере паспорта
                            begin
                                ID2:=ID2 div 10;
                                inc(v);
                            end;
                          for ii:=v to 5 do write(f2, '0'); //вывод нулей перед числом
                          writeln(f2, ID);
                       end
                  else writeln(f2, ID);                    
    end;
end;


procedure resh(var f2:text; kol_sotr, kol_att: byte; arr_Sotr_true:arr_Sotr; arr_Att_true:arr_Att; var kol_SotrAtt: byte; var arr_SotrAtt_true: arr_SotrAtt; DZ: data);
var
   DA: data;
   ii, jj, PA_y, PA_m: byte;
begin
  PA_y:= 0;
  PA_m:=0;
  for ii:=1 to kol_sotr do
      for jj:=1 to kol_att do
        if arr_Sotr_true[ii].prof = arr_Att_true[jj].prof //когда нашли профессию сотрудника из списка
                then begin 
                          PA_y := (arr_Sotr_true[ii].DPA.mm + arr_Att_true[jj].PA) div 12; //определяем сколько лет и месяцев проходит периодичность аттестации
                          PA_m := (arr_Sotr_true[ii].DPA.mm + arr_Att_true[jj].PA) mod 12;
                          DA.yyyy := arr_Sotr_true[ii].DPA.yyyy + PA_y;
                          DA.mm := PA_m;                          
                          if DA.yyyy < DZ.yyyy
                                then begin  
                                                inc(kol_SotrAtt);
                                                arr_SotrAtt_true[kol_SotrAtt].Fam:=arr_Sotr_true[ii].Fam; //если все верно то записываем отрудника
                                                arr_SotrAtt_true[kol_SotrAtt].I:=arr_Sotr_true[ii].I;
                                                arr_SotrAtt_true[kol_SotrAtt].Prof:=arr_Sotr_true[ii].Prof;
                                                arr_SotrAtt_true[kol_SotrAtt].DPA:=arr_Sotr_true[ii].DPA;
                                                arr_SotrAtt_true[kol_SotrAtt].ID:=arr_Sotr_true[ii].ID;
                                     end
                                else if (DA.yyyy = DZ.yyyy) and (DA.mm <= DZ.mm)
                                      then begin  
                                                inc(kol_SotrAtt);
                                                arr_SotrAtt_true[kol_SotrAtt].Fam:=arr_Sotr_true[ii].Fam; //если все верно то записываем отрудника
                                                arr_SotrAtt_true[kol_SotrAtt].I:=arr_Sotr_true[ii].I;
                                                arr_SotrAtt_true[kol_SotrAtt].Prof:=arr_Sotr_true[ii].Prof;
                                                arr_SotrAtt_true[kol_SotrAtt].DPA:=arr_Sotr_true[ii].DPA;
                                                arr_SotrAtt_true[kol_SotrAtt].ID:=arr_Sotr_true[ii].ID;
                                            end;
                       end;                            
end;

end.