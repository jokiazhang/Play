/*
 *  $Id$
 *
 *  Copyright (C) 2006 - 2007 Stephen F. Booth <me@sbooth.org>
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

#import "RecentlyPlayedNode.h"
#import "AudioLibrary.h"
#import "CollectionManager.h"
#import "AudioStreamManager.h"
#import "AudioStream.h"

@interface AudioStreamCollectionNode (Private)
- (NSMutableArray *) streamsArray;
@end

@interface RecentlyPlayedNode (Private)
- (void) streamRemoved:(NSNotification *)aNotification;
@end

@implementation RecentlyPlayedNode

- (id) init
{
	if((self = [super initWithName:NSLocalizedStringFromTable(@"Recently Played", @"Library", @"")])) {
		_count = 25;

		[[[CollectionManager manager] streamManager] addObserver:self 
													  forKeyPath:StatisticsLastPlayedDateKey
														 options:0
														 context:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(streamRemoved:) 
													 name:AudioStreamRemovedFromLibraryNotification
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(streamRemoved:) 
													 name:AudioStreamsRemovedFromLibraryNotification
												   object:nil];
		
	}
	return self;
}

- (void) dealloc
{
	[[[CollectionManager manager] streamManager] removeObserver:self forKeyPath:StatisticsLastPlayedDateKey];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self refreshStreams];
}

- (BOOL) streamsAreOrdered			{ return YES; }
- (BOOL) streamReorderingAllowed	{ return NO; }

- (void) loadStreams
{
	NSPredicate			*predicate			= [NSPredicate predicateWithFormat:@"%K != nil", StatisticsLastPlayedDateKey];
	NSSortDescriptor	*descriptor			= [[NSSortDescriptor alloc] initWithKey:StatisticsLastPlayedDateKey ascending:NO];
	NSArray				*allStreams			= [[[CollectionManager manager] streamManager] streams];
	NSArray				*sortedStreams		= [allStreams sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	NSArray				*filteredStreams	= [sortedStreams filteredArrayUsingPredicate:predicate];	
	unsigned			count				= (_count > [filteredStreams count] ? [filteredStreams count] : _count);
	
	[self willChangeValueForKey:@"streams"];
	[[self streamsArray] replaceObjectsInRange:NSMakeRange(0, [[self streamsArray] count]) withObjectsFromArray:filteredStreams range:NSMakeRange(0, count)];
	[self didChangeValueForKey:@"streams"];
	
	[descriptor release];
}

- (void) refreshStreams
{
	NSPredicate			*predicate			= [NSPredicate predicateWithFormat:@"%K != nil", StatisticsLastPlayedDateKey];
	NSSortDescriptor	*descriptor			= [[NSSortDescriptor alloc] initWithKey:StatisticsLastPlayedDateKey ascending:NO];
	NSArray				*allStreams			= [[[CollectionManager manager] streamManager] streams];
	NSArray				*sortedStreams		= [allStreams sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	NSArray				*filteredStreams	= [sortedStreams filteredArrayUsingPredicate:predicate];
	unsigned			count				= (_count > [filteredStreams count] ? [filteredStreams count] : _count);
	
	[self willChangeValueForKey:@"streams"];
	[[self streamsArray] replaceObjectsInRange:NSMakeRange(0, [[self streamsArray] count]) withObjectsFromArray:filteredStreams range:NSMakeRange(0, count)];
	[self didChangeValueForKey:@"streams"];

	[descriptor release];
}

#pragma mark KVC Mutator Overrides

- (void) insertObject:(AudioStream *)stream inStreamsAtIndex:(unsigned)index
{}

- (void) removeObjectFromStreamsAtIndex:(unsigned)index
{
	NSAssert([self canRemoveStream], @"Attempt to remove a stream from an immutable RecentlyPlayedNode");	
	AudioStream *stream = [[self streamsArray] objectAtIndex:index];
	
	if([stream isPlaying]) {
		[[AudioLibrary library] stop:self];
	}
	
	[stream delete];
	[[self streamsArray] removeObjectAtIndex:index];
}

@end

@implementation RecentlyPlayedNode (Private)

- (void) streamRemoved:(NSNotification *)aNotification
{
	[self refreshStreams];
}

@end
