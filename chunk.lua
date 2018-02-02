local lib = {}

local chunk_size = 64
local canvas_mode = "r8"

function lib.new(x,z,t)
  local chunk = {pos={x=x,z=z},voxels={}}

  if t == "fill" then
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = 1
        end
      end
    end
  else --Assume it needs to be empty
    for ix=1, chunk_size do
      chunk.voxels[ix] = {}
      for iy=1, chunk_size do
        chunk.voxels[ix][iy] = {}
        for iz=1, chunk_size do
          chunk.voxels[ix][iy][iz] = 0
        end
      end
    end
  end

  chunk.generate_texture = function(self)
    self.texture = love.graphics.newCanvas(chunk_size, chunk_size*chunk_size, {format=canvas_mode})
    love.graphics.setCanvas(self.texture)
    love.graphics.push()
    love.graphics.setColor(1,1,1,1)
    for ix=1, chunk_size do
      for iy=1, chunk_size do
        for iz=1, chunk_size do
          if self.voxels[ix][iy][iz] == 1 then
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
