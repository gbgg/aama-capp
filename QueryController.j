/*
 *
 */

@import <Foundation/CPObject.j>

@implementation QueryController : CPObject
{
  // NSApplication appAama;
  // @outlet CPPlatformWindow mainWindow;
  // @outlet CPWindow pnlNewPdgm;
}

- (id)init
{
  [super init];
  CPLog(@"ctlr init");
  return self;
}

- (IBAction) newQuery:(id)sender
{
  CPLog("newQuery");	
  // [CPApp beginSheet: pnlNewPdgm
  //    modalForWindow: mainWindow
  //     modalDelegate: self
  //    didEndSelector: @selector(didEndSheet:returnCode:)
  // 	contextInfo: nil];
}

- (IBAction) openQuery:(id)sender
{
  var alert = [[CPAlert alloc] init];
  [alert setDelegate:self];
  
  [alert addButtonWithTitle:@"OK"];
  [alert addButtonWithTitle:@"Cancel"];
//  [alert setMessageText:@"Open query?"];
  [alert setMessageText:@"This creates a query that will yield a paradigm display."];
  [alert setAlertStyle:CPInformationalAlertStyle];

  //  [alert beginSheetModalForWindow:[searchField window]
  [alert runModal];
}

- (IBAction) submitQuery:(id)sender
{
  var alert = [[CPAlert alloc] init];
  [alert setDelegate:self];
  
  [alert addButtonWithTitle:@"OK"];
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:@"Open query?"];
  // [alert setInformativeText:@"This creates a query that will yield a paradigm display."];
  [alert setAlertStyle:CPInformationalAlertStyle];

  //  [alert beginSheetModalForWindow:[searchField window]
  [alert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode { // contextInfo:(void)contextInfo {
  switch (returnCode) {
  case  0: alert("OK"); break;
  case  1: alert("Cancel");break;
  default: alert("huh?");
  }
}

- (void)didEndSheet:(CPAlert)theAlert returnCode:(int)returnCode { // contextInfo:(void)contextInfo {
  CPLog(@"didEndSheet");
  [pnlNewPdgm orderOut:self];
  }
}


- (IBAction) closeSheet:(id)sender
{
  CPLog(@"close dialog");
  [CPApp endSheet:pnlNewPdgm];
}


- (IBAction) submitQuery:(id)sender
{
  CPLog(@"submit");
  [CPApp endSheet:pnlNewPdgm];
}

@end
