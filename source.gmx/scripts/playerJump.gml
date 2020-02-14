if (place_meeting(x, y + global.grav, oBlock)
    || onPlatform
    || place_meeting(x, y + global.grav, oWater))
{
    vspeed = -jump;
    djump = true;
    audio_play_sound(sndJump, 0, 0);
    global.frameaction_jump = true;
}
else if (djump
    || place_meeting(x, y + global.grav, oWater2)
    || global.infinitejump)
{
    vspeed = -jump2;
    sprite_index = sPlayerJump;
    audio_play_sound(sndDJump, 0, 0);
    global.frameaction_djump = true;
    
    if (!place_meeting(x, y + global.grav, oWater3))
    {
        djump = false;
    }
    else
    {
        djump = true;
    }
}


