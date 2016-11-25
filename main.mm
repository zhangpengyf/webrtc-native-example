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
#include "webrtc/api/call/audio_state.h"

webrtc::Call* g_call = nullptr;
cricket::VoEWrapper* g_voe  = nullptr;
webrtc::AudioSendStream* g_audioSendStream = nullptr;
webrtc::AudioReceiveStream* g_audioReceiveStream = nullptr;
webrtc::VideoSendStream* g_videoSendStream = nullptr;
webrtc::VideoReceiveStream* g_videoReceiveStream = nullptr;

int CreateCall()
{
    std::unique_ptr<webrtc::RtcEventLog> event_log = webrtc::RtcEventLog::Create(webrtc::Clock::GetRealTimeClock());
    webrtc::AudioState::Config stateconfig;
    stateconfig.voice_engine = g_voe->engine();
    rtc::scoped_refptr<webrtc::AudioState> audio_state = webrtc::AudioState::Create(stateconfig);
    
    webrtc::Call::Config config;
    config.audio_state = audio_state;
    config.audio_processing = NULL;
    g_call = webrtc::Call::Create(config);
    
    assert(g_call);
    return 0;
}

int CreateVoe()
{
    g_voe = new cricket::VoEWrapper();
    g_voe->base()->Init();
    return 0;
}

int CreateAudioSendStream()
{
    webrtc::Transport* send_transport = NULL;
    webrtc::AudioSendStream::Config audiosendconfig(send_transport);
    
    int channelId = g_voe->base()->CreateChannel();
    audiosendconfig.voe_channel_id = channelId;
    g_audioSendStream = g_call->CreateAudioSendStream(audiosendconfig);
    
    assert(g_audioSendStream);
    return 0;
}

int CreateAudioReceiveStream()
{
    return 0;
}

int CreateVideoSendStream()
{
    return 0;
}

int CreateVideoReceiveStream()
{
    return 0;
}

int StartCall()
{
    return 0;
}

int test_main()
{
    CreateVoe();
    CreateCall();
    CreateAudioSendStream();
    CreateAudioReceiveStream();
    CreateVideoSendStream();
    CreateVideoReceiveStream();
    StartCall();
    return 0;
}
