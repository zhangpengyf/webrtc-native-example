#include "Header.h"
#include <string>
#include <map>
#include <memory>
#include <algorithm>
#include "webrtc/api/mediastreaminterface.h"
#include "webrtc/media/base/mediachannel.h"
#include "webrtc/media/base/videocommon.h"
#include "webrtc/video_frame.h"
#include "webrtc/call.h"
#include "webrtc/logging/rtc_event_log/rtc_event_log.h"
#include "webrtc/system_wrappers/include/clock.h"
#include "webrtc/base/nethelpers.h"
#include "webrtc/base/physicalsocketserver.h"
#include "webrtc/base/signalthread.h"
#include "webrtc/base/sigslot.h"
#include "webrtc/base/ssladapter.h"
#include "webrtc/base/win32socketinit.h"
#include "webrtc/base/win32socketserver.h"
#include "webrtc/base/basictypes.h"
#include "webrtc/system_wrappers/include/clock.h"
#include "webrtc/logging/rtc_event_log/rtc_event_log.h"
#include "webrtc/modules/audio_device/include/audio_device_defines.h"
#include "webrtc/media/engine/webrtcvoe.h"

int test_main()
{
    std::unique_ptr<webrtc::RtcEventLog> event_log = webrtc::RtcEventLog::Create(webrtc::Clock::GetRealTimeClock());
    webrtc::Call::Config config;
    config.audio_processing = NULL;
    
    webrtc::Call* call = webrtc::Call::Create(config);
    
    cricket::VoEWrapper* voe = new cricket::VoEWrapper();
    webrtc::AudioTransport* audio_transport = voe->base()->audio_transport();
    webrtc::Transport* send_transport = NULL;
    const webrtc::AudioSendStream::Config audiosendconfig(send_transport);
    call->CreateAudioSendStream(audiosendconfig);
    return 0;
}
