@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation AamaMenu: CPObject
{
  CPMenu mainMenu;
}

- (id) init
{
  // CPLog(@"%@ init", self);

  mainMenu = [CPMenu new];

  [mainMenu setAutoenablesItems:NO];

  var bundle = [CPBundle bundleForClass:[CPApplication class]];

  var AamaMenuItem = [[CPMenuItem alloc] initWithTitle:@"AAMA" action:nil keyEquivalent:nil];
  var bfont = [CPFont boldFontWithName:@"Arial" size:14];
  [AamaMenuItem setFont:bfont];
  var AamaMenu = [[CPMenu alloc] initWithTitle:@"Aama"];
  [AamaMenu addItem:[[CPMenuItem alloc]
		      initWithTitle:@"About"
			     action:@selector(orderFrontStandardAboutPanel:)
		      keyEquivalent:@"x"]];
  [AamaMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Preferences" action:@selector(prefs:) keyEquivalent:@"p"]];
  [AamaMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Clear Caches" action:@selector(clearCache:)  keyEquivalent:@""]];
  [AamaMenu addItem:[CPMenuItem separatorItem]];
  [AamaMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@"v"]];
  [AamaMenuItem setSubmenu:AamaMenu];
  [mainMenu addItem:AamaMenuItem];

  var fileMenuItem = [[CPMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:nil];
  var fileMenu = [[CPMenu alloc] initWithTitle:@"File"];

  var newMenuItem = [[CPMenuItem alloc] initWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:nil];
  var newMenu = [[CPMenu alloc] initWithTitle:@"New"];
  [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Folder" action:@selector(newFolder:) keyEquivalent:@"F"]],
  [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Paradigm" action:@selector(newPdgmDocument:) keyEquivalent:@"P"]],
    // [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Script" action:@selector(newWSysDocument:) keyEquivalent:@"S"]],
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Paradigm Browser" action:@selector(newCatalogManager:) keyEquivalent:@"B"]],
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Property Inspector"
						action:@selector(newMorphPropertyInspector:)
					 keyEquivalent:@"I"]];
    [newMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Schema Inspector"
						action:@selector(newSchemaInspector:)
					 keyEquivalent:@"I"]];

  [newMenuItem  setSubmenu:newMenu];
  [fileMenu addItem:newMenuItem];

  var openMenuItem = [[CPMenuItem alloc] initWithTitle:@"Open" action:@selector(openDocument:) keyEquivalent:@"o"];
  // [openMenuItem setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPApplication/Open.png"] size:CGSizeMake(16.0, 16.0)]];
  // [openMenuItem setAlternateImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPApplication/OpenHighlighted.png"] size:CGSizeMake(16.0, 16.0)]];

  [fileMenu addItem:openMenuItem];
  [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Open Recent" action:@selector(openRecent:) keyEquivalent:nil]],
    [fileMenu addItem:[CPMenuItem separatorItem]];

  var closeMenuItem = [[CPMenuItem alloc] initWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
  [closeMenuItem setKeyEquivalentModifierMask:CPControlKeyMask];
  [fileMenu addItem:closeMenuItem];
  
  [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Close All" action:@selector(closeAllDocuments:) keyEquivalent:nil]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save" action:@selector(performSave:) keyEquivalent:"s"]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save As..." action:@selector(saveDocumentAs:) keyEquivalent:nil]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save All" action:@selector(saveAllDocuments:) keyEquivalent:nil]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Revert to Saved" action:@selector(revertDocumentToSaved:)
					  keyEquivalent:nil]],
    [fileMenu addItem:[CPMenuItem separatorItem]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Move to Trash" action:@selector(removeDocument:) keyEquivalent:nil]],
    [fileMenu addItem:[CPMenuItem separatorItem]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Import" action:@selector(import:) keyEquivalent:nil]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Export" action:@selector(export:) keyEquivalent:nil]],
    [fileMenu addItem:[CPMenuItem separatorItem]];

  var propsMenuItem = [[CPMenuItem alloc] initWithTitle:@"Show Properties" action:@selector(showDocPropertySheet:) keyEquivalent:@","];
  [propsMenuItem setKeyEquivalentModifierMask:CPControlKeyMask];
  [fileMenu addItem:propsMenuItem];

    [fileMenu addItem:[CPMenuItem separatorItem]],
    [fileMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Print" action:@selector(printDocument:) keyEquivalent:nil]];

  [fileMenuItem setSubmenu:fileMenu];
  [fileMenuItem setHidden:NO];
  
  // var saveMenuItem = [[CPMenuItem alloc] initWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:nil];

  // [saveMenuItem setImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPApplication/Save.png"] size:CGSizeMake(16.0, 16.0)]];
  // [saveMenuItem setAlternateImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPApplication/SaveHighlighted.png"] size:CGSizeMake(16.0, 16.0)]];


  // var saveMenu = [[CPMenu alloc] initWithTitle:@"Save"];
  // [saveMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s"]];
  // [saveMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Save As" action:@selector(saveDocumentAs:) keyEquivalent:nil];

  // [saveMenuItem setSubmenu:saveMenu];

  // [fileMenu addItem:saveMenuItem];

  [mainMenu addItem:fileMenuItem];

  var editMenuItem = [[CPMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:nil];
  var editMenu = [[CPMenu alloc] initWithTitle:@"Edit"],
    undoMenuItem = [[CPMenuItem alloc] initWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:CPUndoKeyEquivalent],
    redoMenuItem = [[CPMenuItem alloc] initWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:CPRedoKeyEquivalent];

  [undoMenuItem setKeyEquivalentModifierMask:CPUndoKeyEquivalentModifierMask];
  [redoMenuItem setKeyEquivalentModifierMask:CPRedoKeyEquivalentModifierMask];

  [editMenu addItem:undoMenuItem];
  [editMenu addItem:redoMenuItem];

  [editMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:nil]],
    [editMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:nil]],
    [editMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:nil]];

  [editMenuItem setSubmenu:editMenu];
  [editMenuItem setHidden:NO];

  [mainMenu addItem:editMenuItem];

  var formatMenuItem = [[CPMenuItem alloc] initWithTitle:@"Format" action:nil keyEquivalent:nil];
  var formatMenu = [[CPMenu alloc] initWithTitle:@"Format"];
  [formatMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Font" action:@selector(cut:) keyEquivalent:nil]];
  [formatMenuItem setSubmenu:formatMenu];
  [mainMenu addItem:formatMenuItem];

  var favsMenuItem = [[CPMenuItem alloc] initWithTitle:@"Favorites" action:nil keyEquivalent:nil];
  var favsMenu = [[CPMenu alloc] initWithTitle:@"Favorites"];
  [favsMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Add to Favorites" action:@selector(cut:) keyEquivalent:nil]];
  [favsMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Edit Favorites" action:@selector(cut:) keyEquivalent:nil]];
  [favsMenu addItem:[CPMenuItem separatorItem]];
  [favsMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Afar" action:@selector(cut:) keyEquivalent:nil]];
  [favsMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Coptic" action:@selector(cut:) keyEquivalent:nil]];
  [favsMenuItem setSubmenu:favsMenu];
  [mainMenu addItem:favsMenuItem];

  var windowMenuItem = [[CPMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:nil];
  var windowMenu = [[CPMenu alloc] initWithTitle:@"Window"];
  [windowMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Minimize" action:@selector(miniaturize:) keyEquivalent:@"M"]],
    [windowMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Maximize" action:@selector(maximize:) keyEquivalent:@"Z"]],
    [windowMenu addItem:[CPMenuItem separatorItem]],
    [windowMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Cascade" action:@selector(cascade:) keyEquivalent:nil]],
    [windowMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Tile" action:@selector(tile:) keyEquivalent:nil]],
    [windowMenu addItem:[CPMenuItem separatorItem]],
  [windowMenuItem setSubmenu:windowMenu];
  [mainMenu addItem:windowMenuItem];

  var helpMenuItem = [[CPMenuItem alloc] initWithTitle:@"Help" action:nil keyEquivalent:nil];
  var helpMenu = [[CPMenu alloc] initWithTitle:@"Help"];
  [helpMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Search" action:@selector(search:) keyEquivalent:nil]],
    [helpMenu addItem:[[CPMenuItem alloc] initWithTitle:@"Report Bug" action:@selector(bug:) keyEquivalent:nil]],
    [helpMenu addItem:[[CPMenuItem alloc] initWithTitle:@"AAMA Help" action:@selector(help:) keyEquivalent:nil]];
  [helpMenuItem setSubmenu:helpMenu];
  [mainMenu addItem:helpMenuItem];

  // CPLog(@"%@ init", self);
  return mainMenu;
}

@end
