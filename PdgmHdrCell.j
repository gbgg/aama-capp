var DISPLAY = 0; // pvals[DISPLAY] : BOOL
var VALUE = 1; // pvals[VALUE] : CPString
PdgmDragType       = @"PdgmDragType";

@implementation PdgmHdrCell : CPBox
{
  PdgmGridViewController pdgmGridVC @accessors;
  CPString hdr @accessors;
  CPString pname @accessors;
  CPString pval  @accessors;
  var prop @accessors;
  var pvals @accessors;
}

- (id)init
{
  self = [super init];
  [self registerForDraggedTypes:[CPArray arrayWithObjects:PdgmDragType]];
  return self;
}

- (id)initWithFrame:(CPRect)aFrame
{
  self = [super initWithFrame:aFrame];
  [self registerForDraggedTypes:[CPArray arrayWithObjects:PdgmDragType]];
  return self;
}

// - (void)mouseMoved:(CPEvent)anEvent
// {
//   // CPLog(@"%@ mouseMoved", self);
//     [_nextResponder performSelector:_cmd withObject:anEvent];
// }

// - (void)mouseEntered:(CPEvent)anEvent
// {
//   CPLog(@"%@ mouseEntered", self);
//     [_nextResponder performSelector:_cmd withObject:anEvent];
// }

/*!
    Notifies the receiver that the mouse exited the receiver's area.
    @param anEvent contains information about the exit
*/
- (void)mouseExited:(CPEvent)anEvent
{
  CPLog(@"%@ mouseExited", self);
    [_nextResponder performSelector:_cmd withObject:anEvent];
}

/*!
    Notifies the receiver that the user has clicked the mouse down in its area.
    @param anEvent contains information about the click
*/
// - (void)mouseDown:(CPEvent)anEvent
// {
//   CPLog(@"%@ mouseDown event %@", self, anEvent);
//   [super mouseDown:anEvent];
// }

/*!
    Notifies the receiver that the user has clicked the right mouse down in its area.
    @param anEvent contains information about the right click
*/
// - (void)rightMouseDown:(CPEvent)anEvent
// {
//     [_nextResponder performSelector:_cmd withObject:anEvent];
// }

// - (CPDragOperation)draggingEntered:(CPDraggingInfo>)sender
// {
//   CPLog(@"%@ draggingEntered event %@", self, anEvent);
// }

+ (CPMenu)defaultMenu
{
  CPLog(@"%@ defaultMenu", self);
  CPLog(@"    pname: %@, pval: %@", pname, pval);
  return nil;
}

- (CPMenu)menuForEvent:(CPEvent)theEvent
{
  CPLog(@"%@ menuForEvent %@", self, theEvent);
  CPLog(@"    window %@", [theEvent window]);

  var curLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  var magic_square = [self bounds]; //NSMakeRect(0.0, 0.0, 10.0, 10.0);
 
  // if ([self mouse:curLoc inRect:magic_square]) {
  // NSMenu *theMenu = [[self class] defaultMenu];
  // [theMenu insertItemWithTitle:@"Wail" action:@selector(wail:) keyEquivalent:@"" atIndex:[theMenu numberOfItems]-1];

  var ctxMenu = [[CPMenu alloc] initWithTitle:[self pval]];
  [ctxMenu setAutoenablesItems:NO];

  for (var iPval=0; iPval<[pvals count]; iPval++) {
    CPLog(@"    pval %@", iPval);
    var pval = [pvals objectAtIndex:iPval];
    mi = [[CPMenuItem alloc] initWithTitle:[pval objectAtIndex:VALUE] action:@selector(filterPval:) keyEquivalent:nil];
    [mi setTarget:pdgmGridVC];
    [mi setEnabled:YES];
    if ( [pval objectAtIndex:DISPLAY] ) {
      [mi setState:CPOnState];
    } else {
      [mi setState:CPOffState];
    }
    [mi setRepresentedObject:self];
    [ctxMenu addItem:mi];
  }
  return ctxMenu;
  // return [[self class] defaultMenu];
}


- (void)mouseDragged:(CPEvent)anEvent
{
  CPLog(@"%@ mouseDragged event %@", self, anEvent);

  var point = [self convertPoint:[anEvent locationInWindow] fromView:nil];

  if (point.x > [self bounds].size.width - 1 || point.x < 1)
    return NO;

  [[CPPasteboard pasteboardWithName:CPDragPboard] declareTypes:[CPArray arrayWithObject:PdgmDragType] owner:self];

  var bounds = CPRectMake(0,0,20,10); // [self bounds];
  var dragView = [[CPView alloc] initWithFrame: bounds],
    dragFillView = [[CPView alloc] initWithFrame:CGRectInset(bounds, 1.0, 1.0)];

  [dragView setBackgroundColor:[CPColor blackColor]];
  [dragFillView setBackgroundColor:[CPColor grayColor]];
  [dragView addSubview:dragFillView];

  [self dragView: dragView
	      at: CPPointMake(point.x - bounds.size.width / 2.0, point.y - bounds.size.height / 2.0)
	  offset: CPPointMake(0.0, 0.0)
	   event: anEvent
      pasteboard: nil
	  source: self
       slideBack: YES];
  CPLog(@"/%@ mouseDragged event %@", self);
}

- (void)pasteboard:(CPPasteboard)aPasteboard provideDataForType:(CPString)aType
{
  CPLog(@"%@ pasteboard %@ of type %@", self, aPasteboard, aType);

  if (aType == PdgmDragType)
    [aPasteboard setData:self
		 forType:aType];
}

- (void)performDragOperation:(id <CPDraggingInfo>)aSender
{
  var location = [self convertPoint:[aSender draggingLocation] fromView:nil],
    pasteboard = [aSender draggingPasteboard];

  if (![pasteboard availableTypeFromArray:[PdgmDragType]]
      || location.x > [self bounds].size.width - 1
      || location.x < 1)
    return NO;
  // do sth with the data
  var data = [pasteboard dataForType:PdgmDragType];
  if ( [data pname] == pname) {
    if ( [data pval] == pval ) return YES;
    CPLog(@"    reordering pvals %@ : %@ in header %@", [data pval], pval, hdr);
    [pdgmGridVC movePval:[data pval] toPval:pval inProp:[data pname] inHdr:hdr];
  } else {
    CPLog(@"    reordering prop from %@:%@ to %@:%@", [data pname], [data hdr], pname, hdr);
    [pdgmGridVC moveProp:[data pname] fromHdr:[data hdr] toProp:pname toHdr:hdr];
  }
  [pdgmGridVC sortPdgm];
  return YES;
}

@end

