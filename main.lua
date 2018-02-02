local chunk = require "chunk"

local chunks = {}
local shader = nil

local cam_pos = {x=0,y=0,z=-3}
local cam_dir = {x=0,y=0,z=1}
local fov = 90
local voxel_size = 4/64

function love.load()
  shader = love.graphics.newShader("shaders/fragment.glsl")
  local c = chunk.new(0,0,"fill")
  c:generate_texture()
  table.insert(chunks, c)
end

function send(shader, name, value)
  if shader:hasUniform(name) then
    shader:send(name, value)
  end
end

function love.update(dt)
  send(shader, "cam_pos", {cam_pos.x, cam_pos.y, cam_pos.z})
  send(shader, "cam_dir", {cam_dir.x, cam_dir.y, cam_dir.z})
  send(shader, "fov", fov)
end

function love.draw()
  for i=1, #chunks do
    send(shader, "voxel_size", voxel_size)
    send(shader, "chunk", chunks[i].texture)
    send(shader, "chunk_size", 64)
    send(shader, "chunk_pos", {chunks[i].pos.x, chunks[i].pos.z})
    love.graphics.setShader(shader)
    love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
    love.graphics.setShader()
  end
end
