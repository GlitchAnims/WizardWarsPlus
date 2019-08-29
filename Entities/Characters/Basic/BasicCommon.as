//common basic header
namespace BasicStates
{
	enum States
	{
		normal = 0
	}
}

namespace BasicVars
{
	//const ::s32 resheath_time = 2;
}

shared class BasicInfo
{
    u8 state;
};


/*namespace BombType
{
	enum type
	{
		bomb = 0,
		water,
		count
	};
}

const string[] bombNames = { "Bomb",
                             "Water Bomb"
                           };

const string[] bombIcons = { "$Bomb$",
                             "$WaterBomb$"
                           };

const string[] bombTypeNames = { "mat_bombs",
                                 "mat_waterbombs"
                               };
*/

//checking state stuff

/*bool isShieldState(u8 state)
{
	return (state >= KnightStates::shielding && state <= KnightStates::shieldgliding);
}*/

//const f32 DEFAULT_ATTACK_DISTANCE = 16.0f;