# 3d-soft-engine-lua

> A simple 3D engine written in Lua using
> using [lua-fenster](https://github.com/jonasgeiler/lua-fenster).

Some time ago I wanted to learn more about 3D engines, so I read this tutorial
series by David Rousset and then translated the TypeScript code from the
tutorial series into Lua:
[Tutorial series: learning how to write a 3D soft engine from scratch in C#, TypeScript or JavaScript](https://www.davrous.com/2013/06/13/tutorial-series-learning-how-to-write-a-3d-soft-engine-from-scratch-in-c-typescript-or-javascript/)

This 3D engine is obviously not production-ready or really anything to be taken
seriously, but I had a lot of fun writing it!  
It runs completely on the CPU and doesn't utilize any sort of hardware
acceleration or graphics library like OpenGL, therefore the term "soft engine".

This is actually a rework of a very old project of mine, which used
[LÖVE2D](https://love2d.org/) instead of
[lua-fenster](https://github.com/jonasgeiler/lua-fenster) (my own GUI library).  
If you want to see the old version, check out the
[`old-love2d-version`](https://github.com/jonasgeiler/3d-soft-engine-lua/tree/old-love2d-version)
tag.  
The code is a bit messy though.

## Screenshots

![Screenshot - Monkey](https://github.com/jonasgeiler/3d-soft-engine-lua/assets/10259118/20ba15aa-7e18-4a91-abb3-a485d3b83396)
![Screenshot - Teapot](https://github.com/jonasgeiler/3d-soft-engine-lua/assets/10259118/44c0f02f-049e-4c3c-978b-12b9f6df1c68)
![Screenshot - Torus](https://github.com/jonasgeiler/3d-soft-engine-lua/assets/10259118/dfff8735-3f32-4b61-a0f3-0897d64c9dad)

## Requirements

- LuaJIT 2.1 or Lua 5.1 (newer Lua versions might work but not tested)
- [LuaRocks](https://luarocks.org/)

## How to try

Download the repository and install the dependencies with `luarocks`:

```shell
$ luarocks install --only-deps 3d-soft-engine-dev-1.rockspec

# OR, manually install dependencies:
$ luarocks install fenster
$ luarocks install dkjson
```

Afterwards, run [`main.lua`](./main.lua):

```shell
$ luajit ./main.lua

# OR, slower:
$ lua5.1 ./main.lua
```

Feel free to play around with the [`main.lua`](./main.lua) file,
trying out different models and such.
