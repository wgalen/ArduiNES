// ArduiNES
// by Wayne Galen <jummama@gmail.com>
// 01/2011

// Based on code and schematics from the NES Serial interface
// by Andrew Reitano / Batsly Adams (www.batslyadams.com)

//   This program is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, either version 3 of the License, or
//   (at your option) any later version.

//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.

//   You should have received a copy of the GNU General Public License
//   along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <avr/io.h>
#include <avr/interrupt.h>

const int ledPin = 13;
const byte BTN_A      = 0x1;
const byte BTN_B      = 0x2;
const byte BTN_SELECT = 0x4;
const byte BTN_START  = 0x8;
const byte BTN_UP     = 0x10;
const byte BTN_DOWN   = 0x20;
const byte BTN_LEFT   = 0x40;
const byte BTN_RIGHT  = 0x80;

int byteToSend;
int nextByte;

void setup() 
{
  pinMode(0, INPUT);
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, HIGH);
  pinMode(2, INPUT);     // Probably unnecessary
  pinMode(3, INPUT);
  pinMode(4, OUTPUT);    // In case you were using the arduinoboy midi in circuit already
  digitalWrite(4, HIGH); // this will power the optoisolator
  
  
  //Serial.begin(31250);  // MIDI control - if you are using a MIDI compliant external device via the DIN5
  Serial.begin(115200);   // PC Control
  DDRB=0xFF;		      // Set all digital pins to outputs
  cli();     // Disable interrupts for a sec
  EICRA |= (1 << ISC01);
  EICRA |= (0 << ISC00);  // Falling edge of clock line
  EICRA |= (1 << ISC11);  // Did this the long way, ensures compatibility
  EICRA |= (1 << ISC10);  // Rising edge of latch line
  EIMSK |= (1 << INT0);   // Enable INT0 / INT1
  EIMSK |= (1 << INT1);
  sei();     // Reenable interrupts
}

void loop() 
{
  // Do nothing! Wait for the NES to latch
}

void serialEvent()
{
    nextByte=Serial.read() ^ 0xFF; 
}

// Clock function
ISR(INT0_vect)
{
  delayMicroseconds(1);   // Arduino was actually responding too fast to the interrupt!
  PORTB = byteToSend;  // Shift to LSB, OR out everything else
  byteToSend >>= 1;
}

// Latch function
ISR(INT1_vect)
{
  byteToSend=nextByte;
  PORTB = byteToSend;                 // Places LSB on the correct pin
  byteToSend >>= 1;
  //EIMSK |= (1 << INT0);     // Re-enable clock interrupts
}
