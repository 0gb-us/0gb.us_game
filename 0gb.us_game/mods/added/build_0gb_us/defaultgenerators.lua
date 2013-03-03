build_0gb_us.register_generator("woodchecker", function(seed)
  if seed%2==0
    return "default:tree"
  else
    return "default:wood"
  end
end)

build_0gb_us.register_generator("cactuschecker", function(seed)
  if seed%2==0
    return "default:cobble"
  else
    return "default:cactus"
  end
end)

build_0gb_us.register_generator("furnacechests", function(seed)
  if seed%2==0
    return "default:chest"
  else
    return "default:furnace"
  end
end)
