// Basic logic

#include "ThrowCommon.as"
#include "BasicCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as"


//attacks limited to the one time per-actor before reset.

void basic_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool basic_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 basic_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void basic_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void basic_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	BasicInfo basic;

	basic.state = BasicStates::normal;

	this.set("basicInfo", @basic);

	this.set_f32("gib health", -1.5f);
	basic_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");

	//centered on bomb select
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on inventory
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 3, Vec2f(16, 16));
	}
}


void onTick(CBlob@ this)
{
	u8 knocked = getKnocked(this);

	if (this.isInInventory())
		return;

	//basic logic stuff
	//get the vars to turn various other scripts on/off
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	BasicInfo@ basic;
	if (!this.get("basicInfo", @basic))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	Vec2f vec;

	const int direction = this.getAimDirection(vec);
	const f32 side = (this.isFacingLeft() ? 1.0f : -1.0f);

	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	if (getNet().isClient() && !this.isInInventory() && myplayer)  //Basic charge cursor
	{
		BasicCursorUpdate(this, basic);
	}

	if (knocked > 0)// || myplayer && getHUD().hasMenus())
	{

		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;

	}
	
	else if (pressed_a1)   //no attacking during a slide
	{

	}
	else if (this.isKeyJustReleased(key_action2) || this.isKeyJustReleased(key_action1))
	{
		basic.state = BasicStates::normal;
	}


	if (isServer())
	{
		basic_clear_actor_limits(this);
	}


}

void BasicCursorUpdate(CBlob@ this, BasicInfo@ basic)
{
	getHUD().SetCursorFrame(0);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
}

/////////////////////////////////////////////////


void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	BasicInfo@ basic;
	if (!this.get("basicInfo", @basic))
	{
		return;
	}
}



// bomb pick menu

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{

}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	if (!ap.socket) {
		BasicInfo@ basic;
		if (!this.get("basicInfo", @basic))
		{
			return;
		}

		basic.state = BasicStates::normal; //cancel any attacks
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	const string itemname = blob.getName();
}

void SetFirstAvailableBomb(CBlob@ this)
{
}

// Blame Fuzzle.
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible"))
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}
