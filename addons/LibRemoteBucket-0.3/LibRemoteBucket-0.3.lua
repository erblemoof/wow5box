local MAJOR, MINOR = "LibRemoteBucket-0.3", 1
local LibRemoteBucket = LibStub:NewLibrary(MAJOR, MINOR)
if not LibRemoteBucket then return end

LibRemoteBucket.embeds = LibRpc.embeds or {}
return