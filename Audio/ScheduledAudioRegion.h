/*
 *  $Id$
 *
 *  Copyright (C) 2007 Stephen F. Booth <me@sbooth.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import <Cocoa/Cocoa.h>

#include <AudioToolbox/AudioToolbox.h>

@class AudioDecoder;

// This class is a bit of an amalgam- it contains all the logic for accessing a subrange of 
// audio from a Decoder, but also the buffers and associated internal state that 
// AudioScheduler needs to use an object of this class.
@interface ScheduledAudioRegion : NSObject
{
	AudioDecoder			*_decoder;
	AudioTimeStamp			_startTime;
	SInt64					_startingFrame;
	UInt32					_framesToPlay;
	unsigned				_loopCount;
	
	UInt32					_framesReadInCurrentLoop;
	SInt64					_totalFramesRead;
	unsigned				_completedLoops;

	BOOL					_atEnd;
	
	// ========================================
	// AudioScheduler members
	ScheduledAudioSlice		*_sliceBuffer;

	unsigned				_numberSlices;
	unsigned				_framesPerSlice;

	SInt64					_framesScheduled;
	SInt64					_framesRendered;
}	

// ========================================
// Creation
// ========================================
+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder;

+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder startingFrame:(SInt64)startingFrame;
+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder startingFrame:(SInt64)startingFrame framesToPlay:(unsigned)framesToPlay;
+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder startingFrame:(SInt64)startingFrame framesToPlay:(unsigned)framesToPlay loopCount:(unsigned)loopCount;

+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder startTime:(AudioTimeStamp)startTime;
+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder startTime:(AudioTimeStamp)startTime startingFrame:(SInt64)startingFrame;
+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder startTime:(AudioTimeStamp)startTime startingFrame:(SInt64)startingFrame framesToPlay:(unsigned)framesToPlay;
+ (ScheduledAudioRegion *) scheduledAudioRegionForDecoder:(AudioDecoder *)decoder startTime:(AudioTimeStamp)startTime startingFrame:(SInt64)startingFrame framesToPlay:(unsigned)framesToPlay loopCount:(unsigned)loopCount;

// ========================================
// Properties
// ========================================
- (AudioDecoder *) decoder;
- (void) setDecoder:(AudioDecoder *)decoder;

- (AudioTimeStamp) startTime;
- (void) setStartTime:(AudioTimeStamp)startTime;

- (SInt64) startingFrame;
- (void) setStartingFrame:(SInt64)startingFrame;

- (UInt32) framesToPlay;
- (void) setFramesToPlay:(UInt32)fframesToPlay;

- (unsigned) loopCount;
- (void) setLoopCount:(unsigned)loopCount;

// ========================================
// Audio access
// ========================================
- (unsigned) completedLoops;

- (SInt64) totalFrames;
- (SInt64) currentFrame;
- (SInt64) framesRemaining;

- (BOOL) supportsSeeking;
- (SInt64) seekToFrame:(SInt64)frame;

- (SInt64) framesScheduled;
- (SInt64) framesRendered;

@end

// ========================================
// AudioScheduler methods
// ========================================
@interface ScheduledAudioRegion (AudioSchedulerMethods)
- (unsigned) numberOfSlicesInBuffer;
- (unsigned) numberOfFramesPerSlice;

- (void) allocateBuffersWithSliceCount:(unsigned)sliceCount frameCount:(unsigned)frameCount;
- (void) clearSliceBuffer;
- (void) clearSlice:(unsigned)sliceIndex;

- (void) reset;

- (void) clearFramesScheduled;
- (void) clearFramesRendered;

- (UInt32) readAudio:(AudioBufferList *)bufferList frameCount:(UInt32)frameCount;
- (UInt32) readAudioInSlice:(unsigned)sliceIndex;

- (ScheduledAudioSlice *) buffer;
- (ScheduledAudioSlice *) sliceAtIndex:(unsigned)sliceIndex;

- (void) scheduledAdditionalFrames:(UInt32)frameCount;
- (void) renderedAdditionalFrames:(UInt32)frameCount;

- (BOOL) atEnd;
@end