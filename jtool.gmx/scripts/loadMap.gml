// Deletes all palette objects and loads a map from file.

filename = get_open_filename_ext('jtool map|*.jmap','','','Open Map')
if filename == '' exit
var f = file_text_open_read(filename)
var content = file_text_read_string(f)
file_text_close(f)

var index = 1
var currentstring = ''
var section_number = 0
var delim = '|'
var versionstring = ''
var version1 = 0
var version2 = 0
var version3 = 0

global.infinitejump = false
global.dotkid = false

while index <= string_length(content) {
    var nextchar = string_char_at(content,index);
    if nextchar != delim {
         currentstring += nextchar
    }
    if nextchar == delim or index == string_length(content) {
        // jtool
        if section_number == 0 and currentstring != 'jtool'{
            show_message('Not a jtool file.')
            exit
        }
        // version
        else if section_number == 1 {
            versionstring = currentstring
            version1 = string_split(versionstring,0,'.')
            version2 = string_split(versionstring,1,'.')
            version3 = string_split(versionstring,2,'.')
        }
        // everything else
        else if section_number > 1 {
            var prefix = string_split(currentstring,0,':')
            if prefix == 'objects' {
                oEdit.undo_objectstring = ''
                oEdit.undo_nochanges = true
                with all if objectInPalette(object_index) instance_destroy()
                var objectstring = string_split(currentstring,1,':')
                var i = 1
                var yy = 0
                while i < string_length(objectstring) {
                    if string_copy(objectstring,i,1) == '-' {
                        yy = base32StringToInt(string_copy(objectstring,i+1,2))
                        i += 3
                    }
                    else {
                        var objectid = saveIDToObject(base32StringToInt(string_copy(objectstring,i,1)))
                        var xx = base32StringToInt(string_copy(objectstring,i+1,2))
                        var inst = instance_create(xx-128,yy-128,objectid);
                        inst.undo_recent = false;
                        i += 3
                    }
                }
                global.savePlayerX = oPlayerStart.x+17
                global.savePlayerY = oPlayerStart.y+23
                global.savePlayerXScale = 1
                loadPlayer()
            }
            else if prefix == 'dot' {
                global.dotkid = real(string_split(currentstring,1,':'))
            }
            else if prefix == 'inf' {
                global.infjump = real(string_split(currentstring,1,':'))
            }
        }
        section_number += 1
        currentstring = ''
    }
    index += 1
}
