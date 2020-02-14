/// readResourceTreeChildren(file, count, newtree)
for (var i = 0; i < argument1; i++)
{
    hbuffer_write_int32(argument2, hbuffer_read_int32(argument0));  
    hbuffer_write_int32(argument2, hbuffer_read_int32(argument0));
    hbuffer_write_int32(argument2, hbuffer_read_int32(argument0));
    var len = hbuffer_read_int32(argument0);
    var name = hbuffer_read_data(argument0, len);
    writeGM8String(argument2, name);  
    var count = hbuffer_read_int32(argument0);
    hbuffer_write_int32(argument2, count);
    
    readResourceTreeChildren(argument0, count, argument2);
}
