// read gmk/gm81 and add a room, save new gmk/gm81 last

// special thanks:
// https://github.com/WastedMeerkat/gm81decompiler/blob/master/decompiler/gmk.cpp

// GMS buffers are very bad, so I use http dll

var namefile = get_open_filename("Name File|*.json", "");
if (namefile == "")
    exit;
    
var f = file_text_open_read(namefile);
var str = file_text_read_string_all(f);
file_text_close(f);

var namemap = json_decode(str);
if (namemap == -1)
{
    show_message("Wrong name file !");   
    exit;
}

var filename = get_open_filename("GM8 Project|*.gmk;*.gm81", "");
if (filename == "")
    exit;
    
var mapname = get_string("Enter the new room name", "room");
if (mapname == "")
    exit;

    
var file = hbuffer_create();
var indexmap = ds_map_create();

hbuffer_read_from_file(file, filename);
// check magic number
if (hbuffer_read_int32(file) != 1234321)
{
    hbuffer_destroy(file);
    show_message("Wrong GM8 File !");
    exit;
}

// check version
var ver = hbuffer_read_int32(file);
if (ver != 800 && ver != 810)
{
    hbuffer_destroy(file);
    show_message("Wrong GM8 Version !");
    exit;
}

// skip everything we don't need...

// settings
// {...} {settings length} {settings data (zlib)}
hbuffer_set_pos(file, 32);
var len = hbuffer_read_int32(file);
hbuffer_read_data(file, len);

// triggers
// {version header} {triggers count} {single trigger length} {single trigger data (zlib)} {lastchanged double}
hbuffer_read_int32(file);
var count = hbuffer_read_int32(file);
for (var i = 0; i < count; i++)
{
    var len = hbuffer_read_int32(file);
    hbuffer_read_data(file, len);
}
hbuffer_read_float64(file);

// constants
// {version header} {constants count} {single constant name} {single constant value} {lastchanged double}
hbuffer_read_int32(file);
var count = hbuffer_read_int32(file);
for (var i = 0; i < count; i++)
{
    var len = hbuffer_read_int32(file);
    hbuffer_read_data(file, len);
    var len = hbuffer_read_int32(file);
    hbuffer_read_data(file, len);
}
hbuffer_read_float64(file);

// sound, sprite, background, path, script, font, timeline
// {version header} {assets count} {single asset length} {single asset data (zlib)}
for (var i = 0; i < 7; i++)
{
    hbuffer_read_int32(file);
    var count = hbuffer_read_int32(file);
    for (var j = 0; j < count; j++)
    {
        var len = hbuffer_read_int32(file);
        hbuffer_read_data(file, len);
    }
}

// object
// we need to get their index
hbuffer_read_int32(file);
var count = hbuffer_read_int32(file);
for (var i = 0; i < count; i++)
{
    var len = hbuffer_read_int32(file);
    var obj = hbuffer_create();
    
    var data = hbuffer_read_hex(file, len);
    hbuffer_write_hex(obj, data);
    hbuffer_zlib_uncompress(obj);
    
    if (hbuffer_read_int32(obj) == 0)
    {
        hbuffer_destroy(obj);
        continue;
    }
    
    var len = hbuffer_read_int32(obj);
    var name = hbuffer_read_data(obj, len);
    
    // find name in the namemap
    for (var j = ds_map_find_first(namemap); !is_undefined(ds_map_find_value(namemap, j)); j = ds_map_find_next(namemap, j))
    {
        var value = ds_map_find_value(namemap, j);
        if (name == value)
        {
            ds_map_add(indexmap, j, i);
        }
    }
    hbuffer_destroy(obj);
    continue;
}

// ok, now we have reached the room chunk
// {version header} {room count} {single room length} {single room data (zlib)}

// check version header
if (hbuffer_read_int32(file) != 800)
{
    show_message("error while reading room chunk !")
    {
        hbuffer_destroy(file);
        exit;
    }
}

// the start position of the room chunk (->room count)
var roompos = hbuffer_get_pos(file);

// new rooms chunk
var newrooms = hbuffer_create(); 

// origin room count
var roomcount = hbuffer_read_int32(file);

// we will add a new room, so we add 1 to new room chunk
hbuffer_write_int32(newrooms, roomcount + 1);

// write origin data to new room chunk
for (var i = 0; i < roomcount; i++)
{
    var len = hbuffer_read_int32(file);
    hbuffer_write_int32(newrooms, len);
    
    var data = hbuffer_read_hex(file, len);
    hbuffer_write_hex(newrooms, data);
}

var newroomindex = roomcount;

// now we reached the end of room chunk, add a new room
// new SINGLE room chunk
var newroom = hbuffer_create();
hbuffer_write_int32(newroom, 1); // is room vaild

writeGM8String(newroom, mapname); // room name
hbuffer_write_float64(newroom, 0);          // lastchanged double
hbuffer_write_int32(newroom, 541);          // version header

writeGM8String(newroom, "");       // caption
hbuffer_write_int32(newroom, 800); // width
hbuffer_write_int32(newroom, 608); // height
hbuffer_write_int32(newroom, 32);  // snap X
hbuffer_write_int32(newroom, 32);  // snap Y

hbuffer_write_int32(newroom, 0);  // on "◇" grid
hbuffer_write_int32(newroom, 50); // room speed
hbuffer_write_int32(newroom, 0);  // persistent
hbuffer_write_int32(newroom, 0);  // bg color
hbuffer_write_int32(newroom, 0);  // bg color draw
writeGM8String(newroom, "");      // room creation code

// background
hbuffer_write_int32(newroom, 8); // always 8
for (var i = 0; i < 8; i++)
{
    hbuffer_write_int32(newroom, 1);  // visible
    hbuffer_write_int32(newroom, 0);  // foreground
    hbuffer_write_int32(newroom, -1); // bgindex
    hbuffer_write_int32(newroom, 0);  // x
    hbuffer_write_int32(newroom, 0);  // y
    hbuffer_write_int32(newroom, 1);  // tileh
    hbuffer_write_int32(newroom, 1);  // tilev
    hbuffer_write_int32(newroom, 0);  // vspeed
    hbuffer_write_int32(newroom, 0);  // hspeed
    hbuffer_write_int32(newroom, 0);  // stretch
}

// view
hbuffer_write_int32(newroom, 1); // enable view
hbuffer_write_int32(newroom, 8); // always 8
for (var i = 0; i < 8; i++)
{
    hbuffer_write_int32(newroom, i == 0); // visible
    hbuffer_write_int32(newroom, 0);      // view x
    hbuffer_write_int32(newroom, 0);      // view y
    hbuffer_write_int32(newroom, 800);    // view w
    hbuffer_write_int32(newroom, 608);    // view h
    hbuffer_write_int32(newroom, 0);      // port x
    hbuffer_write_int32(newroom, 0);      // port y
    hbuffer_write_int32(newroom, 800);    // port w
    hbuffer_write_int32(newroom, 608);    // port h
    hbuffer_write_int32(newroom, 400);    // hborder
    hbuffer_write_int32(newroom, 304);    // vborder
    hbuffer_write_int32(newroom, 0);      // hspeed
    hbuffer_write_int32(newroom, 0);      // vspeed
    hbuffer_write_int32(newroom, -1);     // follow object
}

// instance

// pass 1: get count
var count = 0;
with (all)
{
    if (!objectInPalette(object_index))
        continue;
                
    if (!ds_map_exists(indexmap, object_get_name(object_index)))
        continue;
        
    var maxpos = 896;
    var minpos = -128;
    if (x >= maxpos || y >= maxpos || x < minpos || y < minpos)
        continue;
    
    count += 1;
}
hbuffer_write_int32(newroom, count);

// pass 2: write info
var oid = 100001;
with (all)
{
    if (!objectInPalette(object_index))
        continue;
                
    if (!ds_map_exists(indexmap, object_get_name(object_index)))
        continue;
        
    var maxpos = 896;
    var minpos = -128;
    if (x >= maxpos || y >= maxpos || x < minpos || y < minpos)
        continue;
    
    hbuffer_write_int32(newroom, x); // instance X           
    hbuffer_write_int32(newroom, y); // instance Y          
    hbuffer_write_int32(newroom, ds_map_find_value(indexmap, object_get_name(object_index))); // object index        
    hbuffer_write_int32(newroom, oid); // instance id
    writeGM8String(newroom, ""); // instance creation code    
    hbuffer_write_int32(newroom, 0); // locked         
    
    oid += 1;
}

// tile
// make a tile system sometime? idk, skip now
hbuffer_write_int32(newroom, 0);

// maker settings
hbuffer_write_int32(newroom, 0);   // remember room editor info
hbuffer_write_int32(newroom, 800); // editor width
hbuffer_write_int32(newroom, 608); // editor height
hbuffer_write_int32(newroom, 1);   // show grid
hbuffer_write_int32(newroom, 1);   // show obj
hbuffer_write_int32(newroom, 1);   // show tile
hbuffer_write_int32(newroom, 1);   // show bg
hbuffer_write_int32(newroom, 1);   // show fg
hbuffer_write_int32(newroom, 1);   // show view
hbuffer_write_int32(newroom, 1);   // delete underlying obj
hbuffer_write_int32(newroom, 1);   // delete underlying tile
hbuffer_write_int32(newroom, 0);   // tab
hbuffer_write_int32(newroom, 0);   // xposscroll
hbuffer_write_int32(newroom, 0);   // yposscroll

// compress with zlib
hbuffer_zlib_compress(newroom);

// write to new room chunk
hbuffer_write_int32(newrooms, hbuffer_get_length(newroom));
hbuffer_write_buffer(newrooms, newroom);

hbuffer_destroy(newroom);

// new gmk file
var newfile = hbuffer_create();

// merge room chunk changes
hbuffer_write_buffer_part(newfile, file, 0, roompos);
hbuffer_write_buffer(newfile, newrooms);

hbuffer_destroy(newrooms);

// it's not over ... we need to add a new room to the resource tree
hbuffer_write_int32(newfile, hbuffer_read_int32(file));
hbuffer_write_int32(newfile, hbuffer_read_int32(file));
var roomendpos = hbuffer_get_pos(file);

// included file
// {version header} {files count} {single file length} {single file data (zlib)}
hbuffer_read_int32(file);
var count = hbuffer_read_int32(file);
for (var i = 0; i < count; i++)
{
    var len = hbuffer_read_int32(file);
    hbuffer_read_data(file, len);
}

// packages
// {version header} {packages count} {single package name string}
hbuffer_read_int32(file);
var count = hbuffer_read_int32(file);
for (var i = 0; i < count; i++)
{
    var len = hbuffer_read_int32(file);
    hbuffer_read_data(file, len);
}

// game information
// {version header} {length} {data}
hbuffer_read_int32(file);
var len = hbuffer_read_int32(file);
hbuffer_read_data(file, len);

// lib creation code & room order
hbuffer_read_int32(file);
var count = hbuffer_read_int32(file);
for (var i = 0; i < count; i++)
{
    var len = hbuffer_read_int32(file);
    hbuffer_read_data(file, len);
}

hbuffer_read_int32(file);
var count = hbuffer_read_int32(file);
for (var i = 0; i < count; i++)
{
    hbuffer_read_int32(file);
}

// resource tree
// {status} {group} {index} {name} {child count}
// status: 1 = resource group, 2 = normal group, 3 = resource
// group: 1 = objects group, 2 = sprites group, 3 = sounds group, 4 = rooms group, 6 = backgrounds group, 
//        7 = scripts group, 8 = paths group, 9 = fonts group, 10 = game information, 11 = global game settings, 
//        12 = timelines group, 13 = extension packages
// what is 5? idk, ask yoyogames

var newtree = hbuffer_create();
var treepos = hbuffer_get_pos(file);
for (var i = 0; i < 12; i++)
{
    hbuffer_write_int32(newtree, hbuffer_read_int32(file));  
    hbuffer_write_int32(newtree, hbuffer_read_int32(file));
    hbuffer_write_int32(newtree, hbuffer_read_int32(file));
    var len = hbuffer_read_int32(file);
    var name = hbuffer_read_data(file, len);
    writeGM8String(newtree, name);  
    var isrooms = 0;
    if (name == "Rooms")
        isrooms = 1;
    
    var count = hbuffer_read_int32(file);
    hbuffer_write_int32(newtree, count + isrooms);
    readResourceTreeChildren(file, count, newtree);
    if (isrooms) 
    {
        hbuffer_write_int32(newtree, 3);
        hbuffer_write_int32(newtree, 4);
        hbuffer_write_int32(newtree, newroomindex);
        writeGM8String(newtree, mapname);
        hbuffer_write_int32(newtree, 0);
    }
}

// final write
hbuffer_write_buffer_part(newfile, file, roomendpos, treepos - roomendpos);
hbuffer_write_buffer(newfile, newtree);

hbuffer_destroy(newtree);

// write to file
hbuffer_write_to_file(newfile, filename);

// write a backup
hbuffer_write_to_file(file, filename + ".bak");

hbuffer_destroy(newfile);
hbuffer_destroy(file);
ds_map_destroy(namemap);
ds_map_destroy(indexmap);

