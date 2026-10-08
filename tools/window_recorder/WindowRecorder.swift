import Foundation
import AppKit
import ScreenCaptureKit
import AVFoundation
import CoreGraphics
import CoreVideo

struct CaptureError: Error, CustomStringConvertible { let description: String }
func flag(_ name: String) -> Bool { CommandLine.arguments.contains(name) }
func arg(_ name: String) -> String? { guard let i=CommandLine.arguments.firstIndex(of:name), i+1<CommandLine.arguments.count else{return nil};return CommandLine.arguments[i+1] }
func currentWindowTitle(_ id: CGWindowID) -> String? {
 guard let rows=CGWindowListCopyWindowInfo(.optionIncludingWindow,id) as? [[String:Any]],let row=rows.first(where:{($0[kCGWindowNumber as String] as? NSNumber)?.uint32Value==id}) else{return nil}
 return row[kCGWindowName as String] as? String
}
func safeError(_ error: Error) -> [String:Any] {
 let e=error as NSError
 var result:[String:Any] = ["domain":e.domain,"code":e.code]
 if let own=error as? CaptureError { result["reason"]=own.description }
 if let underlying=e.userInfo[NSUnderlyingErrorKey] as? NSError {
  result["underlying"]=["domain":underlying.domain,"code":underlying.code]
 }
 // Localized descriptions and userInfo can contain paths, URLs or account details.
 return result
}
func utc(_ date: Date) -> String {
 let iso=ISO8601DateFormatter();iso.formatOptions=[.withInternetDateTime,.withFractionalSeconds]
 return iso.string(from:date)
}
final class Sink: NSObject, SCStreamOutput, SCStreamDelegate {
 let writer: AVAssetWriter
 let input: AVAssetWriterInput
 var frames=0
 var nonBlackFrames=0
 var previousPixels: [Double]?
 var lastMotionUTC: Date?
 var motionComparedFrames=0
 var totalMeanDifference=0.0
 var firstSampleUTC: Date?
 var lastSampleUTC: Date?
 var firstSamplePTS: Double?
 var lastSamplePTS: Double?
 var started=false
 var failure: String?
 var failureError: Error?
 var accepting=true
 init(url: URL,width: Int,height: Int,fragmentSeconds: Double?) throws {
  writer=try AVAssetWriter(outputURL:url,fileType:.mp4)
  if let seconds=fragmentSeconds{writer.movieFragmentInterval=CMTime(seconds:seconds,preferredTimescale:600)}
  input=AVAssetWriterInput(mediaType:.video,outputSettings:[AVVideoCodecKey:AVVideoCodecType.h264,AVVideoWidthKey:width,AVVideoHeightKey:height,AVVideoCompressionPropertiesKey:[AVVideoAverageBitRateKey:12_000_000,AVVideoMaxKeyFrameIntervalKey:30]])
  input.expectsMediaDataInRealTime=true
  super.init()
  guard writer.canAdd(input) else{throw CaptureError(description:"Cannot create video writer")};writer.add(input)
 }
 func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
  guard accepting,type == .screen, sampleBuffer.isValid else{return}
  if let attachments=CMSampleBufferGetSampleAttachmentsArray(sampleBuffer,createIfNecessary:false) as? [[SCStreamFrameInfo:Any]], let status=attachments.first?[.status] as? Int, status != SCFrameStatus.complete.rawValue{return}
  guard let pixels=CMSampleBufferGetImageBuffer(sampleBuffer) else{return}
  CVPixelBufferLockBaseAddress(pixels,.readOnly)
  if let address=CVPixelBufferGetBaseAddress(pixels) {
   let data=address.assumingMemoryBound(to:UInt8.self),width=CVPixelBufferGetWidth(pixels),height=CVPixelBufferGetHeight(pixels),stride=CVPixelBufferGetBytesPerRow(pixels)
   var visible=false
   var samples=[Double]()
   for y in Swift.stride(from:0,to:height,by:max(1,height/16)) {
    for x in Swift.stride(from:0,to:width,by:max(1,width/24)) {
     let i=y*stride+x*4
     let brightness=(Double(data[i])+Double(data[i+1])+Double(data[i+2]))/3
     samples.append(brightness)
     if max(data[i],max(data[i+1],data[i+2]))>8{visible=true}
    }
   }
   if let previous=previousPixels,previous.count==samples.count {
    let mean=zip(previous,samples).reduce(0.0){$0+abs($1.0-$1.1)}/Double(samples.count)
    motionComparedFrames += 1;totalMeanDifference += mean
    if mean>=0.1{lastMotionUTC=Date()}
   } else{lastMotionUTC=Date()}
   previousPixels=samples
   if visible{nonBlackFrames += 1}
  }
  CVPixelBufferUnlockBaseAddress(pixels,.readOnly)
  if !started {
   guard writer.startWriting() else{failure="Video writer start failed";failureError=writer.error;return}
   writer.startSession(atSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer));started=true
  }
  if input.isReadyForMoreMediaData {
   if input.append(sampleBuffer){
    frames += 1
    let utc=Date(),pts=CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
    if firstSampleUTC==nil{firstSampleUTC=utc;firstSamplePTS=pts}
    lastSampleUTC=utc;lastSamplePTS=pts
   }else{failure="Video writer append failed";failureError=writer.error}
  }
 }
 func stream(_ stream: SCStream, didStopWithError error: Error){failure="Window capture stopped unexpectedly";failureError=error}
}
@main struct WindowRecorder {
 static let backgroundColor=CGColor(gray:0,alpha:1)
 @MainActor static func main() async {
  let application=NSApplication.shared
  application.setActivationPolicy(.prohibited)
  var failureContext:[String:Any]=["version":3,"timestampUTC":utc(Date()),"deliveryEligible":false,"usableMedia":false]
  var activeSink: Sink?
  var activeQueue: DispatchQueue?
  var outputPath: String?
  var stage="validation"
  do {
   guard let raw=arg("--window-id"), let id=UInt32(raw), let video=arg("--approval"), video.range(of:"^[A-Za-z0-9_-]{11}$",options:.regularExpression) != nil else{throw CaptureError(description:"Provide --window-id NUMBER and --approval VIDEOID")}
   failureContext["windowID"]=id;failureContext["approval"]=video
   guard arg("--rights")=="licensed" else{throw CaptureError(description:"Only existing licensed rights are accepted")}
   let duration=Double(arg("--seconds") ?? "8") ?? 0
   let review=flag("--source-review")
   guard review ? (duration>=30 && duration<=1200) : (duration>=6 && duration<=10) else{throw CaptureError(description:review ? "Source review must be between30 and1200 seconds" : "Delivery recording must be between6 and10 seconds")}
   var fragmentSeconds: Double?
   if let raw=arg("--fragment-seconds") {
    guard review,let seconds=Double(raw),seconds>=10,seconds<=60 else{throw CaptureError(description:"Optional fragments require source review and interval10–60 seconds")}
    fragmentSeconds=seconds
   }
   var stopURL: URL?
   if let stopPath=arg("--stop-file") {
    let candidate=URL(fileURLWithPath:stopPath).standardizedFileURL
    guard candidate.path.hasPrefix("/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/browser-recording/"), !FileManager.default.fileExists(atPath:candidate.path) else{throw CaptureError(description:"Stop file must be a new path inside approved folder")}
    stopURL=candidate
   }
   guard CGPreflightScreenCaptureAccess() else{throw CaptureError(description:"Existing screen capture permission unavailable; no permission request made")}
   stage="enumerating_window"
   let content=try await SCShareableContent.excludingDesktopWindows(false,onScreenWindowsOnly:true)
   guard let window=content.windows.first(where:{$0.windowID==id}), window.owningApplication?.bundleIdentifier=="com.google.Chrome" else{throw CaptureError(description:"Explicit Chrome window unavailable")}
   failureContext["windowPresent"]=true;failureContext["windowIsChrome"]=true
   let expectedTitle=arg("--expected-title")
   if let expected=expectedTitle {
    guard !expected.isEmpty,let title=currentWindowTitle(id),title.localizedCaseInsensitiveContains(expected) else{throw CaptureError(description:"Selected Chrome window title does not match expected source")}
   }
   failureContext["expectedTitleMatched"]=expectedTitle != nil
   let filter=SCContentFilter(desktopIndependentWindow:window)
   let scale=CGFloat(filter.pointPixelScale)
   var rect=CGRect(origin:.zero,size:window.frame.size)
   if let rawCrop=arg("--crop") {
    let nums=rawCrop.split(separator:",").compactMap{Double($0)}
    guard nums.count==4 else{throw CaptureError(description:"Crop must be x,y,width,height in window points")}
    let crop=CGRect(x:nums[0],y:nums[1],width:nums[2],height:nums[3])
    guard crop.width>0,crop.height>0,rect.contains(crop) else{throw CaptureError(description:"Crop lies outside selected window")};rect=crop
   }
   let width=max(2,Int(rect.width*scale)/2*2),height=max(2,Int(rect.height*scale)/2*2)
   let apply=flag("--apply")
   let summary:[String:Any]=["version":3,"fragmentIntervalSeconds":fragmentSeconds ?? NSNull(),"fragmentRecoveryVerified":false,"dryRun":!apply,"windowID":id,"approval":video,"rights":"licensed","seconds":duration,"width":width,"height":height,"capturesAudio":false,"capturesFullDisplay":false,"capturesOtherWindows":false,"cursor":false,"sourceReview":review,"deliveryEligible":!review,"expectedTitle":expectedTitle ?? NSNull(),"expectedTitleMatched":expectedTitle != nil]
   print(String(data:try JSONSerialization.data(withJSONObject:summary,options:.sortedKeys),encoding:.utf8)!)
   guard apply else{return}
   guard let path=arg("--output"),path.hasPrefix("/Volumes/TONY SSD/ASCENDED_MEDIA/farming34/browser-recording/"),path.hasSuffix(".mp4") else{throw CaptureError(description:"Output must be an MP4 inside approved browser-recording directory")}
   guard !FileManager.default.fileExists(atPath:path) else{throw CaptureError(description:"Output exists; refusing overwrite")}
   outputPath=path;stage="creating_writer"
   let sink=try Sink(url:URL(fileURLWithPath:path),width:width,height:height,fragmentSeconds:fragmentSeconds)
   activeSink=sink
   let config=SCStreamConfiguration()
   config.width=width;config.height=height;config.minimumFrameInterval=CMTime(value:1,timescale:30);config.queueDepth=5;config.showsCursor=false;config.capturesAudio=false;config.backgroundColor=backgroundColor;config.pixelFormat=kCVPixelFormatType_32BGRA;config.sourceRect=rect
   let queue=DispatchQueue(label:"licensed-window-video")
   activeQueue=queue
   let stream=SCStream(filter:filter,configuration:config,delegate:sink)
   try stream.addStreamOutput(sink,type:.screen,sampleHandlerQueue:queue)
   stage="starting_capture"
   try await stream.startCapture()
   stage="recording"
   let recordingStart=DispatchTime.now().uptimeNanoseconds
   var lastProgress=0.0
   var stoppedEarly=false
   var lastTitleCheck=0.0
   var maximumStagnation=0.0
   var stagnationWarning=false
   while true {
    let elapsed=Double(DispatchTime.now().uptimeNanoseconds-recordingStart)/1_000_000_000
    if elapsed>=duration{break}
    let lastMotion=queue.sync{sink.lastMotionUTC}
    let stagnant=lastMotion.map{max(0,Date().timeIntervalSince($0))} ?? 0
    maximumStagnation=max(maximumStagnation,stagnant)
    if stagnant>=30{stagnationWarning=true}
    if expectedTitle != nil && elapsed-lastTitleCheck>=15 {
     guard let title=currentWindowTitle(id),title.localizedCaseInsensitiveContains(expectedTitle!) else{
      failureContext["expectedTitleMatched"]=false
      queue.sync{sink.failure="Chrome window title changed away from expected source"};break
     }
     lastTitleCheck=elapsed
    }
    if let stopURL=stopURL,FileManager.default.fileExists(atPath:stopURL.path){stoppedEarly=true;break}
    if review && elapsed-lastProgress>=15 {
     let count=queue.sync{sink.frames}
     let progress:[String:Any]=["status":"recording_source_review","elapsedSeconds":Int(elapsed),"requestedSeconds":duration,"frames":count,"deliveryEligible":false,"stagnationWarning":stagnant>=30,"stagnationSeconds":Int(stagnant)]
     print(String(data:try JSONSerialization.data(withJSONObject:progress,options:.sortedKeys),encoding:.utf8)!);fflush(stdout)
     lastProgress=elapsed
    }
    if queue.sync(execute:{sink.failure != nil}){break}
    try await Task.sleep(nanoseconds:500_000_000)
   }
   stage="stopping_capture"
   // A stop error must still flush the writer and emit rejected-partial evidence.
   var stopError: Error?
   do{try await stream.stopCapture()}catch{stopError=error}
   queue.sync{sink.accepting=false;if sink.started && sink.writer.status == .writing{sink.input.markAsFinished()}}
   stage="finishing_writer"
   if sink.started && sink.writer.status == .writing{await sink.writer.finishWriting()}
   if let error=stopError{stage="stopping_capture";throw error}
   if let error=sink.failureError{throw error}
   guard sink.started,sink.frames>0,sink.nonBlackFrames>0,sink.failure==nil else{throw CaptureError(description:sink.failure ?? "No visible nonblack video frames; capture rejected")}
   guard sink.writer.status == .completed else{throw sink.writer.error ?? CaptureError(description:"Video writer failed; capture rejected")}
   var metadata=summary
   let iso=ISO8601DateFormatter();iso.formatOptions=[.withInternetDateTime,.withFractionalSeconds]
   metadata["dryRun"]=false;metadata["status"]="captured_pending_visual_review";metadata["frames"]=sink.frames;metadata["output"]=path;metadata["requiresBlackBlockedContentReview"]=true;metadata["stoppedEarly"]=stoppedEarly
   metadata["motionReview"]=["warningOnly":true,"stagnationWarning":stagnationWarning,"maximumStagnationSeconds":maximumStagnation,"thresholdMeanPixelLevels":0.1,"thresholdNormalized":0.1/255.0,"comparedFrames":sink.motionComparedFrames,"averageMeanPixelDifference":sink.motionComparedFrames>0 ? sink.totalMeanDifference/Double(sink.motionComparedFrames):0]
   metadata["cropWindowPoints"]=[rect.origin.x,rect.origin.y,rect.width,rect.height]
   if let date=sink.firstSampleUTC{metadata["firstSampleUTC"]=iso.string(from:date)}
   if let date=sink.lastSampleUTC{metadata["lastSampleUTC"]=iso.string(from:date)}
   if let pts=sink.firstSamplePTS{metadata["firstSamplePTSSeconds"]=pts}
   if let pts=sink.lastSamplePTS{metadata["lastSamplePTSSeconds"]=pts}
   if let first=sink.firstSamplePTS,let last=sink.lastSamplePTS{metadata["sampleSpanSeconds"]=last-first}
   metadata["ptsMeaning"]="Capture host presentation clock; source playback timestamp must be supplied separately"
   let result=try JSONSerialization.data(withJSONObject:metadata,options:[.sortedKeys,.prettyPrinted])
   try result.write(to:URL(fileURLWithPath:path+".capture.json"),options:.atomic)
   print(String(data:result,encoding:.utf8)!)
  } catch {
   failureContext["timestampUTC"]=utc(Date());failureContext["status"]="rejected_partial_capture"
   failureContext["stage"]=stage;failureContext["error"]=safeError(error)
   if let id=failureContext["windowID"] as? UInt32 {
    failureContext["windowStillListed"]=currentWindowTitle(id) != nil
    if let expected=arg("--expected-title") {
     failureContext["expectedTitleMatchedAtFailure"]=currentWindowTitle(id)?.localizedCaseInsensitiveContains(expected) ?? false
    }
   }
   if let sink=activeSink,let queue=activeQueue {
    queue.sync {
     sink.accepting=false
     failureContext["frames"]=sink.frames;failureContext["nonBlackFrames"]=sink.nonBlackFrames
     failureContext["writerStatus"]=sink.writer.status.rawValue
     failureContext["captureReason"]=sink.failure ?? "System operation failed"
     if let e=sink.failureError{failureContext["captureError"]=safeError(e)}
     if let e=sink.writer.error{failureContext["writerError"]=safeError(e)}
     if let first=sink.firstSampleUTC{failureContext["firstSampleUTC"]=utc(first)}
     if let last=sink.lastSampleUTC{failureContext["lastSampleUTC"]=utc(last)}
     if let first=sink.firstSamplePTS{failureContext["firstSamplePTSSeconds"]=first}
     if let last=sink.lastSamplePTS{failureContext["lastSamplePTSSeconds"]=last}
     if let first=sink.firstSamplePTS,let last=sink.lastSamplePTS{failureContext["sampleSpanSeconds"]=last-first}
    }
   }
   if let path=outputPath {
    failureContext["output"]=path
    failureContext["partialPreserved"]=FileManager.default.fileExists(atPath:path)
    if let attributes=try? FileManager.default.attributesOfItem(atPath:path){failureContext["outputBytes"]=attributes[.size]}
   }
   if let data=try? JSONSerialization.data(withJSONObject:failureContext,options:[.sortedKeys,.prettyPrinted]) {
    if let path=outputPath{try? data.write(to:URL(fileURLWithPath:path+".failure.json"),options:.atomic)}
    print(String(data:data,encoding:.utf8)!)
   }
   exit(1)
  }
 }
}
