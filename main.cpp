
#include <windows.h>
#include <string>
#include <map>
#include <memory>
#include <string>
#include <algorithm>
#include "webrtc/api/mediastreaminterface.h"
#include "webrtc/base/win32.h"
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
#include <map>
#include <memory>
#include <string>


#include "webrtc/system_wrappers/include/clock.h"
#include "webrtc/logging/rtc_event_log/rtc_event_log.h"
#include "webrtc/call.h"

int main()
{
	std::unique_ptr<webrtc::RtcEventLog> event_log = webrtc::RtcEventLog::Create(webrtc::Clock::GetRealTimeClock());
	webrtc::Call::Config config(event_log.get());

	webrtc::Call* call = webrtc::Call::Create(config);
	return 0;
}