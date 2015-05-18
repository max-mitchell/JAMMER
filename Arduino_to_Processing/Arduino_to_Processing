
int Vval = 0;
int Pval = 0;
String out = "";
String oldOut = "";


void setup() {
  Serial.begin(9600);
}

void loop() {
  delay(30);
  Vval = analogRead(A0);

  if (Vval > 999)
    out = "V"+String(Vval)+"X";
  else if (Vval > 99) 
    out = "V0"+String(Vval)+"X";
  else if (Vval > 9)
    out = "V00"+String(Vval)+"X";
  else 
    out = "V000"+String(Vval)+"X";

  //if (out.equals(oldOut));
  //else
    Serial.println(out);  
  
    Pval = analogRead(A1);

  if (Pval > 999)
    out = "P"+String(Pval)+"X";
  else if (Pval > 99) 
    out = "P0"+String(Pval)+"X";
  else if (Pval > 9)
    out = "P00"+String(Pval)+"X";
  else 
    out = "P000"+String(Pval)+"X";

  //if (out.equals(oldOut));
  //else
    Serial.println(out);
  out = "";
  
  Serial.println("new");
}
