#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#define REQUIRE_PLUGIN
#include "ad_detector.inc"

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "Abnormal Damage Announcer",
	author = "fakuivan",
	description = "A simple plugin that uses ad_detector to announce abnormal damage behavior",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/member.php?u=264797"
};

public Action OnAbnormalDamage(AD_Type i_type, int i_victim, int &i_attacker, int &i_inflictor, float &f_damage, int &i_damagetype)
{
	switch (i_type)
	{
		case AD_Type_Friendly:
		{
			PrintToChatAll("%N damaged %N (friendly-fire)", i_attacker, i_victim);
		}
		case AD_Type_Spectator:
		{
			PrintToChatAll("%N damaged %N (spec-fire)", i_attacker, i_victim);
		}
		case AD_Type_Unassigned:
		{
			PrintToChatAll("%N damaged %N (unassigned-fire)", i_attacker, i_victim);
		}
	}
}