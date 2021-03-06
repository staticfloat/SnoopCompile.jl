using SnoopCompile

### Log the compiles
# This only needs to be run once (to generate "/tmp/images_compiles.csv")

SnoopCompile.@snoop "/tmp/images_compiles.csv" begin
    include(Pkg.dir("Images", "test","runtests.jl"))
end

### Parse the compiles and generate precompilation scripts
# This can be run repeatedly

# IMPORTANT: we must have the module(s) defined for the parcelation
# step, otherwise we will get no precompiles for the Images module
using Images

data = SnoopCompile.read("/tmp/images_compiles.csv")

# The Images tests are run inside a module ImagesTest, so all
# the precompiles get credited to ImagesTest. Credit them to Images instead.
subst = Dict("ImagesTests"=>"Images")

# Blacklist helps fix problems:
# - MIME uses type-parameters with symbols like :image/png, which is
#   not parseable
blacklist = ["MIME"]

# Use these two lines if you want to create precompile functions for
# individual packages
pc, discards = SnoopCompile.parcel(data[end:-1:1,2], subst=subst, blacklist=blacklist)
SnoopCompile.write("/tmp/precompile", pc)

# Use these two lines if you want to add to your userimg.jl
pc = SnoopCompile.format_userimg(data[end:-1:1,2], subst=subst, blacklist=blacklist)
SnoopCompile.write("/tmp/userimg_Images.jl", pc)
