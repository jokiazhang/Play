/*
 *  $Id$
 *
 *  Copyright (C) 2006 Stephen F. Booth <me@sbooth.org>
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

#import "AudioMetadataWriter.h"
#import "FLACMetadataWriter.h"
#import "OggFLACMetadataWriter.h"
#import "OggVorbisMetadataWriter.h"
//#import "MusepackMetadataWriter.h"
#import "MP3MetadataWriter.h"
//#import "MP4MetadataWriter.h"
//#import "WavPackMetadataWriter.h"
//#import "MonkeysAudioMetadataWriter.h"

#import "UtilityFunctions.h"

NSString *const AudioMetadataWriterErrorDomain = @"org.sbooth.Play.ErrorDomain.AudioMetadataWriter";

@implementation AudioMetadataWriter

+ (AudioMetadataWriter *) metadataWriterForURL:(NSURL *)url error:(NSError **)error
{
	NSParameterAssert(nil != url);
	NSParameterAssert([url isFileURL]);
	
	AudioMetadataWriter				*result;
	NSString						*path;
	NSString						*pathExtension;
	
	path							= [url path];
	pathExtension					= [[path pathExtension] lowercaseString];
	
	if([pathExtension isEqualToString:@"flac"]) {
		result						= [[FLACMetadataWriter alloc] init];
		
		[result setValue:url forKey:@"url"];
	}
	// Determine the content type of the ogg stream
	else if([pathExtension isEqualToString:@"ogg"]) {
		OggStreamType			type		= oggStreamType(url);

		if(kOggStreamTypeInvalid == type || kOggStreamTypeUnknown == type || kOggStreamTypeSpeex == type) {

			if(nil != error) {
				NSMutableDictionary		*errorDictionary	= [NSMutableDictionary dictionary];
				
				switch(type) {
					case kOggStreamTypeInvalid:
						[errorDictionary setObject:[NSString stringWithFormat:@"The file \"%@\" is not a valid Ogg stream.", [path lastPathComponent]] forKey:NSLocalizedDescriptionKey];
						[errorDictionary setObject:@"Not an Ogg stream" forKey:NSLocalizedFailureReasonErrorKey];
						[errorDictionary setObject:@"The file's extension may not match the file's type." forKey:NSLocalizedRecoverySuggestionErrorKey];						
						break;
						
					case kOggStreamTypeUnknown:
						[errorDictionary setObject:[NSString stringWithFormat:@"The type of Ogg stream in the file \"%@\" could not be determined.", [path lastPathComponent]] forKey:NSLocalizedDescriptionKey];
						[errorDictionary setObject:@"Unknown Ogg stream type" forKey:NSLocalizedFailureReasonErrorKey];
						[errorDictionary setObject:@"This data format is not supported for the Ogg container." forKey:NSLocalizedRecoverySuggestionErrorKey];						
						break;
						
					default:
						[errorDictionary setObject:[NSString stringWithFormat:@"The file \"%@\" is not a valid Ogg stream.", [path lastPathComponent]] forKey:NSLocalizedDescriptionKey];
						[errorDictionary setObject:@"Not an Ogg stream" forKey:NSLocalizedFailureReasonErrorKey];
						[errorDictionary setObject:@"The file's extension may not match the file's type." forKey:NSLocalizedRecoverySuggestionErrorKey];						
						break;
				}
				
				*error					= [NSError errorWithDomain:AudioMetadataWriterErrorDomain 
															  code:AudioMetadataWriterFileFormatNotRecognizedError 
														  userInfo:errorDictionary];
			}
			
			return nil;
		}
		
		switch(type) {
			case kOggStreamTypeVorbis:		result = [[OggVorbisMetadataWriter alloc] init];			break;
			case kOggStreamTypeFLAC:		result = [[OggFLACMetadataWriter alloc] init];				break;
//			case kOggStreamTypeSpeex:		result = [[AudioMetadataWriter alloc] init];				break;
			default:						result = [[AudioMetadataWriter alloc] init];				break;
		}

		[result setValue:url forKey:@"url"];
	}/*
	else if([pathExtension isEqualToString:@"mpc"]) {
		result						= [[MusepackMetadataWriter alloc] init];
		
		[result setValue:url forKey:@"url"];
	}*/
	else if([pathExtension isEqualToString:@"mp3"]) {
		result						= [[MP3MetadataWriter alloc] init];
		
		[result setValue:url forKey:@"url"];
	}/*
	else if([pathExtension isEqualToString:@"mp4"] || [pathExtension isEqualToString:@"m4a"]) {
		result						= [[MP4MetadataWriter alloc] init];
		
		[result setValue:url forKey:@"url"];
	}
	else if([pathExtension isEqualToString:@"wv"]) {
		result						= [[WavPackMetadataWriter alloc] init];
		
		[result setValue:url forKey:@"url"];
	}
	else if([pathExtension isEqualToString:@"ape"]) {
		result						= [[MonkeysAudioMetadataWriter alloc] init];
		
		[result setValue:url forKey:@"url"];
	}*/
	else {
/*		if(nil != error) {
			NSMutableDictionary		*errorDictionary;
			
			errorDictionary			= [NSMutableDictionary dictionary];
			
			[errorDictionary setObject:[NSString stringWithFormat:@"The format of the file \"%@\" was not recognized.", [path lastPathComponent]] forKey:NSLocalizedDescriptionKey];
			[errorDictionary setObject:@"File Format Not Recognized" forKey:NSLocalizedFailureReasonErrorKey];
			[errorDictionary setObject:@"The file's extension may not match the file's type." forKey:NSLocalizedRecoverySuggestionErrorKey];
			
			*error					= [NSError errorWithDomain:AudioMetadataWriterErrorDomain 
														  code:AudioMetadataWriterFileFormatNotRecognizedError 
													  userInfo:errorDictionary];
		}*/
		
		result						= nil;
	}
	
	return [result autorelease];
}

- (BOOL)			writeMetadata:(id)metadata error:(NSError **)error			{ return NO; }

@end
