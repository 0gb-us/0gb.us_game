build_0gb_us.register_generator("woodchecker", function(pos, size)
  if (pos.x+pos.y+pos.z)%2 == 0 then
    return "default:tree"
  else
    return "default:wood"
  end
end)

build_0gb_us.register_generator("cactuschecker", function(pos, size)
  if (pos.x+pos.y+pos.z)%2 == 0 then
    return "default:cobble"
  else
    return "default:cactus"
  end
end)

build_0gb_us.register_generator("furnacechests", function(pos, size)
  if (pos.x+pos.y+pos.z)%2 == 0 then
    return "default:chest"
  else
    return "default:furnace"
  end
end)
