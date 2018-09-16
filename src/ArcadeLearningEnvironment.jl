module ArcadeLearningEnvironment

export
    # Types
    ALEInterface,
    ALEPtr,
    # Functions
    ALE_new,
    ALE_del,
    getInt,
    getBool,
    getFloat,
    setString,
    setInternal,
    setInt,
    setBool,
    setFloat,
    loadROM,
    loadrom,
    act,
    game_over,
    reset_game,
    getLegalActionSet,
    getLegalActionSet!,
    getLegalActionSize,
    getMinimalActionSet,
    getMinimalActionSet!,
    getMinimalActionSize,
    getFrameNumber,
    lives,
    getEpisodeFrameNumber,
    getScreen,
    getScreen!,
    getRAM,
    getRAMSize,
    getScreenWidth,
    getScreenHeight,
    getScreenRGB,
    getScreenGrayscale,
    saveState,
    loadState,
    cloneState,
    restoreState,
    cloneSystemState,
    restoreSystemState,
    deleteState,
    saveScreenPNG,
    encodeState,
    encodeStateLen,
    decodeState

include("aleinterface.jl")

end
