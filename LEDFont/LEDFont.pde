int pins[17]= {
  -1, 5, 4, 3, 2, 14, 15, 16, 17, 13, 12, 11, 10, 9, 8, 7, 6};
  
int cols[8] = {
  pins[13], pins[3], pins[4], pins[10], pins[06], pins[11], pins[15], pins[16]};

int rows[8] = {
  pins[9], pins[14], pins[8], pins[12], pins[1], pins[7], pins[2], pins[5]};

const byte font[165]={ 0,0,0,0,30,62,104,200,254,254,0,254,254,146,146,254,108,0,124,254,130,130,198,68,0,254,254,130,130,254,124,0,124,254,146,146,146,130,0,126,254,144,144,144,128,0,124,254,130,146,158,158,0,254,254,16,16,254,254,0,254,254,0,132,134,130,254,252,0,254,254,16,56,238,198,0,252,254,2,2,2,2,0,254,254,96,48,96,254,254,0,254,254,96,48,254,254,0,124,254,130,130,254,124,0,254,254,144,144,240,96,0,124,254,130,134,252,122,0,254,254,144,144,254,110,0,98,242,146,158,140,0,128,128,254,254,128,128,0,252,254,2,2,254,252,0,240,248,12,6,12,248,240,0,254,254,12,24,12,254,254,0,0,0,0, };
const int offsets[96]={ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,11,18,25,32,39,46,53,60,63,69,76,83,91,98,105,112,119,126,132,139,146,154,162,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, };
const int widths[96]={ 4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,7,7,7,7,7,3,6,7,7,8,7,7,7,7,7,6,7,7,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, };

int dispSpeed = 5;
byte bitmap[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };

int buffer[128];
int bufLen=2;

void setup() {
  Serial.begin(9600);
  for (int i = 1; i <17; i++) {
    pinMode(pins[i], OUTPUT);
  }
  for (int i = 0; i < 8; i++) {
    digitalWrite(cols[i], LOW);  
    digitalWrite(rows[i], LOW);
  }
  defaultMessage();
}

void loop() {
  for (int c = 0; c < bufLen; c++){
    const int idx=offsets[buffer[c]-32];
    int lw=widths[buffer[c]-32];
    for (int y = 0; y < lw; y++){
      scroll();
      bitmap[7] = font[idx+y];
      for (int i = 0; i < dispSpeed; i++) {
        display();
        Serial.available();
      }
      dispSpeed=map(analogRead(19),0,1023,30,2);
    }
  }
  checkInput();
}

void checkInput() {
  int num=Serial.available();
  if (num>0) {
    int len=0;
    for(int i=0; i<num; i++) {
      int c=Serial.read();
      if (c>31) {
        buffer[len]=min(max(c,32),127);
        len++;
      } else {
        Serial.print("err=");
        Serial.println(c,DEC);
      }
    }
    if (len>0) {
      bufLen=len;
    } else {
      defaultMessage();
    }
    Serial.println("msg");
    for(int i=0; i<bufLen; i++) {
      Serial.print(buffer[i],DEC);
      Serial.print("=>");
      Serial.println(widths[buffer[i]-32],DEC);
    }
    Serial.println("len");
    Serial.println(bufLen);
  }
}

void defaultMessage() {
  buffer[0]=65;
  buffer[1]=32;
  bufLen=2;
}

void scroll(){
  for (int x = 0; x < 7; x++){
    bitmap[x] = bitmap[x + 1];
  }
}


void display() {
  for (int col = 0; col < 8; col++){
    for (int row = 0,b=128; row < 8; row++,b>>=1){
        digitalWrite(rows[row], (bitmap[col] & b) ? HIGH : LOW);
    }
    digitalWrite(cols[col], LOW);
    delay(2);
    digitalWrite(cols[col], HIGH);
  }
}
