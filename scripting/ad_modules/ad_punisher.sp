#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#define REQUIRE_PLUGIN
#include "ad_detector.inc"
#include "sdktools_functions.inc"

#define PLUGIN_VERSION	"1.0"

#define FF_CVAR			"mp_friendlyfire"

public Plugin myinfo = 
{
	name = "Abnormal Damage Punisher",
	author = "fakuivan",
	description = "Punishes a client when attacking a teammate.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/member.php?u=264797"
};

bool gb_ff;
ConVar gh_ff_convar;

public void OnPluginStart()
{
	CreateConVar("sm_ad_punisher_version", PLUGIN_VERSION, "Version of \"Abnormal Damage Punisher\"", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	if (null != (gh_ff_convar = FindConVar(FF_CVAR)))
	{
		gb_ff = GetConVarBool(gh_ff_convar);
		HookConVarChange(gh_ff_convar, OnFFCVarChanged);
	}
	else
	{
		LogError("%T", "ad_punisher_error_convar_ff_not_found", LANG_SERVER, FF_CVAR);
		gb_ff = true;
	}
	LoadTranslations("ad.punisher");
}

public void OnFFCVarChanged(ConVar h_convar, const char[] s_old_value, const char[] s_new_value)
{
	gb_ff = GetConVarBool(gh_ff_convar);
}

public Action OnAbnormalDamage(AD_Type i_type, int i_victim, int &i_attacker, int &i_inflictor, float &f_damage, int &i_damagetype)
{
	switch (i_type)
	{
		case AD_Type_Friendly:
		{
			if (gb_ff) { return Plugin_Continue; }
			
			PerformTranslatedKickReason(0, i_attacker, "ad_punisher_kick_ff_reason", "ad_punisher_kick__log");
			return Plugin_Handled;
		}
		case AD_Type_Spectator:
		{
			PerformTranslatedKickReason(0, i_attacker, "ad_punisher_kick_spec_reason", "ad_punisher_kick__log");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

stock int PerformTranslatedKickReason(int i_client, int i_target, char[] s_reason, char[] s_log_format)
{
	char s_t_reason[255];
	int i_bytes_written = Format(s_t_reason, sizeof(s_t_reason), "%T", s_reason, LANG_SERVER);
	
	LogAction(i_client, i_target, "%T", s_log_format, LANG_SERVER, i_client, i_target, s_t_reason);
	KickClient(i_target, "%t", s_reason);
	return i_bytes_written;
}
