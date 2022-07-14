#include <a_samp>
#include <streamer>
#include <a_npc>

#define Hellrot 0xFF0000FF

#define Hellgrün 0x00FF00FF

#define Hellblau 0x0091FFFF

#define Gelb 0xFFFF00AA

#define Weis 0xFFFFFFFF

stock DebugMessage(playerid, string[])
{
if(!IsPlayerAdmin(playerid)) return 0;
return SendClientMessage(playerid, Weis, string);
}

stock GetSname(playerid)
{
new SSname[50];
GetPlayerName(playerid,SSname,sizeof(SSname));
return SSname;
}

SecondsToMinutes(seconds)
{
   new tmp[20];
   new minutes = floatround(seconds/60);
   seconds -= minutes*60;
   format(tmp, sizeof(tmp), "%d:%02d", minutes, seconds);
   return tmp;
}

stock RandomColor()
{
new randomcolor = random(255);
return randomcolor;
}

stock SendInfoText(playerid, text[])
{
new striing[150];
format(striing, sizeof striing, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~%s", text);
GameTextForPlayer(playerid, striing, 4000, 3);
return 1;
}

stock SendWarningText(playerid, text[])
{
new striing[150];
format(striing, sizeof striing, "~r~%s", text);
GameTextForPlayer(playerid, striing, 4000, 3);
return 1;
}

#define STEUERN 1
#define DIALOG_SFDERBY 30

new tempspiketimer;
new Autoscooter[10];
new DerbyAuto[20];
new SF_Autoscooterderbytimer;
new SFVehiclePlayerGameTime[MAX_PLAYERS];
new SFDerbyPickup;

public OnPlayerCommandText(playerid, cmdtext[])
{
	    if(!strcmp(cmdtext, "/derby"))
        {
		   SetPlayerPos(playerid, -2019.4202,-107.2771,35.1712);
		}
		return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    new string[50];
    if (pickupid == SFDerbyPickup)
    {
	    format(string,sizeof string,"~b~Press ~k~~SNEAK_ABOUT~ to get a ticket");
	    SendInfoText(playerid, string);
	}
    return 1;
}

/*GetPosInFrontOfPlayer(playerid, Float:distance, &Float:x, &Float:y, &Float:z)
{
    if(GetPlayerPos(playerid, x, y, z)) // this functions returns 0 if the player is not connected
    {
        new Float:z_angle;
        GetPlayerFacingAngle(playerid, z_angle);

        x += distance * floatsin(-z_angle, degrees); // angles in GTA go counter-clockwise, so we need to reverse the retrieved angle
        y += distance * floatcos(-z_angle, degrees);
        CreateObject(1655, x, y, z, 0, 0, z_angle, 300);//what

        return 1; // return 1 on success, the actual coordinates are returned by reference
    }
    return 0; // return 0 if the player isn't connected
}*/

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
   if(newkeys == KEY_WALK && IsPlayerInRangeOfPoint(playerid, 2, -2014.7194,-106.7274,35.1364))
   {
      new string[250];
      format(string, sizeof string, "Bumper Cars \t Price: %i$ \t %i/10 Vehicles used \nCar Derby \t Price: %i$ \t %i/15 Vehicles used", 25+STEUERN, UsedSFDerbyVehicles(0), 150+STEUERN, UsedSFDerbyVehicles(1));
      ShowPlayerDialog(playerid, DIALOG_SFDERBY, DIALOG_STYLE_TABLIST, "Ticket counter", string, "Okay", "Exit");
   }
   if(newkeys & KEY_ANALOG_UP)
   {
	  if(!IsPlayerInAnyVehicle(playerid)) return 1;
      new Float:X, Float: Y, Float: Z, Float: A;
      GetPlayerPos(playerid, X, Y, Z);
	  GetVehicleZAngle(GetPlayerVehicleID(playerid), A);
      X += 13 * floatsin(-A, degrees);
      Y += 13 * floatcos(-A, degrees);
      new objectid = CreateObject(1655, X, Y, Z-0.85, 0, 0, A, 300);
      SetTimerEx("RemoveDynamicJumpRamp", 1000, false, "%i", objectid);
   }
   if(newkeys & KEY_ANALOG_DOWN)
   {
	  if(!IsPlayerInAnyVehicle(playerid)) return 1;
	  if(GetSVarInt("Spiketime") > 0) return SendClientMessage(playerid, Hellrot, "8======D");
      new Float:X, Float: Y, Float: Z, Float: A;
      GetPlayerPos(playerid, X, Y, Z);
	  GetVehicleZAngle(GetPlayerVehicleID(playerid), A);
      X -= 7 * floatsin(-A, degrees);
      Y -= 8 * floatcos(-A, degrees);
      new objectid = CreateObject(2899, X, Y, Z-0.6, 0, 0, A+90, 300);
	  tempspiketimer = SetTimerEx("SpikeCheckRemove", 100, true, "%i", objectid);
      SetSVarInt("SpikeTimerid", tempspiketimer);
   }
   return 1;
}

encode_tires(tire1, tire2, tire3, tire4) {

    return tire1 | (tire2 << 1) | (tire3 << 2) | (tire4 << 3);
}

forward SpikeCheckRemove(spikeobjectid);
public SpikeCheckRemove(spikeobjectid)
{
      if(GetSVarInt("Spiketime") == 165)
      {
	     KillTimer(GetSVarInt("SpikeTimerid"));
	     SetSVarInt("SpikeTimerid", -1);
         DestroyObject(spikeobjectid);
         SetSVarInt("Spiketime", 0);
         return 1;
      }
      new Float: X, Float: Y, Float:Z;
      GetObjectPos(spikeobjectid, X, Y, Z);
      for(new i = 0; i < MAX_PLAYERS; i++)
      {
	     if(IsPlayerInRangeOfPoint(i, 3, X, Y, Z) && IsPlayerInAnyVehicle(i))
	     {
		    UpdateVehicleDamageStatus(GetPlayerVehicleID(i), 0, 0, 0, encode_tires(1, 1, 1, 1));
	     }
      }
      SetSVarInt("Spiketime", (GetSVarInt("Spiketime") +1));
      /*new string[20];
      format(string, sizeof string, "%i", GetSVarInt("Spiketime"));
      SendClientMessageToAll(Weis, string);*/
      return 1;
}

forward RemoveDynamicJumpRamp(rampobjectid);
public RemoveDynamicJumpRamp(rampobjectid)
{
   DestroyObject(rampobjectid);
}

stock UsedSFDerbyVehicles(action)
{
   new usedvehicles;
   for(new d = 0; d < MAX_VEHICLES; d++)
   if(action == 0)
   {
      if(d == 16) return usedvehicles;
      for (new i = 0; i <= MAX_PLAYERS; i++)
      {
         if (IsPlayerInVehicle(i, DerbyAuto[d])) usedvehicles = usedvehicles +1;
      }
   }
   for(new d = 0; d < MAX_VEHICLES; d++)
   if(action == 1)
   {
      if(d == 10) return usedvehicles;
      for (new i = 0; i <= MAX_PLAYERS; i++)
      {
         if (IsPlayerInVehicle(i, Autoscooter[d])) usedvehicles = usedvehicles +1;
      }
   }
   return -1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
   if(dialogid == DIALOG_SFDERBY)
   {
	  if(response)
	  {
	     if(listitem == 0)
	     {
		    SetPlayerPos(playerid, -2014.4052,-126.3299,35.2592);
		    GivePlayerMoney(playerid, -(25+STEUERN));
		    SFVehiclePlayerGameTime[playerid] = 300;// 5 mins
	     }
	     else if(listitem == 1)
	     {
		    SetPlayerPos(playerid, -2084.5435,-171.4245,35.3203);
		    GivePlayerMoney(playerid, -(150+STEUERN));
		    SFVehiclePlayerGameTime[playerid] = 600;// 10 mins
	     }
	     else
	     {
		    return 1;
		 }
	  }
   }
   return 1;
}

public OnFilterScriptInit()
{
    new tmpobjid;
    SFDerbyPickup = CreatePickup(1318, 1, -2014.7194,-106.7274,35.1364, 0);
    tmpobjid = CreateDynamicObject(18781, -2083.971435, -244.468017, 41.997257, 352.500000, 0.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2086.338378, -265.335632, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2080.154541, -265.335632, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2080.154541, -268.805267, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2086.328613, -268.805267, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2086.328613, -272.244873, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2080.155029, -272.244873, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2080.155029, -275.694671, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2086.329101, -275.694671, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2086.329101, -277.474365, 52.355514, 540.000000, 360.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2080.144042, -277.474365, 52.355514, 540.000000, 360.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2091.061523, -272.644348, 52.355514, 540.000000, 360.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2091.061523, -263.104644, 52.355514, 540.000000, 360.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2091.061523, -257.292816, 49.217636, -128.299728, 360.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2091.061523, -251.361495, 41.707244, -128.299728, 360.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2091.061523, -246.192535, 35.162178, -128.299728, 360.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2070.591552, -268.805267, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2070.591064, -272.244873, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2070.954345, -275.789978, 52.355514, 540.000000, 360.000000, 110.599967, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2093.654052, -249.997039, 37.342674, -85.999908, 450.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2061.044189, -268.805267, 50.695617, 360.000000, 90.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2061.997070, -272.422882, 52.355514, 540.000000, 360.000000, 110.599967, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2054.069335, -265.884765, 50.695617, 360.000000, 90.000000, 135.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2051.176757, -258.905456, 50.695617, 360.000000, 90.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2051.176757, -249.345367, 50.695617, 360.000000, 90.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(18768, -2051.176757, -229.175415, 50.965564, 720.000000, 180.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2031.466552, -230.115432, 50.695617, 360.000000, 90.000000, 270.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2024.508911, -227.216156, 50.695617, 360.000000, 90.000000, 315.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2025.699218, -232.985733, 50.695617, 360.000000, 90.000000, 585.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2021.618408, -220.226257, 50.695617, 360.000000, 90.000000, 360.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(13593, -2021.585205, -214.551727, 51.491207, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2021.898681, -197.176635, 50.425632, 360.000000, 90.000000, 360.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2022.807617, -239.945800, 50.695617, 360.000000, 90.000000, 900.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2022.807617, -249.395187, 49.646896, -12.600008, 90.000000, 900.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2022.807617, -258.455688, 48.595577, 360.000000, 90.000000, 900.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2025.731323, -265.429290, 48.595577, 360.000000, 90.000000, 1035.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2032.748413, -268.338470, 48.595577, 360.000000, 90.000000, 1170.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2039.722900, -265.453491, 48.595577, 360.000000, 90.000000, 1125.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2042.613159, -258.493621, 48.595577, 360.000000, 90.000000, 1080.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2042.613159, -249.006347, 47.586460, -12.100009, 90.000000, 1080.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2042.613159, -239.513610, 46.575614, 360.000000, 90.000000, 1080.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2039.736083, -232.562698, 46.575614, 360.000000, 90.000000, 1035.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2036.867553, -225.574066, 46.575614, 360.000000, 90.000000, 1080.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2036.867553, -216.043975, 46.575614, 360.000000, 90.000000, 1080.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2036.867553, -206.683959, 46.575614, 360.000000, 90.000000, 1080.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2036.867553, -197.273941, 46.575614, 360.000000, 90.000000, 1080.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2036.889892, -175.408447, 50.425632, 360.000000, 90.000000, 360.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(13593, -2036.816772, -191.193511, 47.586929, 8.399993, 0.000000, -1.299999, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2039.769531, -168.466003, 50.425632, 360.000000, 90.000000, 405.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2046.719970, -165.596176, 50.425632, 360.000000, 90.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2038.290405, -167.017135, 52.103961, 360.000000, -167.399810, 405.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(13593, -2036.807739, -178.218841, 50.405593, -19.500022, 0.000000, 178.499877, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2033.527587, -174.709838, 50.425632, 360.000000, 90.000000, 405.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2022.959350, -188.131500, 50.425632, 360.000000, 90.000000, 13.100000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2026.790527, -181.448760, 50.425632, 360.000000, 90.000000, 405.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2053.722900, -168.495498, 50.425632, 360.000000, 90.000000, 495.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2056.597167, -175.469543, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2056.597167, -184.639694, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2056.597167, -194.149627, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(13593, -2056.626464, -197.021835, 51.147235, 1.900002, 0.000000, 178.599899, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2056.698242, -212.069412, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2046.719970, -163.926223, 52.145610, 360.000000, 180.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2054.898193, -167.321884, 52.155612, 360.000000, 180.000000, 495.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2069.229492, -231.369369, 50.425632, 360.000000, 90.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2076.228515, -228.477325, 50.425632, 360.000000, 90.000000, 585.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2079.110351, -221.517227, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(13593, -2079.044433, -205.677200, 51.254203, 0.099998, 0.000000, -1.700000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(13593, -2079.031982, -201.846145, 51.247535, 0.099998, 0.000000, 178.300003, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 2, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19711, -2076.446533, -182.566574, 51.168422, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19711, -2065.857421, -182.566574, 51.168422, 0.000000, 0.000000, 900.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2063.227050, -191.569732, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2063.227050, -200.649688, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(19447, -2063.227050, -209.629684, 50.425632, 360.000000, 90.000000, 540.000000, -1, -1, -1, 150.00, 150.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
    tmpobjid = CreateDynamicObject(16003, -2012.699829, -106.643966, 35.598907, 1440.000000, 360.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2037.116699, -107.048263, 35.884021, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2037.116699, -116.608169, 35.884021, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2032.384887, -121.358161, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2022.754394, -121.358161, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2016.411376, -121.358161, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2037.116699, -116.608169, 37.573947, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2037.116699, -107.048263, 37.574020, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2032.384887, -121.358161, 37.573997, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2022.754394, -121.358161, 37.573921, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2016.573852, -121.358161, 37.573921, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(970, -2059.934814, -112.244651, 34.830039, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(970, -2064.777099, -112.244651, 34.830039, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(970, -2070.166748, -112.244651, 34.830039, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(970, -2074.597900, -112.244651, 34.830039, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(970, -2079.761474, -112.244651, 34.830039, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(970, -2084.302490, -112.244651, 34.830039, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2016.411376, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2025.853149, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2035.493408, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2045.063720, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2054.645263, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2064.168212, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2073.680664, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2083.240478, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2091.005371, -163.026382, 35.884021, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(18786, -2043.356811, -146.158081, 35.310291, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(18786, -2069.375244, -146.158081, 35.310291, 0.000000, 0.000000, 180.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2083.639160, -272.202026, 38.600337, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2083.639160, -272.202026, 46.140083, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2064.235107, -243.792129, 38.600337, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2068.107910, -268.292205, 46.150337, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2051.144042, -257.372314, 37.610370, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2051.144042, -257.372314, 46.250385, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2068.107910, -268.292205, 38.600337, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2064.235107, -243.792129, 46.390327, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2064.235107, -216.002136, 38.600337, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2064.235107, -216.002136, 46.410324, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2038.284912, -216.002136, 38.320331, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2038.284912, -216.002136, 46.400310, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2037.864501, -242.382186, 38.600337, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2037.864501, -242.382186, 45.890247, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2021.464477, -214.152175, 46.400287, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2021.464477, -214.152175, 38.490310, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2021.464477, -200.792312, 45.810382, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2021.464477, -200.792312, 37.210281, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2036.913452, -173.872238, 45.980312, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2036.913452, -173.872238, 37.240283, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2032.865966, -268.382232, 44.130340, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2022.735351, -241.182220, 46.110301, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2022.735351, -241.182220, 37.230278, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2032.865966, -268.382232, 35.960319, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2042.517578, -241.412307, 42.120338, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2042.517578, -241.412307, 38.450370, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2036.913452, -190.272155, 43.200347, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2036.913452, -190.272155, 34.600368, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2055.517822, -175.652206, 37.240283, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(3498, -2055.517822, -175.652206, 45.980239, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19633, -2025.505615, -259.118560, 33.702514, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(18784, -2021.789672, -172.976333, 36.646614, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(18784, -2021.789672, -190.446426, 36.646614, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.906250, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(18779, -2023.010986, -221.579696, 34.991458, 0.000000, -16.300008, 270.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2091.005371, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2081.425048, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2071.784423, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2062.222656, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2052.612792, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2043.012084, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2033.381958, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2023.781860, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19460, -2016.680175, -163.026382, 39.343971, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2084.933593, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2072.963134, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2060.991210, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2049.010498, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2037.030761, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2025.052124, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2022.571044, -162.917373, 40.694221, 0.000000, 0.000000, 0.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -163.157287, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -175.107177, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -187.087234, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -199.067108, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -211.047195, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -223.027297, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -235.007293, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -246.987274, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -258.967224, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -268.987274, 40.694221, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2011.218383, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2023.208374, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2035.188964, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2047.158935, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2059.119873, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2071.120849, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2083.103027, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2084.384277, -280.797363, 40.694221, 0.000000, 0.000000, 1260.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -280.747375, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -268.757446, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -256.777282, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -244.807312, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -232.827255, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -220.837310, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -208.857208, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -196.867187, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -184.897293, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(987, -2096.404785, -174.967376, 40.694221, 0.000000, 0.000000, 450.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2078.389160, -214.615722, 50.507259, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2079.730468, -206.145629, 50.507259, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2079.730468, -214.615722, 50.507259, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2079.730468, -210.365570, 50.507259, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2078.389160, -210.355667, 50.507259, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2078.389160, -206.115676, 50.507259, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2078.389160, -201.875732, 50.507259, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2078.389160, -197.645629, 50.507259, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2078.389160, -193.435577, 50.507259, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2079.730468, -201.885650, 50.507259, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2079.730468, -197.655609, 50.507259, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2079.730468, -193.435531, 50.507259, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2079.730468, -189.215515, 50.507259, 0.000000, 0.000000, 630.000000, -1, -1, -1, 150.00, 150.00); 
    tmpobjid = CreateDynamicObject(19467, -2078.389160, -189.185562, 50.507259, 0.000000, 0.000000, 90.000000, -1, -1, -1, 150.00, 150.00); 
    //autoscooter vortex
    Autoscooter[0] = CreateVehicle(539,-2015.3159,-123.7239,34.6046,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[1] = CreateVehicle(539,-2015.3159,-127.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[2] = CreateVehicle(539,-2015.3159,-131.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[3] = CreateVehicle(539,-2015.3159,-135.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[4] = CreateVehicle(539,-2015.3159,-139.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[5] = CreateVehicle(539,-2015.3159,-143.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[6] = CreateVehicle(539,-2015.3159,-147.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[7] = CreateVehicle(539,-2015.3159,-151.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[8] = CreateVehicle(539,-2015.3159,-155.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    Autoscooter[9] = CreateVehicle(539,-2015.3159,-159.7039,34.6303,90.9715, RandomColor(), RandomColor(), 0);
    
    //derby autos
    DerbyAuto[0] = CreateVehicle(504,-2094.2166,-166.6051,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[1] = CreateVehicle(504,-2090.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[2] = CreateVehicle(504,-2086.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[3] = CreateVehicle(504,-2082.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[4] = CreateVehicle(504,-2078.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[5] = CreateVehicle(504,-2074.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[6] = CreateVehicle(504,-2070.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[7] = CreateVehicle(504,-2066.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[8] = CreateVehicle(504,-2062.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[9] = CreateVehicle(504,-2058.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[10] = CreateVehicle(504,-2054.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[11] = CreateVehicle(504,-2050.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[12] = CreateVehicle(504,-2046.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[13] = CreateVehicle(504,-2042.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[14] = CreateVehicle(504,-2038.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
    DerbyAuto[15] = CreateVehicle(504,-2034.9026,-166.6605,35.1128,180.1126, RandomColor(), RandomColor(), 0);
	SF_Autoscooterderbytimer = SetTimer("SFAutoscooterDerby", 1000, true);
    return 1; 

}

public OnFilterScriptExit()
{
   KillTimer(SF_Autoscooterderbytimer);
   return 1;
}

stock IsPlayerInSFVehicleGameRange(playerid)
{
   for(new d = 0; d < MAX_VEHICLES; d++)
   if(IsPlayerInAnyVehicle(playerid))
   {
      new vehicleid = GetPlayerVehicleID(playerid);
      {
         if(d == 16) return 0;
         new Float:X, Float: Y, Float:Z;
         GetPlayerPos(playerid, X, Y, Z);
         if(vehicleid == DerbyAuto[d])
         {
            if (X > -2097 && X < -2013 && Y < -162 && Y > -280)
            {
               return 2;
            }
            else
            {
               return 1;
            }
         }
         if(vehicleid == Autoscooter[0] || vehicleid == Autoscooter[1] || vehicleid == Autoscooter[2] || vehicleid == Autoscooter[3] || vehicleid == Autoscooter[4] || vehicleid == Autoscooter[5]
          || vehicleid == Autoscooter[6] || vehicleid == Autoscooter[7] || vehicleid == Autoscooter[8] || vehicleid == Autoscooter[9])
         {
            if (X > -2097 && X < -2013 && Y < -100 && Y > -162)
            {
               return 2;
            }
            else
            {
               return 1;
            }
         }
      }
   }
   return 0;
}

forward SFAutoscooterDerby();
public SFAutoscooterDerby()
{
   for(new i = 0; i < MAX_PLAYERS; i++)
   if(IsPlayerInSFVehicleGameRange(i) == 1)
   {
		 SetVehicleToRespawn(GetPlayerVehicleID(i));
		 SetPlayerPos(i, -2019.4202,-107.2771,35.1712);
		 SFVehiclePlayerGameTime[i] = 0;
	     return SendWarningText(i, "Playtime is over! You should have stayed in the area!");
   }
   else if(IsPlayerInSFVehicleGameRange(i) == 2)
   {
      new string[50];
      if(SFVehiclePlayerGameTime[i] <= 0)
      {
		 SetVehicleToRespawn(GetPlayerVehicleID(i));
		 SetPlayerPos(i, -2019.4202,-107.2771,35.1712);
	     return SendWarningText(i, "Playtime is over!");
      }
      format(string, sizeof string, "Remaining Time: %s", SecondsToMinutes(SFVehiclePlayerGameTime[i]));
      SFVehiclePlayerGameTime[i] = SFVehiclePlayerGameTime[i] -1;
      SendInfoText(i, string);
   }
   return 1;
}

public OnPlayerConnect(playerid)
{ 
	RemoveBuildingForPlayer(playerid, 11015, -2028.130, -111.273, 36.132, 0.250);
	RemoveBuildingForPlayer(playerid, 11371, -2028.130, -111.273, 36.132, 0.250);
	RemoveBuildingForPlayer(playerid, 1497, -2029.020, -120.063, 34.257, 0.250);
	RemoveBuildingForPlayer(playerid, 1532, -2025.829, -102.469, 34.273, 0.250);
	RemoveBuildingForPlayer(playerid, 11099, -2056.989, -184.546, 34.414, 0.250);
}

stock IsPlayerDriver(playerid)
{
   return (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER);
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
   for(new d = 0; d < MAX_VEHICLES; d++)
   {
      if(d == 16) return 0;
      if(!IsPlayerDriver(playerid)) return 1;
      new Float:X, Float: Y, Float:Z;
      GetPlayerPos(playerid, X, Y, Z);
      if(vehicleid == DerbyAuto[d] ||vehicleid == Autoscooter[0] || vehicleid == Autoscooter[1] || vehicleid == Autoscooter[2] || vehicleid == Autoscooter[3] || vehicleid == Autoscooter[4]
	   || vehicleid == Autoscooter[5] || vehicleid == Autoscooter[6] || vehicleid == Autoscooter[7] || vehicleid == Autoscooter[8] || vehicleid == Autoscooter[9])
      {
		 SetVehicleToRespawn(vehicleid);
      }
   }
   return 1;
}
