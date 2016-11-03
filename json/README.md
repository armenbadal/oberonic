
# JSON Օբերոն-2֊ի համար

Այստեղ փորձում եմ Օբերոն֊2 լեզվի համար իրականացնել JSON
մոդուլը։ Իմ նախնական պլաններով այն պետք է ծրագրավորողին
տրամադրի JSON֊ում օգտագործվող տվյալների կառուցվածքներն ու
դրանց նմուշները կառուցելու ինտերֆեյսը (կոնստրուկտորներ)։ 
Պետք է կարողանա ֆայլից կարդալ JSON լեզվով գրված տվյալներն
ու կառուցի համապատասխան ծառը։ Եվ պետք է կարողանա ծառը
գրառել ֆայլում՝ հնարավորինս ընթեռնելի եղանակով։

## JSON լեզվի քերականությունը

JSON֊ի քերականությունը վերցրել եմ http://json.org/ կայքից,
որտեղ այն բերված է BNF գրառմամբ և, վերլուծիչի իրականացումը
հեշտացնելու համար, ձևափոխել եմ EBNF գրառման։ Ահա այն․

````
Script = Object.
Object = '{' [STRING ':' Value {',' STRING ':' Value}] '}'.
Value  = STRING | NUMBER | Array | Object | 'true' | 'false' | 'null'.
Array  = '[' [Value {',' Value}] ']'.
````

Քերականության մեջ գլխատառերով գրառված տերմինալային սիմվոլները,
սահմանվում են հետևյալ կերպ․

````
STRING   = '"' {Char} '"'.
Cahr     = any-Unicode-character-except-"-or-\-or-control-character
         | '\"' | '\\' | '\/' | '\b' | '\f' | '\n' | '\r' | '\t'
         | '\u' four-hex-digits.
NUMBER   = ['-'] Integer [Fraction] [Exponent].
Integer  = '0' | ('1'..'9'){('0'..'9')}.
Fraction = ('e'|'E')[('+'|'-')]('0'..'9'){'0'..'9')}.
Exponent = '.'('0'..'9'){'0'..'9')}.
````

## Տվյալների կառուցվածքները

Քերականությունից երևում է, որ JSON ֆայլում հանդիպում են հետևյալ
տիպի օբյեկտները․ _տողեր_, _իրական թվեր_, _բուլյան_ հաստատուններ,
_`null`_ հաստատունը, _զանգվածներ_ և _օբյեկտներ_։ Այդ տիպերի
համար սահմանել եմ հետևյալ անունները․

````oberon
TYPE
  Value*   = POINTER TO ValueDesc;
  Pair*    = POINTER TO PairDesc;
  Object*  = POINTER TO ObjectDesc;
  Array*   = POINTER TO ArrayDesc;
  String*  = POINTER TO StringDesc;
  Number*  = POINTER TO NumberDesc;
  Boolean* = POINTER TO BooleanDesc;
````

`ValueDesc` գրառումը, որը պարունակում է իր հաջորդին կապվելու
համար նախատեսված միակ `next` ցուցիչը, միաժամանակ ծառայում է
նաև որպես `null` հաստատունի մոդել։

````oberon
TYPE
  ValueDesc = RECORD
    next : Value
  END;
````

Տողերի, թվերի ու բուլյան արժեքների մոդելներն ընդլայնում են `ValueDesc` տիպը։

````oberon
  StringDesc = RECORD(ValueDesc)
    data : ARRAY 256 OF CHAR
  END;

  NumberDesc = RECORD(ValueDesc)
    value- : REAL
  END;

  BooleanDesc = RECORD(ValueDesc)
    value- : BOOLEAN
  END;
````

`Object`֊ը զույգերի ցուցակ է, իսկ զույգը՝ `Pair`, 

````oberon
  PairDesc = RECORD
    key- : String;
    value- : Value;
    next : Pair;
  END;

  ObjectDesc = RECORD(ValueDesc)
    elems, ep : Pair
  END;

  ArrayDesc = RECORD(ValueDesc)
    count- : INTEGER;
    elems : POINTER TO ARRAY OF Value
  END;
````


## Ծառի գրառումը ֆայլի մեջ

## Ֆայլի վերլուծությունը


