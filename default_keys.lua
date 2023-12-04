-- defaultKeys
-- Variable
-- A set of opinionated defaults for the spoon
-- These can be overwritten by the user in init.lua before calling Reason:bindHotkeys()
return {
    -- create device
    createDevice = { { 'cmd' }, 'f' },
    -- global
    toggleMixer = { { 'ctrl' }, 'q' },
    toggleRack = { { 'ctrl' }, 'w' },
    toggleSequencer = { { 'ctrl' }, 'e' },
    togglePianoKeys = { { 'ctrl' }, 'a' },
    toggleToolWindow = { { 'ctrl' }, 'd' },
    toggleSpectrumEQ = { { 'ctrl' }, 's' },
    toggleRegrooveMixer = { { 'ctrl' }, 'r' },
    toggleBrowser = { { 'ctrl' }, 'f' },
    exportSong = { { 'ctrl' }, 't' },
    exportLoop = { { 'ctrl', 'cmd' }, 't' },
    bounceMixerChannels = { { 'ctrl' }, 'b' },
    color = { { 'ctrl', 'cmd' }, 'c' },
    createMixChannel = { { 'cmd', 'shift' }, 't' },
    copySettings = { { 'ctrl' }, 'c' },
    pasteSettings = { { 'ctrl' }, 'v' },
    -- mixer
    resetAllChannelSettings = { { 'alt' }, 'r' },
    -- rack
    autoRoute = { { 'alt' }, 'a' },
    browsePatches = { { 'alt' }, 'f' },
    disconnectDevice = { { 'alt' }, 'd' },
    resetDevice = { { 'alt' }, 'r' },
    combine = { { 'ctrl' }, 'g' },
    -- sequencer
    bounceClip = { { 'ctrl', 'cmd' }, 'b' },
    flatten = { { 'ctrl', 'cmd' }, 'f' },
    joinClips = { { 'ctrl' }, 'g' },
    doubleTempo = { { 'alt' }, 'z' },
    halfTempo = { { 'alt' }, 'x' },
    legato = { { 'alt' }, 'a' },
    quantize = { { 'alt' }, 'q' },
    reverse = { { 'alt' }, 'r' },
    setLoopAndPlay = { { 'alt' }, '`' },
}
