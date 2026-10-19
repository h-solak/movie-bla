// Local-dev only: Node 25+ removed buffer.SlowBuffer, which old deps
// (buffer-equal-constant-time via jsonwebtoken@8) still read at load time.
const buffer = require("buffer");
if (!buffer.SlowBuffer) {
  function SlowBuffer(size) {
    return Buffer.allocUnsafeSlow(size);
  }
  SlowBuffer.prototype = Buffer.prototype;
  buffer.SlowBuffer = SlowBuffer;
}
