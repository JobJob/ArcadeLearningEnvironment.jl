
if isfile(joinpath(dirname(dirname(@__FILE__)), "deps", "deps.jl"))
    include("../deps/deps.jl")
else
    error("libale_c not properly installed. Please run Pkg.build(\"ArcadeLearningEnvironment\")")
end

const ALEInterface = Cvoid
const ALEPtr = Ptr{ALEInterface}
const ALEState = Cvoid
const ALEStatePtr = Ptr{ALEState}

ALE_new() = ccall((:ALE_new, libale_c), ALEPtr, ())
ALE_del(ale::ALEPtr) = ccall((:ALE_del, libale_c), Cvoid, (ALEPtr,), ale)

function getString(ale::ALEPtr, key::String)
    res = ccall((:getString, libale_c), Ptr{Cchar}, (ALEPtr, Ptr{Cchar}),
        ale, key)
    bytestring(res)
end
getInt(ale::ALEPtr, key::String) = ccall((:getInt, libale_c), Cint,
    (ALEPtr, Ptr{Cchar}), ale, key)
getBool(ale::ALEPtr, key::String) = ccall((:getBool, libale_c), Cint,
    (ALEPtr, Ptr{Cchar}), ale, key) > 0
getFloat(ale::ALEPtr, key::String) = ccall((:getFloat, libale_c), Float32,
    (ALEPtr, Ptr{Cchar}), ale, key)

setString(ale::ALEPtr, key::String, value::String) =
    ccall((:setString, libale_c), Cvoid, (ALEPtr, Ptr{Cchar}, Ptr{Cchar}),
        ale, key, value)
setInt(ale::ALEPtr, key::String, value::Cint) = ccall((:setInt, libale_c),
    Cvoid, (ALEPtr, Ptr{Cchar}, Cint), ale, key, value)
setBool(ale::ALEPtr, key::String, value::Bool) = ccall((:setBool, libale_c),
    Cvoid, (ALEPtr, Ptr{Cchar}, Cint), ale, key, value)
setFloat(ale::ALEPtr, key::String, value::Cfloat) =
    ccall((:setFloat, libale_c), Cvoid, (ALEPtr, Ptr{Cchar}, Cfloat),
        ale, key, value)

loadROM(ale::ALEPtr, rom_file::String) = ccall((:loadROM, libale_c), Cvoid,
    (ALEPtr, Ptr{Cchar}), ale, rom_file)

"""
`loadrom(ale::ALEPtr, romname::String)`

notes:
1) Gym rom names are lowercase like "seaquest.bin", "pong.bin"
2) Gym puts roms in /path/to/site-packages/atari_py/atari_roms
"""
function loadrom(ale::ALEPtr, romname::String)
    rompath = haskey(ENV, "ALE_ROM_DIR") ? ENV["ALE_ROM_DIR"] : ""
    romname[end-3:end] != ".bin" && (romname *= ".bin")
    romfullpath = joinpath(rompath, romname)
    @debug "loading rom at path: $romfullpath"
    loadROM(ale, romfullpath)
end

act(ale::ALEPtr, action::Cint) =
    ccall((:act, libale_c), Cint, (ALEPtr, Cint), ale, action)
game_over(ale::ALEPtr) =
    ccall((:game_over, libale_c), Cint, (ALEPtr,), ale) > 0
reset_game(ale::ALEPtr) = ccall((:reset_game, libale_c), Cvoid, (ALEPtr,), ale)

function getLegalActionSet(ale::ALEPtr)
    actions = Vector{Cint}(undef, 0)
    getLegalActionSet!(ale, actions)
    actions
end
function getLegalActionSet!(ale::ALEPtr, actions::Vector{Cint})
    resize!(actions, getLegalActionSize(ale))
    ccall((:getLegalActionSet, libale_c), Cvoid, (ALEPtr, Ptr{Cint}),
        ale, actions)
end
getLegalActionSize(ale::ALEPtr) =
    ccall((:getLegalActionSize, libale_c), Cint, (ALEPtr,), ale)

function getMinimalActionSet(ale::ALEPtr)
    actions = Vector{Cint}(undef, 0)
    getMinimalActionSet!(ale, actions)
    actions
end
function getMinimalActionSet!(ale::ALEPtr, actions::Vector{Cint})
    resize!(actions, getMinimalActionSize(ale))
    ccall((:getMinimalActionSet, libale_c), Cvoid, (ALEPtr, Ptr{Cint}),
        ale, actions)
end
getMinimalActionSize(ale::ALEPtr) =
    ccall((:getMinimalActionSize, libale_c), Cint, (ALEPtr,), ale)

getFrameNumber(ale::ALEPtr) =
    ccall((:getFrameNumber, libale_c), Cint, (ALEPtr,), ale)
lives(ale::ALEPtr) = ccall((:lives, libale_c), Cint, (ALEPtr,), ale)
getEpisodeFrameNumber(ale::ALEPtr) =
    ccall((:getEpisodeFrameNumber, libale_c), Cint, (ALEPtr,), ale)

function getScreen(ale::ALEPtr)
    w = getScreenWidth(ale)
    h = getScreenHeight(ale)
    screen_data = Vector{Cuchar}(undef, w*h) # row-major order
    getScreen!(ale, screen_data)
    screen_data
end
getScreen!(ale::ALEPtr, screen_data::Vector{Cuchar}) =
    ccall((:getScreen, libale_c), Cvoid, (ALEPtr, Ptr{Cuchar}), ale, screen_data)
getRAM(ale::ALEPtr, ram::Vector{Cuchar}) =
    ccall((:getRAM, libale_c), Cvoid, (ALEPtr, Ptr{Cuchar}), ale, ram)
getRAMSize(ale::ALEPtr) = ccall((:getRAMSize, libale_c), Cint, (ALEPtr,), ale)
getScreenWidth(ale::ALEPtr) =
    ccall((:getScreenWidth, libale_c), Cint, (ALEPtr,), ale)
getScreenHeight(ale::ALEPtr) =
    ccall((:getScreenHeight, libale_c), Cint, (ALEPtr,), ale)

getScreenRGB(ale::ALEPtr, output_buffer::Vector{Cuchar}) =
    ccall((:getScreenRGB, libale_c), Cvoid, (ALEPtr, Ptr{Cuchar}),
        ale, output_buffer)
getScreenGrayscale(ale::ALEPtr, output_buffer::Vector{Cuchar}) =
    ccall((:getScreenGrayscale, libale_c), Cvoid, (ALEPtr, Ptr{Cuchar}),
        ale, output_buffer)

saveState(ale::ALEPtr) = ccall((:saveState, libale_c), Cvoid, (ALEPtr,), ale)
loadState(ale::ALEPtr) = ccall((:loadState, libale_c), Cvoid, (ALEPtr,), ale)
cloneState(ale::ALEPtr) = ccall((:cloneState, libale_c), ALEStatePtr,
    (ALEPtr,), ale)
restoreState(ale::ALEPtr, state::ALEStatePtr) =
    ccall((:restoreState, libale_c), Cvoid, (ALEPtr, ALEStatePtr), ale, state)
cloneSystemState(ale::ALEPtr) = ccall((:cloneSystemState, libale_c),
    ALEStatePtr, (ALEPtr,), ale)
restoreSystemState(ale::ALEPtr, state::ALEStatePtr) =
    ccall((:restoreSystemState, libale_c), Cvoid, (ALEPtr, ALEStatePtr),
        ale, state)
deleteState(state::ALEStatePtr) = ccall((:deleteState, libale_c), Cvoid,
    (ALEStatePtr,), state)
saveScreenPNG(ale::ALEPtr, filename::String) = ccall((:saveScreenPNG, libale_c),
    Cvoid, (ALEPtr, Ptr{Cchar}), ale, filename)

function encodeState(state::ALEStatePtr)
    len = encodeStateLen(state)
    buf = Vector{Cchar}(undef, len)
    ccall((:encodeState, libale_c), Cvoid, (ALEStatePtr, Ptr{Cchar}, Cint),
        state, buf, len)
    buf
end
encodeStateLen(state::ALEStatePtr) = ccall((:encodeStateLen, libale_c),
    Cint, (ALEStatePtr,), state)
decodeState(buf::Vector{Cchar}) = ccall((:decodeState, libale_c),
    ALEStatePtr, (Ptr{Cchar}, Cint), buf, length(buf))
