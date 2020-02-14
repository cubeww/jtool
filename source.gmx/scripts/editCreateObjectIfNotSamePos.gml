var xx = argument0;
var yy = argument1;
var obj = argument2;
var object_at_position = false;
with (obj)
{
    if (x == xx && y == yy)
    {
        object_at_position = true;
    }
}
if (!object_at_position)
{
    editCreateObject(xx, yy, obj);
}

