unit ourtype;
interface
const N = 10;

type data = record
  dd: byte;    //31
  mm: byte;    //12
  yyyy: word;  //1960-2001
end;

type Sotr = record
      Fam: string[20];    //фамилия
      i: string[4];       //инициалы
      pol: string[1];     //пол
      prof: string[20];   //профессия
      DR: data;           //дата рождения
      DPA: data;          //дата атестации
      ID: longint;        //номер паспорта
    end;
    arr_Sotr = array[1..N] of Sotr;
    
type Att = record
      Prof : string[20];  //профессия 
      PA : byte;          //периодичность аттестации (12..36)
    end; 
    arr_Att = array[1..N] of Att;
    
type SotrAtt = record
      Fam: string[20];    //фамилия
      i: string[4];       //инициалы
      prof: string[20];   //профессия
      DPA: data;          //дата атестации
      ID: longint;        //номер паспорта
    end;
    arr_SotrAtt = array[1..N] of SotrAtt;
 
 
implementation
end.