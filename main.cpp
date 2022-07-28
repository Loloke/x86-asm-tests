#include <Arduino.h>

#define BUTTON1 4
#define LED1 2

hw_timer_t * timer1 = NULL;
volatile byte state1 = LOW;

struct Button {
    const uint8_t PIN;
    uint32_t numberKeyPresses;
    bool pressed;
};

Button button1 = {BUTTON1, 0, false};

unsigned long button_time = 0;  
unsigned long last_button_time = 0; 

void IRAM_ATTR onTimer1(){
  state1 = !state1;
  digitalWrite(LED1, state1);
}

void IRAM_ATTR isr1() {
    button_time = millis();
if (button_time - last_button_time > 350)
{
        button1.numberKeyPresses++;
        button1.pressed = true;
        last_button_time = button_time;
        timer1 = timerBegin(0, 80, true);
        timerAttachInterrupt(timer1, &onTimer1, true);
        timerAlarmWrite(timer1, 1000000, false);
        timerAlarmEnable(timer1);
}
}

void setup() {
    Serial.begin(9600);
    pinMode(button1.PIN, INPUT_PULLUP);
    pinMode(LED1, OUTPUT);
    attachInterrupt(button1.PIN, isr1, FALLING);
}

void loop() {
    if (button1.pressed) {
        Serial.printf("Button has been pressed %u times\n", button1.numberKeyPresses);
        button1.pressed = false;
    }
}
