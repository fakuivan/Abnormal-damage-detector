/*
**
*/
#if defined _ad_detector_included
 #endinput
#endif
#define _ad_detector_included

enum AD_Type
{
	AD_Type_Friendly,			/**< Friendly fire detected */
	AD_Type_Spectator,			/**< Victim damaged from team "spectator" */
	AD_Type_Unassigned,			/**< Victim damaged from team "unassigned" */
};

/**
 * Called when abnormal damage is detected.
 *
 * @param i_type		Abnormal damage type (AD_Type).
 * @param i_victim		Victim.
 * @param i_attacker	Attacker.
 * @param i_inflictor	Inflictor (a rocket or a sentry gun).
 * @param f_damage		Damage about to be done.
 * @param i_damagetype	Type of damage DMG_* macro.
 * @return  			Plugin_Handled to cancel.
 */
forward Action OnAbnormalDamage(AD_Type i_type, int i_victim, int &i_attacker, int &i_inflictor, float &f_damage, int &i_damagetype);

/*
#if !defined REQUIRE_PLUGIN
public __pl_ad_detector_SetNTVOptional()
{
	MarkNativeAsOptional("");
}
#endif
*/

public SharedPlugin __pl_ad_detector =
{
	name = "ad_detector",
	file = "ad_detector.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};
