// open a .yy file and write the map data

// I tried writing directly using json, but it failed
// gms2 will automatically restore room files, and this situation seems to be random
// so I used this stitching method

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

var filename = get_open_filename("GMS2 Room|*.yy", "");
if (filename == "")
    exit;
    
var f = file_text_open_read(filename);
var str = file_text_read_string_all(f);
file_text_close(f);
var old = jso_decode_map(str);
var mapname = jso_map_get(old, "name");
var roomid = jso_map_get(old, "id");
jso_cleanup_map(old);
  
var str = gms2Template(0);
str += mapname;
str += gms2Template(1);
str += roomid;
str += gms2Template(2);

var instlist = jso_new_list();
with (all)
{
    if (!objectInPalette(object_index))
        continue;
                
    if (!ds_map_exists(namemap, object_get_name(object_index)))
        continue;
        
    var maxpos = 896;
    var minpos = -128;
    if (x >= maxpos || y >= maxpos || x < minpos || y < minpos)
        continue;
        
    var inst = jso_new_map();
    jso_map_add_string(inst, "id", uuid_generate());
    var instid = randomInstanceID();
    jso_map_add_string(inst, "name", "inst_" + instid);
    jso_map_add_string(inst, "objId", ds_map_find_value(namemap, object_get_name(object_index)));
    jso_map_add_integer(inst, "x", x);
    jso_map_add_integer(inst, "y", y);
    
    jso_list_add_submap(instlist, inst);
}

// fill instance order IDs
for (var i = 0; i < ds_list_size(instlist); i++)
{
    var inst = jso_list_get(instlist, i);
    var instid = jso_map_get(inst, "id");
    str += '"' + instid + '"';
    if (i != ds_list_size(instlist) - 1)
    {
        str += ',
        ';
    }
}

str += gms2Template(3);

// fill instances
for (var i = 0; i < ds_list_size(instlist); i++)
{
    var inst = jso_list_get(instlist, i);
    var instid = jso_map_get(inst, "id");
    str += '{"name": "'+jso_map_get(inst, 'name')+'","id": "'+jso_map_get(inst, 'id')+'","colour": { "Value": 4294967295 },"creationCodeFile": "","creationCodeType": "","ignore": false,"imageIndex": 0,"imageSpeed": 1,"inheritCode": false,"inheritItemSettings": false,"IsDnD": false,"m_originalParentID": "00000000-0000-0000-0000-000000000000","m_serialiseFrozen": false,"modelName": "GMRInstance","name_with_no_file_rename": "'+jso_map_get(inst, 'name')+'","objId": "'+jso_map_get(inst, "objId")+'","properties": null,"rotation": 0,"scaleX": 1,"scaleY": 1,"mvc": "1.1","x": '+string(jso_map_get(inst, 'x'))+',"y": '+string(jso_map_get(inst, "y"))+'}';
    if (i != ds_list_size(instlist) - 1)
    {
        str += ",
";
    }
}

str += gms2Template(4);

// save to file
var f = FS_file_text_open_write(filename);
FS_file_text_write_string(f, str);
FS_file_text_close(f);

ds_map_destroy(namemap);
jso_cleanup_list(instlist);
