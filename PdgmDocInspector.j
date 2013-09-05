
/*
 * 
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation PdgmDocInspector : CPWindow
{
  CPDocument idoc @accessors;
  CPObject coObject @accessors;
  SEL coProperty @accessors;
  SEL prop @accessors;
  CPCheckBox cbxReloadFlag;
  BOOL reloadFlag @accessors;
  CPString query @accessors;
  LPMultiLineTextField txtQuery;
}

-(CPString)query
{
  // CPLog(@"PdgmDocInspector.query:\n%@", query);
  return query;
}

-(id)init
{
  CPLog(@"PdgmDocInspector init");
  [super init];
  return self;
}

/*
 *
 */
-(id)initWithDoc:(CPDocument)theDoc
{
  CPLog(@"%@: initWithDoc: %@", self, theDoc);
  [self setIdoc:theDoc];
  var x = 20,
    y = 100,
    w = 500,
    h = 400;
  
  [super initWithContentRect:CGRectMake(x, y, w, h)
		   styleMask:CPDocModalWindowMask | CPResizableWindowMask];
  CPLog(@"    ....2");
  [[super contentView] setBackgroundColor:[CPColor colorWithHexString:@"DADADA"]];
  // [super setDelegate:self];
  CPLog(@"    ....3");
  var contentView = [super contentView];

  CPLog(@"    ....4");
  var boxQuery= [[CPBox alloc] initWithFrame: CGRectMake(10, 10, w-20, h-50)];
  [boxQuery setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [[boxQuery contentView] setBackgroundColor:[CPColor colorWithHexString:@"FFFFFF"]];
  [boxQuery setBorderType:CPBezelBorder];
  [contentView addSubview:boxQuery];
  
  var txtQuery = [[LPMultiLineTextField alloc] initWithFrame: CGRectInset([boxQuery bounds], 5, 5)];
  [txtQuery setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  [txtQuery setDelegate:[[self idoc] doclet]];
  [txtQuery setEditable:YES];
  [txtQuery setStringValue:[[idoc doclet] query]];

  [[boxQuery contentView] addSubview:txtQuery];

  var boxControls = [[CPBox alloc] initWithFrame: CGRectMake(10, h-40, w-20, 32)];
  [boxControls setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  // [[boxControls contentView] setBackgroundColor:[CPColor colorWithHexString:@"FF8888"]];
  [contentView addSubview:boxControls];

  cbxReloadFlag = [CPCheckBox buttonWithTitle:@"Reload data?"];
  [cbxReloadFlag setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
  [cbxReloadFlag setFrameOrigin:CGPointMake(w-300, 5)];
  [cbxReloadFlag setObjectValue:CPOnState];
  
  [[boxControls contentView] addSubview:cbxReloadFlag];
    
  btnCancel = [[CPButton alloc] initWithFrame:CGRectMake(w-200, 5, 80, 24)];
  [btnCancel setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
  [btnCancel setTitle:"Cancel"];
  [btnCancel setBezelStyle:CPRoundedBezelStyle];
  [btnCancel setAction:@selector(cancelInspection:)];
  [btnCancel setTarget:self];
  [[boxControls contentView] addSubview:btnCancel];

  var btnOK = [[CPButton alloc] initWithFrame:CGRectMake(w-100, 5, 80, 24)];
  [btnOK setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];
  [btnOK setTitle:"OK"];
  [btnOK setBezelStyle:CPRoundedBezelStyle];
  [btnOK setAction:@selector(approveInspection:)];
  [btnOK setTarget:self];
  [[boxControls contentView] addSubview:btnOK];
  
  [super setDefaultButtonCell:btnOK];
  [super makeFirstResponder:btnOK];
  [super setDelegate:self];
  // CPLog(@"%@: propsheet first responder: %@", self, [super firstResponder]);
  // CPLog(@"%@: propsheet responder: %@", self, [[super firstResponder] nextResponder]);

  [self makeKeyWindow];
  CPLog(@"/%@: initWithDoc: %@", self, theDoc);
  return self;
}

// - (CFAction)showDocPropertySheet:(id)sender
// {
//   CPLog(@"PdgmDocInspector:showDocPropertySheet");
//   var mainWin = [super window];
//   CPLog(@"mainWin: " + mainWin);
//   [mainWin orderFront:self];
//   var queryInfo;
//   // if (!_pdgmPropertySheet) {
//     _pdgmPropertySheet = [self makePropertySheet:nil forNewDoc:NO];
//   // } else {
//   //   [_pdgmPropertySheet forNewDoc:NO];
//   // }
//   [CPApp beginSheet: _pdgmPropertySheet
//      modalForWindow: mainWin
//       modalDelegate: self
//      didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
// 	contextInfo: CPString];
// }


- (void)showDocPropertySheetForType:(CPString)docType
{
  CPLog(@"%@: showDocPropertySheetForType %@", self, docType);
  [CPApp beginSheet: self
     modalForWindow: [CPApp mainWindow]
      modalDelegate: self
     didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
	contextInfo: CPString];
  CPLog(@"/%@: showDocPropertySheetForType %@", self, docType);
}

- (void)didEndSheet:(CPWindow)theSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
  CPLog(@"%@/: didEndSheet", self);
  [self orderOut:self];
  // [CPApp endSheet:self];
}

- (CFAction)cancelInspection:(id)sender
{
  CPLog(@"%@ cancelInspection action", self);
  [CPApp endSheet:self];
  // notifiy any pending NEW docs so they can close
  [[CPNotificationCenter defaultCenter]
        postNotificationName:@"InspectorDidCancelNotification" object:nil];
}

- (CFAction)approveInspection:(id)sender
{
  CPLog(@"%@: approveInspection action", self);
  var qry = [txtQuery stringValue];
  // CPLog(@" query: %@", qry);
  // CPLog(@"    ....document:%@; doclet:%@", idoc, [idoc doclet]);
  [[idoc doclet] setQuery:qry];
  // CPLog(@"    ....content:\n" + [[idoc doclet] query]);
  [idoc setReloadFlag:[cbxReloadFlag objectValue]];
  // CPLog(@"PdgmDocInspector: reloadFlag: %@", [[idoc doclet] reloadFlag]);
  [[CPNotificationCenter defaultCenter]
        postNotificationName:@"InspectorDidAcceptNotification" object:idoc];
  [CPApp endSheet:self];
  CPLog(@"/%@: approveInspection", self);
}

- (void)setCoObject:(id)theObject
{
  CPLog(@"setCoObject");
  coObject = theObject;
}

- (void)setCoObjectSetter:(SEL)theCoProperty forObjectGetter:(SEL)theProperty
{
  CPLog(@"setCoObjectSetter %@, ObjGetter %@", theCoProperty, theProperty);
  [self setCoProperty:theCoProperty];
  [self setProp:theProperty];
}

- (CFAction)performDelete:(id)sender
{
  CPLog(@"PdgmDocInspector: delete");
}

@end
