# iliketurtles
ComputerCraft APIs for turtle lovers!

## Install

Requirements:
* http must be enabled
* raw.github.com must be whitelisted

```sh
# openp's github script
github run whitehat101/iliketurtles/master/install.lua
```
or

```sh
# any turtle
pastebin get sERDBEru install
install
rm install # optional
```

## Testing

Code was developed against `LuaJIT 2.0.3`.

`test.lua` loads APIs compatible with those available in game and runs the first argument as a program and passes the remaining arguments to that program.

```sh
# run a program
luajit test.lua programs/cacti-farmer north 1 2 3

# run a test
luajit test.lua apis/orientation_test.lua
```
