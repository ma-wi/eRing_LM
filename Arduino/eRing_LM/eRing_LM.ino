#include <CapacitiveSensor.h>

CapacitiveSensor   cs1 = CapacitiveSensor(8, 3);
CapacitiveSensor   cs2 = CapacitiveSensor(2, 9);
CapacitiveSensor   cs3 = CapacitiveSensor(4, 7);
CapacitiveSensor   cs4 = CapacitiveSensor(5, 6);

long total1 = 0;
long total2 = 0;
long total3 = 0;
long total4 = 0;

void setup()
{
  int t = 0xffff;
  cs1.set_CS_AutocaL_Millis(t);
  cs2.set_CS_AutocaL_Millis(t);
  cs3.set_CS_AutocaL_Millis(t);
  cs4.set_CS_AutocaL_Millis(t);

  int timeout = 500;
  cs1.set_CS_Timeout_Millis(timeout);
  cs2.set_CS_Timeout_Millis(timeout);
  cs3.set_CS_Timeout_Millis(timeout);
  cs4.set_CS_Timeout_Millis(timeout);

  Serial.begin(115200);

  // physical button to label the data
  pinMode(11, INPUT);
  digitalWrite(11, HIGH);
}

int count = 0;
void loop()
{
  int t = 100;
  
  switch (count) {
    case 1:
      total1 =  cs1.capacitiveSensorRaw(t);
      break;
    case 2:
      total2 =  cs2.capacitiveSensorRaw(t);
      break;
    case 3:
      total3 =  cs3.capacitiveSensorRaw(t);
      break;
    case 4:
      total4 =  cs4.capacitiveSensorRaw(t);
      break;
    default:
      count = 0;
  }
  count++;

  Serial.print(digitalRead(11)); // read button state
  Serial.print(" ");
  Serial.print(total1);
  Serial.print(" ");
  Serial.print(total2);
  Serial.print(" ");
  Serial.print(total3);
  Serial.print(" ");
  Serial.print(total4);
  Serial.print(" ");
  Serial.print("0\r");

  delay(1);                             // arbitrary delay to limit data to serial port
}
