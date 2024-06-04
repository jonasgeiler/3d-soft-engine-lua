# 3d-rasterizer-lua (WIP)

> A simple 3D software engine using [lua-fenster](https://github.com/jonasgeiler/lua-fenster) and written in Lua.

Some time ago I wanted to learn more about 3D rasterizers, so I read this tutorial series by David Rousset and then translated the TypeScript code from the tutorial series into Lua:
[Tutorial series: learning how to write a 3D soft engine from scratch in C#, TypeScript or JavaScript](https://www.davrous.com/2013/06/13/tutorial-series-learning-how-to-write-a-3d-soft-engine-from-scratch-in-c-typescript-or-javascript/)

> [!WARNING]
> This project is currently in development!

## Screenshot

![Screenshot](https://github.com/jonasgeiler/3d-rasterizer-lua/assets/10259118/8b250fd3-3acc-42c3-a49c-a92d67c76ad4)

## To Do

- [X] Part 1 - Writing the core logic for camera, mesh & device object
- [X] Part 2 - Drawing lines and triangles to obtain a wireframe rendering
- [X] Part 3 - Loading meshes exported from Blender in a JSON format
- [X] Part 4 - Filling the triangle with rasterization and using a Z-Buffer
- [ ] Part 5 - Handling light with:
  - [X] Flat Shading
  - [ ] Gouraud Shading
- [ ] Part 6 - Applying textures, back-face culling and WebGL
