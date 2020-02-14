/// file_text_read_string_all(file)
var file = argument0;
if (file < 0) return undefined;
var str = "";
while (!file_text_eof(file)) {
    str += file_text_read_string(file);
    file_text_readln(file);
}
file_text_close(file);
return str;
