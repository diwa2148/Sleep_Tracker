/**
 * SOMNA Vintage Ambient Sound Synthesizer
 * High-performance Web Audio API procedural sound engine:
 * - Tape Hiss (Warm analog cassette flutter)
 * - Midnight Rain & Soft Vinyl Crackle
 * - 432 Hz Binaural Theta Sleep Drone
 * - 80s FM Analog Dreamwave Poly-Pad
 */
window.SomnaAudioSynth = (function() {
  let audioCtx = null;
  let currentNodes = [];
  let masterGain = null;
  let isPlaying = false;
  let currentTrackId = null;

  function initContext() {
    if (!audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      audioCtx = new AudioContext();
      masterGain = audioCtx.createGain();
      masterGain.gain.setValueAtTime(0.5, audioCtx.currentTime);
      masterGain.connect(audioCtx.destination);
    }
    if (audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
  }

  function stop() {
    for (const node of currentNodes) {
      try {
        if (node.stop) node.stop();
        if (node.disconnect) node.disconnect();
      } catch (e) {}
    }
    currentNodes = [];
    isPlaying = false;
    currentTrackId = null;
  }

  function setVolume(vol) {
    if (masterGain && audioCtx) {
      masterGain.gain.setTargetAtTime(Math.max(0, Math.min(1, vol)), audioCtx.currentTime, 0.05);
    }
  }

  function play(trackId, vol) {
    initContext();
    stop();
    if (vol !== undefined) setVolume(vol);
    currentTrackId = trackId;
    isPlaying = true;

    const sampleRate = audioCtx.sampleRate;
    const now = audioCtx.currentTime;

    if (trackId === 'tape_hiss') {
      // 1. Warm Analog Tape Hiss (Filtered noise with subtle wow & flutter)
      const bufferSize = sampleRate * 2;
      const buffer = audioCtx.createBuffer(1, bufferSize, sampleRate);
      const data = buffer.getChannelData(0);
      let last = 0;
      for (let i = 0; i < bufferSize; i++) {
        const white = Math.random() * 2 - 1;
        // Mild 1-pole pinkish smoothing
        data[i] = (last * 0.35) + (white * 0.65);
        last = data[i];
      }
      const noise = audioCtx.createBufferSource();
      noise.buffer = buffer;
      noise.loop = true;

      const bandpass = audioCtx.createBiquadFilter();
      bandpass.type = 'bandpass';
      bandpass.frequency.setValueAtTime(2200, now);
      bandpass.Q.setValueAtTime(0.6, now);

      const lfo = audioCtx.createOscillator();
      lfo.frequency.setValueAtTime(0.35, now); // 0.35 Hz subtle flutter
      const lfoGain = audioCtx.createGain();
      lfoGain.gain.setValueAtTime(0.08, now);

      const trackGain = audioCtx.createGain();
      trackGain.gain.setValueAtTime(0.35, now);

      lfo.connect(lfoGain);
      lfoGain.connect(trackGain.gain);

      noise.connect(bandpass);
      bandpass.connect(trackGain);
      trackGain.connect(masterGain);

      noise.start();
      lfo.start();
      currentNodes.push(noise, lfo, bandpass, lfoGain, trackGain);

    } else if (trackId === 'midnight_rain') {
      // 2. Midnight Rain & Soft Vinyl Crackle
      const bufferSize = sampleRate * 3;
      const buffer = audioCtx.createBuffer(2, bufferSize, sampleRate);
      for (let ch = 0; ch < 2; ch++) {
        const data = buffer.getChannelData(ch);
        let b0 = 0, b1 = 0, b2 = 0;
        for (let i = 0; i < bufferSize; i++) {
          const white = Math.random() * 2 - 1;
          b0 = 0.99886 * b0 + white * 0.0555179;
          b1 = 0.99332 * b1 + white * 0.0750759;
          b2 = 0.96900 * b2 + white * 0.1538520;
          let sample = b0 + b1 + b2 + white * 0.5362;
          // Random soft vinyl clicks (0.04% probability)
          if (Math.random() < 0.0004) {
            sample += (Math.random() * 2 - 1) * 2.2;
          }
          data[i] = sample * 0.12;
        }
      }
      const rain = audioCtx.createBufferSource();
      rain.buffer = buffer;
      rain.loop = true;

      const lowpass = audioCtx.createBiquadFilter();
      lowpass.type = 'lowpass';
      lowpass.frequency.setValueAtTime(950, now);

      const trackGain = audioCtx.createGain();
      trackGain.gain.setValueAtTime(0.4, now);

      rain.connect(lowpass);
      lowpass.connect(trackGain);
      trackGain.connect(masterGain);

      rain.start();
      currentNodes.push(rain, lowpass, trackGain);

    } else if (trackId === 'synth_432') {
      // 3. 432 Hz Binaural Theta Sleep Carrier
      const osc1 = audioCtx.createOscillator();
      osc1.type = 'sine';
      osc1.frequency.setValueAtTime(432, now);

      const osc2 = audioCtx.createOscillator();
      osc2.type = 'sine';
      osc2.frequency.setValueAtTime(436, now); // 4 Hz binaural beat

      const sub = audioCtx.createOscillator();
      sub.type = 'sine';
      sub.frequency.setValueAtTime(216, now);

      const trackGain = audioCtx.createGain();
      trackGain.gain.setValueAtTime(0.18, now);

      osc1.connect(trackGain);
      osc2.connect(trackGain);
      sub.connect(trackGain);
      trackGain.connect(masterGain);

      osc1.start();
      osc2.start();
      sub.start();
      currentNodes.push(osc1, osc2, sub, trackGain);

    } else if (trackId === 'dreamwave') {
      // 4. 80s FM Analog Dreamwave Poly-Pad
      const freqs = [110, 164.8, 277.18];
      const trackGain = audioCtx.createGain();
      trackGain.gain.setValueAtTime(0.15, now);

      const filter = audioCtx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(480, now);

      const lfo = audioCtx.createOscillator();
      lfo.frequency.setValueAtTime(0.1, now);
      const lfoGain = audioCtx.createGain();
      lfoGain.gain.setValueAtTime(160, now);
      lfo.connect(lfoGain);
      lfoGain.connect(filter.frequency);

      freqs.forEach(freq => {
        const osc = audioCtx.createOscillator();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(freq, now);
        osc.connect(filter);
        osc.start();
        currentNodes.push(osc);
      });

      filter.connect(trackGain);
      trackGain.connect(masterGain);
      lfo.start();
      currentNodes.push(filter, lfo, lfoGain, trackGain);
    }
  }

  let alarmInterval = null;
  let alarmNodes = [];
  let isAlarmPlaying = false;
  let currentAlarmId = null;

  function stopAlarm() {
    if (alarmInterval) {
      clearInterval(alarmInterval);
      alarmInterval = null;
    }
    for (const node of alarmNodes) {
      try {
        if (node.stop) node.stop();
        if (node.disconnect) node.disconnect();
      } catch (e) {}
    }
    alarmNodes = [];
    isAlarmPlaying = false;
    currentAlarmId = null;
  }

  function playAlarm(alarmId, vol) {
    initContext();
    stopAlarm();
    if (vol !== undefined) setVolume(vol);
    currentAlarmId = alarmId;
    isAlarmPlaying = true;

    function trigger8BitNote(freq, startTime, duration) {
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      osc.type = 'square';
      osc.frequency.setValueAtTime(freq, startTime);

      // 8-bit snappy pluck envelope
      gain.gain.setValueAtTime(0.001, startTime);
      gain.gain.linearRampToValueAtTime(0.22, startTime + 0.015);
      gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration);

      osc.connect(gain);
      gain.connect(masterGain);
      osc.start(startTime);
      osc.stop(startTime + duration + 0.05);
      alarmNodes.push(osc, gain);
    }

    function triggerFmChime(carrierFreq, startTime) {
      const carrier = audioCtx.createOscillator();
      const modulator = audioCtx.createOscillator();
      const modGain = audioCtx.createGain();
      const noteGain = audioCtx.createGain();

      carrier.type = 'sine';
      carrier.frequency.setValueAtTime(carrierFreq, startTime);

      modulator.type = 'sine';
      modulator.frequency.setValueAtTime(carrierFreq * 3.5, startTime);

      modGain.gain.setValueAtTime(carrierFreq * 2.0, startTime);
      modGain.gain.exponentialRampToValueAtTime(1.0, startTime + 1.2);

      noteGain.gain.setValueAtTime(0.001, startTime);
      noteGain.gain.linearRampToValueAtTime(0.25, startTime + 0.03);
      noteGain.gain.exponentialRampToValueAtTime(0.001, startTime + 1.6);

      modulator.connect(modGain);
      modGain.connect(carrier.frequency);
      carrier.connect(noteGain);
      noteGain.connect(masterGain);

      modulator.start(startTime);
      carrier.start(startTime);
      modulator.stop(startTime + 1.7);
      carrier.stop(startTime + 1.7);
      alarmNodes.push(carrier, modulator, modGain, noteGain);
    }

    function triggerQuartzChirp(startTime) {
      [0, 0.12].forEach(offset => {
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'square';
        osc.frequency.setValueAtTime(2048, startTime + offset);

        gain.gain.setValueAtTime(0.2, startTime + offset);
        gain.gain.setValueAtTime(0.001, startTime + offset + 0.07);

        osc.connect(gain);
        gain.connect(masterGain);
        osc.start(startTime + offset);
        osc.stop(startTime + offset + 0.08);
        alarmNodes.push(osc, gain);
      });
    }

    function triggerAnalogSweep(startTime) {
      const osc1 = audioCtx.createOscillator();
      const osc2 = audioCtx.createOscillator();
      const filter = audioCtx.createBiquadFilter();
      const gain = audioCtx.createGain();

      osc1.type = 'sawtooth';
      osc1.frequency.setValueAtTime(220, startTime);
      osc2.type = 'sawtooth';
      osc2.frequency.setValueAtTime(221.4, startTime); // warm detune

      filter.type = 'lowpass';
      filter.Q.setValueAtTime(4.0, startTime);
      filter.frequency.setValueAtTime(240, startTime);
      filter.frequency.exponentialRampToValueAtTime(1400, startTime + 1.2);

      gain.gain.setValueAtTime(0.001, startTime);
      gain.gain.linearRampToValueAtTime(0.2, startTime + 0.15);
      gain.gain.exponentialRampToValueAtTime(0.001, startTime + 1.8);

      osc1.connect(filter);
      osc2.connect(filter);
      filter.connect(gain);
      gain.connect(masterGain);

      osc1.start(startTime);
      osc2.start(startTime);
      osc1.stop(startTime + 1.9);
      osc2.stop(startTime + 1.9);
      alarmNodes.push(osc1, osc2, filter, gain);
    }

    function step() {
      if (!isAlarmPlaying) return;
      const t = audioCtx.currentTime;

      if (alarmId === '8bit_dawn') {
        const scale = [261.63, 329.63, 392.00, 493.88, 523.25, 659.25];
        scale.forEach((freq, idx) => {
          trigger8BitNote(freq, t + (idx * 0.14), 0.18);
        });
      } else if (alarmId === 'fm_chime') {
        triggerFmChime(523.25, t); // C5
        triggerFmChime(659.25, t + 0.22); // E5
        triggerFmChime(783.99, t + 0.44); // G5
      } else if (alarmId === 'quartz_beep') {
        triggerQuartzChirp(t);
      } else if (alarmId === 'analog_sunrise') {
        triggerAnalogSweep(t);
      }
    }

    step();
    const intervalMs = alarmId === 'quartz_beep' ? 1400 : 2600;
    alarmInterval = setInterval(step, intervalMs);
  }

  return {
    play: play,
    stop: stop,
    setVolume: setVolume,
    isPlaying: function() { return isPlaying; },
    getTrack: function() { return currentTrackId; },
    playAlarm: playAlarm,
    stopAlarm: stopAlarm,
    isAlarmPlaying: function() { return isAlarmPlaying; },
    getAlarm: function() { return currentAlarmId; }
  };
})();

