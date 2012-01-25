// ArduiNES frontend
// by Wayne Galen
// Released under GNU General Public License, version 3

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


// State machine constants
final int STATE_INIT   = 0;
final int STATE_MAP    = 1;
final int STATE_RUN    = 2;
// NES button constants
final char BTN_A       = 0x01;
final char BTN_B       = 0x02;
final char BTN_SELECT  = 0x04;
final char BTN_START   = 0x08;
final char BTN_UP      = 0x10;
final char BTN_DOWN    = 0x20;
final char BTN_LEFT    = 0x40;
final char BTN_RIGHT   = 0x80;

int buttonStats = 0;
int buttonMap[] = new int[8];

int buttonIndex = 0; //Used only during keymapping. There's probably a cleaner way.

int lastKey;
int state = STATE_INIT;

int portIndex = -1;
String[] portList;

import processing.serial.*;

Serial arduines;

void setup()
{
  portList = Serial.list();
  size(640,480);
}

void draw()
{
  background(0);
  switch (state)
  {
    
    case STATE_INIT: //Present port list.
      if (portIndex > -1)
      {
        arduines = new Serial(this, portList[portIndex], 115200);
        state = STATE_MAP;
      }
      if (portList.length==0)
      {
        text("No serial ports detected. Please verify that you have your ArduiNES plugged in.", 10,10);
      }
      
      for(int i = 0; i < portList.length; i++)
      {
        text(i + ".",10,(i+1)*10);
        text(portList[i],20,(i+1)*10);
      }
      break;
      
    case STATE_MAP: //Iterate through buttonMap and set keycodes accordingly.
      for(buttonIndex = 0; buttonIndex < 8; buttonIndex++)
      {
        if (buttonMap[buttonIndex] == 0)
          break;
      }
      //Check to see if we have mapped all the buttons
      if (buttonIndex==7)
      {
        if (buttonMap[7]!=0)
        {
          buttonIndex=8;
        }
      }
      //if buttonIndex==8 here, then every key has been mapped.
      if (buttonIndex==8)
      {
        state=STATE_RUN;
        break;
      }
      //if we're here, there's keys to map.
      switch(buttonIndex)
      {
        case 0:
          text("Press a key for the A button.", 10,10);
          break;
        case 1:
          text("Press a key for the B button.", 10,10);
          break;
        case 2:
          text("Press a key for the Select button.", 10,10);
          break;
        case 3:
          text("Press a key for the Start button.", 10,10);
          break;
        case 4:
          text("Press a key for the Up button.", 10,10);
          break;
        case 5:
          text("Press a key for the Down button.", 10,10);
          break;
        case 6:
          text("Press a key for the Left button.", 10,10);
          break;
        case 7:
          text("Press a key for the Right button.", 10,10);
          break;
      }
      break;
    case STATE_RUN:
      text("Button stats:",10,10);
      if ((buttonStats & BTN_A) >0){
        text("A",10,20);
      }
      if ((buttonStats & BTN_B) >0){
        text("B",20,20);
      }
      if ((buttonStats & BTN_SELECT) >0){
        text("Select",30,20);
      }
      if ((buttonStats & BTN_START) >0){
        text("Start",70,20);
      }
      if ((buttonStats & BTN_UP) >0){
        text("Up",100,20);
      }
      if ((buttonStats & BTN_DOWN) >0){
        text("Down",120,20);
      }
      if ((buttonStats & BTN_LEFT) >0){
        text("Left",155,20);
      }
      if ((buttonStats & BTN_RIGHT) >0){
        text("Right",180,20);
      }
      break;
  }
}

void keyPressed()
{
  switch(state)
  {
    case STATE_INIT:
      if ((key=='0')&&(portList.length > 0))
        portIndex=0;
      if ((key=='1')&&(portList.length > 1))
        portIndex=1;
      if ((key=='2')&&(portList.length > 2))
        portIndex=2;
      if ((key=='3')&&(portList.length > 3))
        portIndex=3;
      if ((key=='4')&&(portList.length > 4))
        portIndex=4;
      if ((key=='5')&&(portList.length > 5))
        portIndex=5;
      if ((key=='6')&&(portList.length > 6))
        portIndex=6;
      if ((key=='7')&&(portList.length > 7))
        portIndex=7;
      if ((key=='8')&&(portList.length > 8))
        portIndex=8;
      if ((key=='9')&&(portList.length > 9))
        portIndex=9;
      break;
    case STATE_MAP:
      buttonMap[buttonIndex] = key;
      buttonStats=0;
      break;
    case STATE_RUN:
      if (key==lastKey)  //I shouldn't need this, but in processing, you get
        break;           //multiple calls to keyPressed when typematic kicks in.
        
      if (key==buttonMap[0]){
        buttonStats |= BTN_A;
      }
      if (key==buttonMap[1]){
        buttonStats |= BTN_B;
      }
      if (key==buttonMap[2]){
        buttonStats |= BTN_SELECT;
      }
      if (key==buttonMap[3]){
        buttonStats |= BTN_START;
      }
      if (key==buttonMap[4]){
        buttonStats |= BTN_UP;
      }
      if (key==buttonMap[5]){
        buttonStats |= BTN_DOWN;
      }
      if (key==buttonMap[6]){
        buttonStats |= BTN_LEFT;
      }
      if (key==buttonMap[7]){
        buttonStats |= BTN_RIGHT;
      }
      arduines.write(buttonStats);
      lastKey=key;
  }
}

void keyReleased()
{
  if (state!=STATE_RUN) //nothing to do with key releases unless everything is set up
  {
    return;
  }
  lastKey=0;
  if (key==buttonMap[0]){
    buttonStats &= ~(BTN_A);
  }
  if (key==buttonMap[1]){
    buttonStats &= ~(BTN_B);
  }
  if (key==buttonMap[2]){
    buttonStats &= ~(BTN_SELECT);
  }
  if (key==buttonMap[3]){
    buttonStats &= ~(BTN_START);
  }
  if (key==buttonMap[4]){
    buttonStats &= ~(BTN_UP);
  }
  if (key==buttonMap[5]){
    buttonStats &= ~(BTN_DOWN);
  }
  if (key==buttonMap[6]){
    buttonStats &= ~(BTN_LEFT);
  }
  if (key==buttonMap[7]){
    buttonStats &= ~(BTN_RIGHT);
  }  
  arduines.write(buttonStats);
}
