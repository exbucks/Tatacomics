//
//  TLayer.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTataDelegate.h"

@class TDocument;
@class TScene;
@class TActor;
@class SMXMLElement;

@interface TLayer : CALayer

@property (weak) TDocument*         document;
@property (copy) NSString*          name;
@property (weak) TLayer*            parent;

@property (assign) BOOL             locked;

@property (assign) float            alpha;

@property (strong) NSMutableArray*  childs;
@property (strong) NSMutableArray*  animations;

@property (strong) NSMutableArray*  events;
@property (strong) NSMutableArray*  states;

@property (copy) NSString*          run_state;
@property (assign) BOOL             run_enabled;

- (id)initWithDocument:(TDocument*)document;
- (id)initWithDocument:(TDocument*)document parent:(TLayer*)parentLayer name:(NSString*)layerName;

- (TLayer*)clone;
- (void)clone:(TLayer*)target;

- (BOOL)parseXml:(SMXMLElement*)xml parent:(TLayer*)parent;
- (SMXMLElement*)toXml;

- (void)fixRelationship;
- (void)refresh;
- (void)updateContents;

- (int)newLayerNameSuffixWithPrefix:(NSString*)prefix;
- (NSString*)newLayerNameWithPrefix:(NSString*)prefix;

- (void)addChild:(TLayer*)child;
- (NSArray*)sortedChilds;
- (NSArray*)getAllChilds;
- (TLayer*)findLayer:(NSString*)name;
- (TScene*)ownerScene;

- (CGPoint)screenToLogical:(CGPoint)point;
- (CGPoint)screenVectorToLogical:(CGPoint)vector;
- (CGPoint)logicalToScreen:(CGPoint)point;
- (CGPoint)logicalVectorToScreen:(CGPoint)vector;
- (CGRect)bound;
- (NSArray*)boundOnScreen;
- (CGRect)boundStraightOnScreen;

- (TActor*)actorAtScreenPosition:(CGPoint)pos withinInteraction:(BOOL)withinInteraction;

- (BOOL)isUsingImage:(NSString*)image;
- (BOOL)isUsingSound:(NSString*)sound;

- (NSArray*)getDefaultEvents;
- (NSArray*)getEvents;
- (BOOL)addEvent:(NSString*)event;
- (BOOL)isDefaultEvent:(NSString*)event;
- (void)renameEvent:(NSString*)event newEvent:(NSString*)newEvent;
- (BOOL)deleteEvent:(NSString*)event;

- (NSArray*)getDefaultStates;
- (NSArray*)getStates;
- (BOOL)addState:(NSString*)state;
- (BOOL)isDefaultState:(NSString*)state;
- (void)renameState:(NSString*)state newState:(NSString*)newState;
- (BOOL)deleteState:(NSString*)state;

- (void)fireEvent:(NSString*)event recursive:(BOOL)recursive;
- (void)startAnimation:(NSString*)event;
- (void)stopAnimation:(NSString*)event state:(NSString*)state;
- (void)step:(id<TTataDelegate>)delegate time:(long long)time;

@end
