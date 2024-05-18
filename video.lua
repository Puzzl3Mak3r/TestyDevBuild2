local theora = require('plugin.theora')

-------------------------------------------------

local video = {
    _isPlaying = false
}

function video:new(...)
    local instance = ... or {}
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function video:scaffold(x, y, w, h, filename, duration, playbackended)
    self._duration = duration * 1000
    self._onPlaybackEnded = playbackended
    self._video = theora.decodeFromFile(filename)
    --
    self._container = display.newImageRect(self._video.filename, self._video.baseDir, w, h)
    self._container.x, self._container.y = x, y
    --
    self._registry = {
        function(event) self:_play() end
    }
end

function video:render(sceneGroup)
    sceneGroup:insert(self._container)
end

function video:info()
    return {
        paused = self._video.paused,
        format = self._video.format,
        elapsed = self._video.elapsed,
        hasAudio = self._video.hasAudio,
        hasVideo = self._video.hasVideo,
        availableAudio = self._video.availableAudio,
        availableVideo = self._video.availableVideo
    }
end

function video:audioMixin(filename, channel)
    self._audio = audio.loadStream(filename)
    self._channel = channel or 0
end

function video:_play()
    local now, delta = system.getTimer()
    if self._isPlaying then
        if self._prev then
            delta = now - self._prev
        end
        --
        self._video:Step(delta or 0)
        self._video:invalidate()
        --
        if self._video.elapsed >= self._duration then
            self._watchedToEnd = true -- entire video was watched
            self:stop()
        end
    end
    --
    self._prev = now
end

function video:play()
    if self._isPlaying then return end
    --
    if self._audio then
        self._activeChannel = audio.play(self._audio, {channel = self._channel})
    end
    --
    self._isPlaying = true
    Runtime:addEventListener('enterFrame', self._registry[1])
end

function video:pause()
    if not self._isPlaying then return end
    --
    if self._audio then
        audio.pause(self._activeChannel)
    end
    --
    self._isPlaying = false
    self._video:Pause(true)
end

function video:resume()
    if self._isPlaying then return end
    --
    if self._audio then
        audio.resume(self._activeChannel)
    end
    --
    self._isPlaying = true
    self._video:Pause(false)
end

function video:stop()
    Runtime:removeEventListener('enterFrame', self._registry[1])
    --
    if self._audio then
        audio.stop(self._activeChannel)
        audio.dispose(self._audio)
        self._audio = nil
    end
    --
    self._isPlaying = false
    self._video:Pause(true)
    --
    -- slight delay to avoid a crash that occurs when the video stops after being watched to the end
    -- funnily enough, there are no crashes if the video is stopped midway
    -- anyway a slight delay before calling "self._video:releaseSelf()" fixes the problem
    timer.performWithDelay(100,
        function()
            self._video:releaseSelf() -- culprit
            self._container:removeSelf()
            self._video, self._container = nil, nil
            --
            self._onPlaybackEnded(self._watchedToEnd or false)
        end
    )
end

return video