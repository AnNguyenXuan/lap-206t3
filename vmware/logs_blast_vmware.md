Here's a summary of what happened to this VMware Horizon Blast client:

📋 Session Timeline — April 17, 2026
🔴 Phase 1: Session Disconnection (16:16:00)
The client disconnected — intentionally by the user.

At 16:16:00, the Blast MKS and Audio channels for connection cnx:26 were closed.
The close reason was VDPCONNECT_USER_INIT_DISCONNECT (reason code: 23) — meaning the user deliberately disconnected the session (not a crash or network failure).
All VVC (VMware Virtual Channel) proxy server instances (prxy-srv-3092, prxy-srv-3684, prxy-srv-4052, prxy-srv-4848, prxy-srv-5288, prxy-srv-6708, prxy-srv-10620) shut down cleanly.
The session state machine transitioned: BLASTSESSION_CONNECTED → BLASTSESSION_INVALIDATED.
Auth tokens/cookies were invalidated and cleaned up.
The H.264 encoder (libx264-157.5.dll) was unloaded. Total encoded data: ~19.8 MB.
The VDI Desktop session was locked (WTS_SESSION_LOCK) at 16:16:01.
Client info from the session:

User: annx (domain VTDC) / local machine user: nguye_ax / machine: nguyenxuanan
Client IP: 192.168.102.52
Client Version: 5.3.0-15208953 (VMware Horizon Client for Windows)
Broker: vdi-rp.vtdc.local, accessed via External Gateway beta-cloud.viettelidc.com.vn
Desktop Pool: staffs (farm ID)
Display: 1 screen, 1920×1080, DPI 120, H.264 4:2:0
🟢 Phase 2: Session Reconnection (16:30:04 – 16:30:10)
The same user reconnected ~14 minutes later.

At 16:30:04, a new auth token (m0fakz**\***) was generated for a reconnection request.
At 16:30:06, a new WebSocket connection was established using TCP transport (not UDP — UDP headers were present but UDP Response Headers present: No).
A new VVC session (ID: 1, cnx:27) was started and reached [established] state.
All proxy service channels (prxy-srv-3092, prxy-srv-3684, prxy-srv-4048, prxy-srv-4848, prxy-srv-5288, prxy-srv-9372, prxy-srv-2404) reconnected successfully.
The display topology was set to 1920×1080 using the VMware SVGA 3D adapter.
H.264 encoding resumed using libx264-157.5.dll.
Two minor warnings occurred:
⚠️ HzMon_Init failed — Horizon Monitoring API could not initialize (non-critical).
⚠️ SetThreadDesktop failed: The requested resource is in use — minor, non-blocking.
⚠️ VNCEncodeRequestTopology: failed to set topology (x2) — duplicate topology requests, self-resolved.
⚠️ nvEncodeAPI64.dll unavailable — No NVIDIA GPU, falling back to software H.264 encoding.
🟢 Phase 3: Session Running Normally (16:30:38 – 16:31:38)
Bandwidth stats confirm the session was working well:
~9,046 KBps at 16:30:38 (RTT: 1.75 ms)
~9,966 KBps at 16:31:38 (RTT: 1.74 ms)
Very low RTT indicates an internal/LAN connection despite routing through an external gateway.
✅ Conclusion
No error or failure occurred. The user (annx) voluntarily disconnected at 16:16:00, the VDI desktop was locked, and then the user reconnected at 16:30:06. The new session established successfully and was running normally over TCP with H.264 software encoding.
