// comboBoxButton(x,y,w,h,droph,text)

var xx = argument0;
var yy = argument1;
var w = argument2;
var h = argument3;
var droph = argument4;
var text = argument5;
var icon = argument6;
var enabled = global.state == globalstate_idle && !global.comboboxselected;
if (menuButton(xx, yy, w, h, text, enabled, icon))
{
    selected = !selected;
    global.comboboxselected = selected;
}

if (selected
    && (mouse_x < x || mouse_x > x + w - 1
    || mouse_y < y || mouse_y > y + h + droph - 1
    || global.state != globalstate_idle))
{
    selected = false;
    global.comboboxselected = false;
}

