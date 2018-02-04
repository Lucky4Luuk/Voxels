local chunk = require "chunk"
require "perlin"

local chunks = {}
local shader = nil

local cam_pos = {x=0,y=0,z=-3}
local cam_rot = {x=0,y=0,z=0}
local fov = 90
local voxel_size = 1/64

local totalTime = 0
local timestep = 1/60

local mode = "gpu"

function love.load()
  perlin:load()
  shader = love.graphics.newShader("shaders/fragment.glsl")
  for x=-0, 1 do
    for z=-0, 1 do
      local c = chunk.new(x*64,z*64,"flat")
      c:generate_texture()
      table.insert(chunks, c)
    end
  end
end

function send(shader, name, value)
  if shader:hasUniform(name) then
    shader:send(name, value)
  end
end

function FixedUpdate()
  local ry = cam_rot.y / 180 * math.pi
  if love.keyboard.isDown("d") then
    cam_pos.x = cam_pos.x + math.sin(ry-math.pi/2)*timestep*5
    cam_pos.z = cam_pos.z - math.cos(ry-math.pi/2)*timestep*5
  elseif love.keyboard.isDown("a") then
    cam_pos.x = cam_pos.x - math.sin(ry-math.pi/2)*timestep*5
    cam_pos.z = cam_pos.z + math.cos(ry-math.pi/2)*timestep*5
  end

  if love.keyboard.isDown("e") then
    cam_pos.y = cam_pos.y + timestep*5
  elseif love.keyboard.isDown("q") then
    cam_pos.y = cam_pos.y - timestep*5
  end

  if love.keyboard.isDown("w") then
    cam_pos.x = cam_pos.x + math.sin(ry-math.pi)*timestep*5
    cam_pos.z = cam_pos.z - math.cos(ry-math.pi)*timestep*5
  elseif love.keyboard.isDown("s") then
    cam_pos.x = cam_pos.x - math.sin(ry-math.pi)*timestep*5
    cam_pos.z = cam_pos.z + math.cos(ry-math.pi)*timestep*5
  end

  if love.keyboard.isDown("right") then
    cam_rot.y = (cam_rot.y + timestep*45) % 360
  elseif love.keyboard.isDown("left") then
    cam_rot.y = cam_rot.y - timestep*45
    if cam_rot.y < 0 then cam_rot.y = 360 end
  end
end

function love.update(dt)
  local ry = cam_rot.y / 180 * math.pi
  for i=1, #chunks do
    local nx = chunks[i].pos.x - cam_pos.x
    local nz = chunks[i].pos.z - cam_pos.z
    local rx = nx * math.cos(ry) - nz * math.sin(ry)
    local rz = nz * math.cos(ry) + nx * math.sin(ry)
    chunks[i].dtc = rx*rx + rz*rz
  end
  table.sort(chunks, sort_chunks)
  totalTime = totalTime + dt
  while totalTime > timestep do
    FixedUpdate()
    totalTime = totalTime - timestep
  end

  if mode == "gpu" then
    local cam_dir = {x=-math.sin(ry),y=0,z=math.cos(ry)}
    send(shader, "cam_pos", {cam_pos.x, cam_pos.y, cam_pos.z})
    send(shader, "cam_dir", {cam_dir.x, cam_dir.y, cam_dir.z})
    send(shader, "fov", fov)
  end
end

function sort_chunks(a,b)
  return a.dtc < b.dtc
end

function love.draw()
  local vox_count = 0
  for i=1, #chunks do
    if mode == "gpu" then
      send(shader, "voxel_size", voxel_size)
      send(shader, "chunk", chunks[i].texture)
      send(shader, "chunk_size", 64)
      send(shader, "chunk_pos", {chunks[i].pos.x, chunks[i].pos.z})
      love.graphics.setShader(shader)
      love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
      love.graphics.setShader()
    else
      -- Software rendering
    end
  end

  love.graphics.setColor(1,1,1,1)
  local dy = 0
  if mode == "cpu" then
    love.graphics.print("Voxels being drawn: "..tostring(vox_count),0,dy)
    dy = dy + 12
  end
  love.graphics.print("MS: "..tostring(love.timer.getDelta())*1000,0,dy)
  dy = dy + 12
  love.graphics.print("FPS: "..tostring(love.timer.getFPS()),0,dy)
  dy = dy + 12
end
