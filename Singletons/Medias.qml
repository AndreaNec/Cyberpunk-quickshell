// Medias.qml
pragma Singleton
import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    // tutti i player (ObjectModel, per le ListView)
    readonly property var players: Mpris.players

    // player scelto a mano (es. cliccando nella lista); null = automatico
    property var selected: null

    // player attivo: quello scelto, altrimenti il primo che sta suonando, altrimenti il primo
    readonly property var active: {
        const list = Mpris.players.values;
        if (selected && list.includes(selected))
            return selected;
        return list.find(p => p.isPlaying) ?? list[0] ?? null;
    }

    // ---------- lettura ----------
    function metadata(p) {
        if (!p)
            return null;
        return {
            title: p.trackTitle || p.identity || "Unknown Title",
            artist: p.trackArtist || "Unknown Artist",
            album: p.trackAlbum || "",
            art: p.trackArtUrl || "",
            player: p.identity || "",
            playing: p.isPlaying
        };
    }

    // null se il player non supporta la cosa: usa "?? valore" fuori
    function volume(p) {
        return p && p.volumeSupported ? p.volume : null;
    }
    function position(p) {
        return p && p.positionSupported ? p.position : null;
    }
    function length(p) {
        return p && p.lengthSupported ? p.length : null;
    }

    // ---------- capability ----------
    function caps(p) {
        return {
            volume: !!p && p.volumeSupported && p.canControl,
            seek: !!p && p.canSeek,
            next: !!p && p.canGoNext,
            previous: !!p && p.canGoPrevious,
            toggle: !!p && p.canTogglePlaying,
            shuffle: !!p && p.shuffleSupported && p.canControl,
            loop: !!p && p.loopSupported && p.canControl
        };
    }

    // ---------- azioni (no-op se non supportate) ----------
    function togglePlaying(p) {
        if (p?.canTogglePlaying)
            p.togglePlaying();
    }
    function next(p) {
        if (p?.canGoNext)
            p.next();
    }
    function previous(p) {
        if (p?.canGoPrevious)
            p.previous();
    }

    function setVolume(p, v) {
        if (p?.volumeSupported && p.canControl)
            p.volume = Math.max(0, Math.min(1, v));
    }
    function changeVolume(p, delta) {
        const v = volume(p);
        if (v !== null)
            setVolume(p, v + delta);
    }
    function seekTo(p, seconds) {
        if (p?.canSeek && p.positionSupported)
            p.position = seconds;
    }
}
