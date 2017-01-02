#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

enum AD_Type
{
	AD_Type_Friendly,			/**< Friendly fire detected */
	AD_Type_Spectator,			/**< Victim damaged from team "spectator" */
	AD_Type_Unassigned,			/**< Victim damaged from team "unassigned" */
};

#define DEBUG

#define PLUGIN_VERSION "1.0"
#define UNHOOK_CLIENT(%1)	SDKUnhook(%1, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive)
#define HOOK_CLIENT(%1)		SDKHook(%1, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive)

public Plugin myinfo = 
{
	name = "Abnormal damage detector (core)",
	author = "fakuivan",
	description = "Exposes forwards for plugins to know when Friendly-Fire/Spec-Fire is taking place.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/member.php?u=264797"
};

Handle gh_OnAbnormalDamage;

public void OnPluginStart()
{
	CreateConVar("sm_ad_detector_version", PLUGIN_VERSION, "Version of AD Detector", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i))
		{
			HOOK_CLIENT(i);
		}
	}
	
	gh_OnAbnormalDamage = CreateGlobalForward("OnAbnormalDamage", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef);
	#if defined DEBUG //{
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_ad_debug_damage", Cmd_Damage, ADMFLAG_SLAY, "Damages a client as if an attacker did it");
	#endif //}
}

#if defined DEBUG //{
public Action Cmd_Damage(int i_client, int i_args)
{
	if (i_args != 4)
	{
		ReplyToCommand(i_client, "[SM-DEBUG] Usage: <victim> <target> <damage> <broadcast>");
		return Plugin_Handled;
	}
	int i_victim = FindTargetFromArg(i_client);
	int i_attacker = FindTargetFromArg(i_client, 2);
	if ((i_victim == -1) || (i_attacker == -1))
	{
		return Plugin_Handled;
	}
	int i_inflictor = i_attacker;
	float f_damage = GetCmdArgFloat(3);
	bool b_broadcast = (GetCmdArgInt(4) == 1);
	int i_dmg_type = DMG_GENERIC;
	Action i_result = Plugin_Continue;
	if (b_broadcast)
	{
		i_result = OnTakeDamageAlive(i_victim, i_attacker, i_inflictor, f_damage, i_dmg_type);
	}
	if (i_result == Plugin_Continue)
	{
		SDKHooks_TakeDamage(i_victim, i_inflictor, i_attacker, f_damage, i_dmg_type);
	}
	return Plugin_Handled;
}

stock int FindTargetFromArg(int i_client, int i_arg_pos = 1, bool b_nobots = false, bool b_immunity = true)
{
	char s_target[MAX_TARGET_LENGTH];
	GetCmdArg(i_arg_pos, s_target, sizeof(s_target));
	return FindTarget(i_client, s_target, b_nobots, b_immunity);
}

stock float GetCmdArgFloat(int i_arg_pos)
{
	char s_value[14];
	GetCmdArg(i_arg_pos, s_value, sizeof(s_value));
	return StringToFloat(s_value);
}

stock int GetCmdArgInt(int i_arg_pos)
{
	char s_value[12];
	GetCmdArg(i_arg_pos, s_value, sizeof(s_value));
	return StringToInt(s_value);
}
#endif //}

public APLRes AskPluginLoad2(Handle h_myself, bool b_late, char[] s_error, int i_err_max)
{
	RegPluginLibrary("ad_detector");
	return APLRes_Success;
}

public void OnClientPostAdminCheck(int i_client)
{
	HOOK_CLIENT(i_client);
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			UNHOOK_CLIENT(i);
		}
	}
}

public Action OnTakeDamageAlive(int i_victim, int &i_attacker, int &i_inflictor, float &f_damage, int &i_damagetype)
{
	if (i_attacker == i_victim)
	{
		//self damage
		return Plugin_Continue;
	}
	if (!((1 <= i_victim) && (i_victim <= MaxClients) && (1 <= i_attacker) && (i_attacker <= MaxClients)))
	{ 
		//env damage, or damaged by a sentry gun
		return Plugin_Continue;
	}
	TFTeam i_attacker_team = TF2_GetClientTeam(i_attacker);
	if (i_attacker_team == TFTeam_Spectator)
	{
		Action i_result;
		//spec dmg
		Call_StartForward(gh_OnAbnormalDamage);
		
		Call_PushCell(AD_Type_Spectator);
		Call_PushCell(i_victim);
		Call_PushCellRef(i_attacker);
		Call_PushCellRef(i_inflictor);
		Call_PushFloatRef(f_damage);
		Call_PushCellRef(i_damagetype);
		
		Call_Finish(i_result);
		
		return i_result;
	}
	TFTeam i_victim_team = TF2_GetClientTeam(i_victim);
	if (i_attacker_team == i_victim_team)
	{
		Action i_result;
		//friendly dmg
		Call_StartForward(gh_OnAbnormalDamage);
		
		Call_PushCell(AD_Type_Friendly);
		Call_PushCell(i_victim);
		Call_PushCellRef(i_attacker);
		Call_PushCellRef(i_inflictor);
		Call_PushFloatRef(f_damage);
		Call_PushCellRef(i_damagetype);
		
		Call_Finish(i_result);
		
		return i_result;
	}
	if (i_attacker_team == TFTeam_Unassigned)
	{
		Action i_result;
		//unassigned damage
		Call_StartForward(gh_OnAbnormalDamage);
		
		Call_PushCell(AD_Type_Unassigned);
		Call_PushCell(i_victim);
		Call_PushCellRef(i_attacker);
		Call_PushCellRef(i_inflictor);
		Call_PushFloatRef(f_damage);
		Call_PushCellRef(i_damagetype);
		
		Call_Finish(i_result);
		
		return i_result;
	}
	return Plugin_Continue;
}