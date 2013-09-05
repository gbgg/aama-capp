@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
// @import <AppKit/CPBrowser.j>

@import "MICPBrowser.j"
// @import "CPGeometry.j"

@import "MITableView.j"

@implementation MIBrowser : MICPBrowser
{
  CPView _docView;
}

- (id)initWithFrame:(CGRect)aFrame
{
  // CPLog(@"%@ initWithFrame", self);
  var b = [super initWithFrame:aFrame];
  // CPLog(@"MIBrowser initWithFrame 2");
  // [super setTableViewClass:CPClassFromString(@"MITableView")];
  [self setTableViewClass:[MITableView class]];
  // CPLog(@"MIBrowser initWithFrame 3");
  return b;
}

- (CPView)contentView
{
  // CPLog(@"MIBrowser.contentView %@", _contentView);
  return _contentView;
}

- (void)mouseDown:(CPEvent)anEvent
{
  CPLog(@"%@ mouseDown", self);
  [super mouseDown:anEvent];
}



- (void)keyDown:(CPEvent)theEvent
{
  CPLog(@"%@ keyDown", self);
  [super keyDown:theEvent];
}

@end

