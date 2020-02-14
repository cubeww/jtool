// save map as a IWM map file

// get IWM map directory...
var path = temp_directory;
path = string_copy(path, 0, string_length(path) - 5);
path += "IWM\maps\";

if (!FS_directory_exists(path))
    FS_directory_create(path);
    
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

var mapname = get_string("Enter the new map name", "map");
if (mapname == "")
    exit;

var instcount = 0;
with (all)
{
    if (!objectInPalette(object_index))
        continue;
        
    if (object_index == oWalljumpL || object_index == oWalljumpR)
        continue;
        
    if (!ds_map_exists(namemap, object_get_name(object_index)))
        continue;    
    
    var maxpos = 896;
    var minpos = -128;
    if (x >= maxpos || y >= maxpos || x < minpos || y < minpos)
        continue;
        
    instcount++;
}

DerpXmlWrite_New();

// IWM does not support XML with line breaks now :O
DerpXmlWrite_Config("", "");

DerpXmlWrite_OpenTag("sfm_map");
    DerpXmlWrite_OpenTag("head");
        DerpXmlWrite_OpenTag("name");
            DerpXmlWrite_Text(mapname);
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("version");
            DerpXmlWrite_Text("59");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("tileset");
            DerpXmlWrite_Text("1");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("tileset2");
            DerpXmlWrite_Text("1");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("bg");
            DerpXmlWrite_Text("0");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("spikes");
            DerpXmlWrite_Text("1");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("width");
            DerpXmlWrite_Text("800");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("height");
            DerpXmlWrite_Text("608");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("colors");
            DerpXmlWrite_Text("5A0200000600000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("scroll_mode");
            DerpXmlWrite_Text("0");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("music");
            DerpXmlWrite_Text("1");
        DerpXmlWrite_CloseTag();
        
        DerpXmlWrite_OpenTag("num_objects");
            DerpXmlWrite_Text(string(instcount));
        DerpXmlWrite_CloseTag();
        
    DerpXmlWrite_CloseTag();
    
    DerpXmlWrite_OpenTag("objects");
        with (all)
        {
            if (!objectInPalette(object_index))
                continue;
                
            if (object_index == oWalljumpL || object_index == oWalljumpR)
                continue;
                
            if (!ds_map_exists(namemap, object_get_name(object_index)))
                continue;    
            
            var maxpos = 896;
            var minpos = -128;
            if (x >= maxpos || y >= maxpos || x < minpos || y < minpos)
                continue;
                
            DerpXmlWrite_OpenTag("object");
                DerpXmlWrite_Attribute("type", ds_map_find_value(namemap, object_get_name(object_index)));
                DerpXmlWrite_Attribute("x", string(x + 16));
                DerpXmlWrite_Attribute("y", string(y + 16));
                if (object_index == oSpikeUp)
                    DerpXmlWrite_Attribute("sprite_angle", "90");                
                if (object_index == oSpikeLeft)
                    DerpXmlWrite_Attribute("sprite_angle", "180");
                if (object_index == oSpikeDown)
                    DerpXmlWrite_Attribute("sprite_angle", "270");
                if (object_index == oSpikeRight)
                    DerpXmlWrite_Attribute("sprite_angle", "0");
                if (object_index == oMiniSpikeUp)
                    DerpXmlWrite_Attribute("sprite_angle", "90");
                if (object_index == oMiniSpikeLeft)
                    DerpXmlWrite_Attribute("sprite_angle", "180");
                if (object_index == oMiniSpikeDown)
                    DerpXmlWrite_Attribute("sprite_angle", "270");
                if (object_index == oMiniSpikeRight)
                    DerpXmlWrite_Attribute("sprite_angle", "0");
                // params
                if (object_index != oPlayerStart)
                {
                    DerpXmlWrite_LeafElement("param", "");
                        DerpXmlWrite_Attribute("key", "scale");
                        DerpXmlWrite_Attribute("val", "1");
                }
                if (object_index == oEditBlock || object_index == oEditMiniBlock)
                {
                    DerpXmlWrite_LeafElement("param", "");
                        DerpXmlWrite_Attribute("key", "tileset");
                        DerpXmlWrite_Attribute("val", "0");
                    // vine check
                    var v = instance_place(x, y, oWalljumpL);
                    if (v != noone)
                    {
                        DerpXmlWrite_OpenTag("obj");
                            DerpXmlWrite_Attribute("type", ds_map_find_value(namemap, object_get_name(v.object_index)));
                            DerpXmlWrite_Attribute("x", string(v.x + 16));
                            DerpXmlWrite_Attribute("y", string(v.y + 16));
                            DerpXmlWrite_Attribute("slot", "0");
                        DerpXmlWrite_CloseTag();
                    }
                    var v = instance_place(x, y, oWalljumpR);
                    if (v != noone)
                    {
                        DerpXmlWrite_OpenTag("obj");
                            DerpXmlWrite_Attribute("type", ds_map_find_value(namemap, object_get_name(v.object_index)));
                            DerpXmlWrite_Attribute("x", string(v.x + 16));
                            DerpXmlWrite_Attribute("y", string(v.y + 16));
                            DerpXmlWrite_Attribute("slot", "1");
                        DerpXmlWrite_CloseTag();
                    }
                }
                if (object_index == oPlayerStart || object_index == oSave)
                {
                   DerpXmlWrite_LeafElement("param", "");
                        DerpXmlWrite_Attribute("key", "grav_type");
                        DerpXmlWrite_Attribute("val", "0"); 
                }
                if (object_index == oApple)
                {
                   DerpXmlWrite_LeafElement("param", "");
                        DerpXmlWrite_Attribute("key", "bounce");
                        DerpXmlWrite_Attribute("val", "0"); 
                   DerpXmlWrite_LeafElement("param", "");
                        DerpXmlWrite_Attribute("key", "cherry_color");
                        DerpXmlWrite_Attribute("val", "0"); 
                }
                if (object_index == oPlatform)
                {
                   DerpXmlWrite_LeafElement("param", "");
                        DerpXmlWrite_Attribute("key", "sideways");
                        DerpXmlWrite_Attribute("val", "0"); 
                }
            DerpXmlWrite_CloseTag();
        }
    DerpXmlWrite_CloseTag();
DerpXmlWrite_CloseTag();
    
var xmlString = DerpXmlWrite_GetString();
DerpXmlWrite_UnloadString();

var f = FS_file_text_open_write(path + mapname + ".map");
FS_file_text_write_string(f, xmlString);
FS_file_text_close(f);

