# Shared Functions

### [OpenAI.Print(...)](https://github.com/vicentefelipechile/openai-gmod/blob/only-http/lua/openai/shared.lua#L12)

This function works as the same function [MsgC](https://wiki.facepunch.com/gmod/Global.MsgC)

Example:
```lua
OpenAI.Print("[", "OpenAI", "]")
```

Output:
```
[OpenAI]
```

------

### [OpenAI.SetFileName(name, format, dir)](https://github.com/vicentefelipechile/openai-gmod/blob/only-http/lua/openai/shared.lua#L19)

This function converts a string and return a functional file path, all paths are inside of ```data/openai```

Example:
```lua
local myfile        = OpenAI.SetFileName("This is my file name")
local myfileformat  = OpenAI.SetFileName("This is my file format name", ".mp3")
local myfiledir     = OpenAI.SetFileName("This is my file name", "json", "mydir")

print( myfile )
print( myfileformat )
print( myfiledir )
```

Output:
```
data/openai/1680733521_this_is_my_file_name.txt
data/openai/1680733522_this_is_my_file_format_name.mp3
data/openai/mydir/1680733523_this_is_my_file_name.json
```

------

### [OpenAI.HandleCommands(str)](https://github.com/vicentefelipechile/openai-gmod/blob/only-http/lua/openai/shared.lua#LL45C11-L45C11)

This function check if the string starts with a "!" if it, then return the command and the value

Example:
```lua
print( OpenAI.HandleCommands("!chat Hello") )
print( OpenAI.HandleCommands("dalle Man walking in the moon") )

local cmd, value = OpenAI.HandleCommands("!hello there")
print( cmd == "hello" )
```

Output:
```
chat            Hello
nil


true
```
