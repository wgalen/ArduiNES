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
final int STATE_DEVICE = 1;
final int STATE_MAP    = 2;
final int STATE_RUN    = 3;
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
int buttonIndex = 0; //Used only during keymapping. There's probably a cleaner way.

int lastKey;
int state = STATE_INIT;

int portIndex = -1;
String[] portList;

int deviceIndex = -1;
String[] deviceList;

ControllDevice device;
ControllIO controll;

import procontroll.*;
import processing.serial.*;

Serial arduines;

void setup()
{
  portList = Serial.list();
  controll=ControllIO.getInstance(this);
  deviceList = new String[controll.getNumberOfDevices()];
  for (int i=0;i<deviceList.length;i++)
  {
    device=controll.getDevice(i);
    deviceList[i]=device.getName();
    device.close();
  }
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
        arduines = new Serial(this, portList[portIndex], 9600); 
        state = STATE_DEVICE;
        break;
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
      
    case STATE_DEVICE: //Present device list.
      if (deviceIndex > -1)
      {
        device=controll.getDevice(deviceIndex);
        device.open();
        state = STATE_MAP;
        lastKey=-1;
        delay(500); //ugly hack so we don't read out keys to early if the keyboard is active in procontroll
      }
      if (deviceList.length==0)
      {
        text("No input devices available. Something is massively broken.", 10,10);
      }
      
      for (int i = 0; i < deviceList.length; i++)
      {
        text(i + ".",10,(i+1)*10);
        text(deviceList[i],20,(i+1)*10);
      }
      break;
      
    case STATE_MAP: //Iterate through buttonMap and set keycodes accordingly.
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
      for (int i = 0;i < device.getNumberOfButtons();i++)
      {
        if(device.getButton(i).pressed())
        {
          if (i==lastKey)
            return;
          switch(buttonIndex)
          {
            case 0:
              device.plug("pressA",ControllIO.ON_PRESS,i);
              device.plug("releaseA",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
            case 1:
              device.plug("pressB",ControllIO.ON_PRESS,i);
              device.plug("releaseB",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
            case 2:
              device.plug("pressSelect",ControllIO.ON_PRESS,i);
              device.plug("releaseSelect",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
            case 3:
              device.plug("pressStart",ControllIO.ON_PRESS,i);
              device.plug("releaseStart",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
            case 4:
              device.plug("pressUp",ControllIO.ON_PRESS,i);
              device.plug("releaseUp",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
            case 5:
              device.plug("pressDown",ControllIO.ON_PRESS,i);
              device.plug("releaseDown",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
            case 6:
              device.plug("pressLeft",ControllIO.ON_PRESS,i);
              device.plug("releaseLeft",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
            case 7:
              device.plug("pressRight",ControllIO.ON_PRESS,i);
              device.plug("releaseRight",ControllIO.ON_RELEASE,i);
              lastKey=i;
              buttonIndex++;
              break;
          }
        }
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
    
    case STATE_DEVICE:
      if ((key=='0')&&(deviceList.length > 0))
        deviceIndex=0;
      if ((key=='1')&&(deviceList.length > 1))
        deviceIndex=1;
      if ((key=='2')&&(deviceList.length > 2))
        deviceIndex=2;
      if ((key=='3')&&(deviceList.length > 3))
        deviceIndex=3;
      if ((key=='4')&&(deviceList.length > 4))
        deviceIndex=4;
      if ((key=='5')&&(deviceList.length > 5))
        deviceIndex=5;
      if ((key=='6')&&(deviceList.length > 6))
        deviceIndex=6;
      if ((key=='7')&&(deviceList.length > 7))
        deviceIndex=7;
      if ((key=='8')&&(deviceList.length > 8))
        deviceIndex=8;
      if ((key=='9')&&(deviceList.length > 9))
        deviceIndex=9;
      break;
  }
}
void pressA()
{
  buttonStats |= BTN_A;
  arduines.write(buttonStats);
}
void pressB()
{
  buttonStats |= BTN_B;
  arduines.write(buttonStats);
}
void pressSelect()
{
  buttonStats |= BTN_SELECT;
  arduines.write(buttonStats);
}
void pressStart()
{
  buttonStats |= BTN_START;
  arduines.write(buttonStats);
}
void pressUp()
{
  buttonStats |= BTN_UP;
  arduines.write(buttonStats);
}
void pressDown()
{
  buttonStats |= BTN_DOWN;
  arduines.write(buttonStats);
}
void pressLeft()
{
  buttonStats |= BTN_LEFT;
  arduines.write(buttonStats);
}
void pressRight()
{
  buttonStats |= BTN_RIGHT;
  arduines.write(buttonStats);
}
void releaseA()
{
  buttonStats &= ~(BTN_A);
  arduines.write(buttonStats);
}
void releaseB()
{
  buttonStats &= ~(BTN_B);
  arduines.write(buttonStats);
}
void releaseSelect()
{
  buttonStats &= ~(BTN_SELECT);
  arduines.write(buttonStats);
}
void releaseStart()
{
  buttonStats &= ~(BTN_START);
  arduines.write(buttonStats);
}
void releaseUp()
{
  buttonStats &= ~(BTN_UP);
  arduines.write(buttonStats);
}
void releaseDown()
{
  buttonStats &= ~(BTN_DOWN);
  arduines.write(buttonStats);
}
void releaseLeft()
{
  buttonStats &= ~(BTN_LEFT);
  arduines.write(buttonStats);
}
void releaseRight()
{
  buttonStats &= ~(BTN_RIGHT);
  arduines.write(buttonStats);
}
