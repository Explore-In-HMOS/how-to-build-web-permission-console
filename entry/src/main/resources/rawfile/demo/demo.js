'use strict';

function setStatus(text) {
  const el = document.getElementById('status');
  if (el) {
    el.textContent = text;
  }
}

function triggerGeolocation() {
  setStatus('Requesting location…');
  if (!navigator.geolocation) {
    setStatus('Geolocation unsupported');
    return;
  }
  navigator.geolocation.getCurrentPosition(
    function (pos) {
      const lat = pos.coords.latitude.toFixed(3);
      const lon = pos.coords.longitude.toFixed(3);
      document.getElementById('coords').textContent = lat + ', ' + lon;
      document.getElementById('temp').textContent = '21°';
      setStatus('Location granted');
      console.info('Weather updated for ' + lat + ',' + lon);
    },
    function (err) {
      document.getElementById('coords').textContent = 'Location denied';
      setStatus('Location error: ' + err.code);
      console.warn('Geolocation error code ' + err.code + ': ' + err.message);
    },
    { enableHighAccuracy: true, timeout: 10000 }
  );
}

function triggerConsole() {
  console.debug('debug: widget tick');
  console.info('info: fetching forecast');
  console.log('log: forecast cache hit');
  console.warn('warn: using stale forecast');
  console.error('error: forecast API unreachable');
  setStatus('Emitted 5 console messages');
}

function triggerAlert() {
  setStatus('Showing alert…');
  alert('Severe weather warning in your area.');
  setStatus('Alert dismissed');
}

function triggerConfirm() {
  setStatus('Showing confirm…');
  const ok = confirm('Enable severe-weather notifications?');
  setStatus('Confirm result: ' + ok);
  console.log('confirm() resolved to ' + ok);
}

function triggerPrompt() {
  setStatus('Showing prompt…');
  const city = prompt('Which city?', 'Shenzhen');
  setStatus('Prompt result: ' + city);
  console.log('prompt() resolved to ' + city);
}

function triggerMicrophone() {
  setStatus('Requesting microphone…');
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    setStatus('getUserMedia unsupported');
    return;
  }
  navigator.mediaDevices.getUserMedia({ video: false, audio: true })
    .then(function (stream) {
      setStatus('microphone granted');
      stream.getTracks().forEach(function (t) { t.stop(); });
    })
    .catch(function (err) {
      setStatus('microphone denied: ' + err.name);
      console.warn('getUserMedia failed: ' + err.name);
    });
}

function triggerNetError() {
  setStatus('Loading bad URL…');
  window.location.href = 'https://nonexistent.invalid.example/forecast';
}
