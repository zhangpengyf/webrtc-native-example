#include "Header.h"
#include "webrtc/call.h"
#include "webrtc/config.h"
#include "webrtc/logging/rtc_event_log/rtc_event_log.h"
#include "webrtc/media/engine/webrtcvoe.h"
#include "webrtc/modules/audio_coding/codecs/builtin_audio_decoder_factory.h"
#include "webrtc/base/asyncpacketsocket.h"
#include "webrtc/video_encoder.h"
#include "webrtc/video_decoder.h"
#include "webrtc/modules/video_coding/codec_database.h"
#include "webrtc/test/frame_generator_capturer.h"

webrtc::Call* g_call = nullptr;
cricket::VoEWrapper* g_voe  = nullptr;
webrtc::AudioSendStream* g_audioSendStream = nullptr;
webrtc::AudioReceiveStream* g_audioReceiveStream = nullptr;
webrtc::VideoSendStream* g_videoSendStream = nullptr;
webrtc::VideoReceiveStream* g_videoReceiveStream = nullptr;
rtc::scoped_refptr<webrtc::AudioDecoderFactory> g_audioDecoderFactory;

int g_audioSendChannelId = -1;
int g_audioReceiveChannelId = -1;
int g_videoSendChannelId = -1;
int g_videoReceiveChannelId = -1;
class AudioLoopbackTransport;
class VideoLoopbackTransport;
AudioLoopbackTransport* g_audioSendTransport = nullptr;
VideoLoopbackTransport* g_videoSendTransport = nullptr;

webrtc::VideoCodec g_videoCodec;

class AudioLoopbackTransport:public webrtc::Transport{
public:
    virtual bool SendRtp(const uint8_t* packet,size_t length,const webrtc::PacketOptions& options)
    {
        //printf("send audio rtp\n");
        rtc::PacketTime pTime = rtc::CreatePacketTime(0);
        webrtc::PacketReceiver::DeliveryStatus status = g_call->Receiver()->DeliverPacket(webrtc::MediaType::AUDIO, packet, length, webrtc::PacketTime(pTime.timestamp, pTime.not_before));
        assert(status == webrtc::PacketReceiver::DeliveryStatus::DELIVERY_OK);
        return true;
    }
    virtual bool SendRtcp(const uint8_t* packet, size_t length)
    {
        printf("send audio rtcp\n");
        rtc::PacketTime pTime = rtc::CreatePacketTime(0);
        webrtc::PacketReceiver::DeliveryStatus status = g_call->Receiver()->DeliverPacket(webrtc::MediaType::AUDIO, packet, length, webrtc::PacketTime(pTime.timestamp, pTime.not_before));
        assert(status == webrtc::PacketReceiver::DeliveryStatus::DELIVERY_OK);
        return true;
    }
};

class VideoLoopbackTransport:public webrtc::Transport{
public:
    virtual bool SendRtp(const uint8_t* packet,size_t length,const webrtc::PacketOptions& options)
    {
        printf("send video rtp\n");
        rtc::PacketTime pTime = rtc::CreatePacketTime(0);
        webrtc::PacketReceiver::DeliveryStatus status = g_call->Receiver()->DeliverPacket(webrtc::MediaType::VIDEO, packet, length, webrtc::PacketTime(pTime.timestamp, pTime.not_before));
        assert(status == webrtc::PacketReceiver::DeliveryStatus::DELIVERY_OK);
        return true;
    }
    virtual bool SendRtcp(const uint8_t* packet, size_t length)
    {
        printf("send video rtcp\n");
        rtc::PacketTime pTime = rtc::CreatePacketTime(0);
        webrtc::PacketReceiver::DeliveryStatus status = g_call->Receiver()->DeliverPacket(webrtc::MediaType::VIDEO, packet, length, webrtc::PacketTime(pTime.timestamp, pTime.not_before));
        assert(status == webrtc::PacketReceiver::DeliveryStatus::DELIVERY_OK);
        return true;
    }
};

class FakeRenderer : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
public:
    FakeRenderer() {};
    
    void OnFrame(const webrtc::VideoFrame& video_frame) override {
        printf("render frame");
    }
};

int CreateVoe()
{
    g_audioDecoderFactory = webrtc::CreateBuiltinAudioDecoderFactory();
    g_voe = new cricket::VoEWrapper();
    g_voe->base()->Init(NULL,NULL,g_audioDecoderFactory);
    return 0;
}

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

int CreateAudioSendStream()
{
    g_audioSendTransport = new AudioLoopbackTransport();
    webrtc::AudioSendStream::Config config(g_audioSendTransport);
    
    g_audioSendChannelId = g_voe->base()->CreateChannel();
    config.voe_channel_id = g_audioSendChannelId;
    g_audioSendStream = g_call->CreateAudioSendStream(config);
    
    assert(g_audioSendStream);
    return 0;
}

int CreateAudioReceiveStream()
{
    webrtc::AudioReceiveStream::Config config;
    config.decoder_factory = g_audioDecoderFactory;
    g_audioReceiveChannelId = g_voe->base()->CreateChannel();
    config.voe_channel_id = g_audioReceiveChannelId;
    
    g_audioReceiveStream = g_call->CreateAudioReceiveStream(config);
    
    assert(g_audioReceiveStream);
    return 0;
}


class EncoderStreamFactory : public webrtc::VideoEncoderConfig::VideoStreamFactoryInterface {
public:
    EncoderStreamFactory(std::string codec_name,
                         int max_qp,
                         int max_framerate,
                         bool is_screencast,
                         bool conference_mode)
    : codec_name_(codec_name),
    max_qp_(max_qp),
    max_framerate_(max_framerate),
    is_screencast_(is_screencast),
    conference_mode_(conference_mode) {}
    
private:
    std::vector<webrtc::VideoStream> CreateEncoderStreams(
                                                          int width,
                                                          int height,
                                                          const webrtc::VideoEncoderConfig& encoder_config) override {
        RTC_DCHECK(encoder_config.number_of_streams > 1 ? !is_screencast_ : true);
        
        
        webrtc::VideoStream stream;
        stream.width = width;
        stream.height = height;
        stream.max_framerate = max_framerate_;
        stream.min_bitrate_bps = 100 * 1000;
        stream.target_bitrate_bps = stream.max_bitrate_bps = 500*1000;
        stream.max_qp = max_qp_;
        
        
        std::vector<webrtc::VideoStream> streams;
        streams.push_back(stream);
        return streams;
    }
    
    const std::string codec_name_;
    const int max_qp_;
    const int max_framerate_;
    const bool is_screencast_;
    const bool conference_mode_;
};


int CreateVideoSendStream()
{
    g_videoSendTransport = new VideoLoopbackTransport();

    //VideoEncoderConfig
    webrtc::VideoEncoderConfig encoder_config;
    webrtc::VCMCodecDataBase::Codec(webrtc::kVideoCodecVP8, &g_videoCodec);
    encoder_config.encoder_specific_settings = new rtc::RefCountedObject<webrtc::VideoEncoderConfig::Vp8EncoderSpecificSettings>(g_videoCodec.codecSpecific.VP8);
    encoder_config.encoder_specific_settings->FillEncoderSpecificSettings(&g_videoCodec);
    encoder_config.content_type = webrtc::VideoEncoderConfig::ContentType::kRealtimeVideo;
    encoder_config.number_of_streams = 1;
    encoder_config.video_stream_factory = new rtc::RefCountedObject<EncoderStreamFactory>(g_videoCodec.plName, g_videoCodec.qpMax, g_videoCodec.maxFramerate, false, false);
    
    //Config
    webrtc::VideoSendStream::Config config(g_videoSendTransport);
    config.rtp.ssrcs.push_back(888);
    config.encoder_settings.payload_name = "VP8";
    config.encoder_settings.encoder = webrtc::VideoEncoder::Create(webrtc::VideoEncoder::EncoderType::kVp8);
    config.encoder_settings.payload_type = g_videoCodec.plType;
    
    g_videoSendStream = g_call->CreateVideoSendStream(std::move(config), std::move(encoder_config));
    return 0;
}

int CreateVideoReceiveStream()
{
    webrtc::VideoReceiveStream::Config config(g_videoSendTransport);
    config.renderer = new FakeRenderer();
    config.rtp.local_ssrc = 222;
    config.rtp.remote_ssrc = 888;
    webrtc::VideoReceiveStream::Decoder decoder;
    decoder.decoder = webrtc::VideoDecoder::Create(webrtc::VideoDecoder::DecoderType::kVp8);
    decoder.payload_name = g_videoCodec.plName;
    decoder.payload_type = g_videoCodec.plType;
    config.decoders.push_back(decoder);
    g_videoReceiveStream = g_call->CreateVideoReceiveStream(std::move(config));
    return 0;
}

int StartCall()
{
    g_audioSendStream->Start();
    g_audioReceiveStream->Start();
    g_videoReceiveStream->Start();
    
    webrtc::test::FrameGeneratorCapturer* capture = webrtc::test::FrameGeneratorCapturer::Create(640, 480, 20, webrtc::Clock::GetRealTimeClock());
    capture->Init();
    g_videoSendStream->SetSource(capture);
    capture->Start();
    g_videoSendStream->Start();
    
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
