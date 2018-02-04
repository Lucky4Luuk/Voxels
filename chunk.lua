local lib = {}

local chunk_size = 64
local canvas_mode = "normal"

function lib.new(x,z,t)
  local chunk = {pos={x=x,z=z},voxels={}}

  if t == "fill" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=1, color={1,0.2,0.2}}
        end
      end
    end
  elseif t == "perlin" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=0}
        end
      end
    end
    for ix=1, chunk_size do
      for iz=1, chunk_size do
        local n = math.max(perlin:noise(ix,0.3,iz),0.3)
        for iy=1, math.floor(n*chunk_size) do
          chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.8,0.15}}
        end
      end
    end
  elseif t == "flat" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=0}
          if iy < 9 then
            chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.8,0.15}}
          elseif iy < 12 then
            chunk.voxels[ix][iy][iz] = {exists=1, color={0.3,0.4,0.15}}
          end
        end
      end
    end
  else --Assume it needs to be empty
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = {exists=0}
        end
      end
    end
  end

  chunk.generate_texture = function(self)
    self.texture = love.graphics.newCanvas(chunk_size, chunk_size*chunk_size, {format=canvas_mode})
    love.graphics.setCanvas(self.texture)
    love.graphics.clear()
    love.graphics.push()
    love.graphics.setColor(1,1,1,1)
    for ix=1, chunk_size do
      for iy=1, chunk_size do
        for iz=1, chunk_size do
          if self.voxels[ix][iy][iz].exists == 1 then
            love.graphics.points((ix-1), (iy-1) + (iz-1)*chunk_size)
          end
        end
      end
    end
    love.graphics.pop()
    love.graphics.setCanvas()
  end

  return chunk
end

return lib
