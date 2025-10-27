#import <Cocoa/Cocoa.h>

@interface ClockView : NSView
@end

@implementation ClockView {
    NSTimer *_timer;
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}

- (void)timerFired:(NSTimer *)timer {
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSRect bounds = self.bounds;

    // Use the smaller of width/height so the clock stays perfectly round
    CGFloat side = MIN(bounds.size.width, bounds.size.height);
    NSPoint center = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
    CGFloat radius = side / 2 - 10;

    // Background
    [[NSColor whiteColor] setFill];
    NSRect circleRect = NSMakeRect(center.x - radius, center.y - radius, radius * 2, radius * 2);
    [[NSBezierPath bezierPathWithOvalInRect:circleRect] fill];

    // Black rim
    [[NSColor blackColor] setStroke];
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:circleRect];
    circlePath.lineWidth = MAX(1, radius * 0.05); //
    [circlePath stroke];

    //
    CGFloat longTickLength = radius * 0.12;
    CGFloat shortTickLength = radius * 0.06;
    CGFloat longTickWidth = MAX(1, radius * 0.015);
    CGFloat shortTickWidth = MAX(0.5, radius * 0.008);

    [[NSColor blackColor] setStroke];
    for (int i = 0; i < 60; i++) {
        CGFloat angle = M_PI_2 - (2 * M_PI * (i / 60.0));
        CGFloat tickLength = (i % 5 == 0) ? longTickLength : shortTickLength;
        CGFloat lineWidth = (i % 5 == 0) ? longTickWidth : shortTickWidth;

        CGFloat innerRadius = radius - tickLength;
        CGFloat outerRadius = radius;

        NSPoint startPoint = NSMakePoint(center.x + innerRadius * cos(angle),
                                         center.y + innerRadius * sin(angle));
        NSPoint endPoint = NSMakePoint(center.x + outerRadius * cos(angle),
                                       center.y + outerRadius * sin(angle));

        NSBezierPath *tickPath = [NSBezierPath bezierPath];
        tickPath.lineWidth = lineWidth;
        [tickPath moveToPoint:startPoint];
        [tickPath lineToPoint:endPoint];
        [tickPath stroke];
    }

    //
    CGFloat numberRadius = radius - longTickLength - radius * 0.1;
    CGFloat fontSize = MAX(10, radius * 0.15);
    NSDictionary *attrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:fontSize weight:NSFontWeightMedium],
        NSForegroundColorAttributeName: [NSColor blackColor]
    };
    NSArray<NSString *> *numbers = @[@"12", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11"];
    for (int i = 0; i < 12; i++) {
        CGFloat angle = M_PI_2 - (2 * M_PI * (i / 12.0));
        NSPoint textCenter = NSMakePoint(center.x + numberRadius * cos(angle),
                                         center.y + numberRadius * sin(angle));
        NSString *numStr = numbers[i];

        NSSize textSize = [numStr sizeWithAttributes:attrs];
        NSRect textRect = NSMakeRect(textCenter.x - textSize.width / 2,
                                     textCenter.y - textSize.height / 2,
                                     textSize.width,
                                     textSize.height);
        [numStr drawInRect:textRect withAttributes:attrs];
    }

    // Current time
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];

    CGFloat seconds = components.second;
    CGFloat minutes = components.minute + seconds / 60.0;
    CGFloat hours = components.hour % 12 + minutes / 60.0;

    CGFloat secAngle = M_PI_2 - (2 * M_PI * (seconds / 60.0));
    CGFloat minAngle = M_PI_2 - (2 * M_PI * (minutes / 60.0));
    CGFloat hourAngle = M_PI_2 - (2 * M_PI * (hours / 12.0));

    //
    CGFloat hourLength = radius * 0.5;
    CGFloat minLength = radius * 0.75;
    CGFloat secLength = radius * 0.9;

    CGFloat hourWidth = MAX(2, radius * 0.05);
    CGFloat minWidth = MAX(1.5, radius * 0.035);
    CGFloat secWidth = MAX(1, radius * 0.015);

    void (^drawHand)(CGFloat length, CGFloat lineWidth, NSColor *, CGFloat) = ^(CGFloat length, CGFloat lineWidth, NSColor *color, CGFloat angle) {
        [color setStroke];
        NSBezierPath *path = [NSBezierPath bezierPath];
        path.lineWidth = lineWidth;
        [path moveToPoint:center];
        NSPoint endPoint = NSMakePoint(center.x + length * cos(angle),
                                       center.y + length * sin(angle));
        [path lineToPoint:endPoint];
        [path stroke];
    };

    drawHand(hourLength, hourWidth, [NSColor colorWithCalibratedRed:0 green:0 blue:0.6 alpha:1], hourAngle);
    drawHand(minLength, minWidth, [NSColor colorWithCalibratedRed:0 green:0.6 blue:0 alpha:1], minAngle);
    drawHand(secLength, secWidth, [NSColor colorWithCalibratedRed:0.8 green:0 blue:0 alpha:1], secAngle);

    // Center dot
    CGFloat centerDotRadius = MAX(4, radius * 0.04);
    NSRect centerRect = NSMakeRect(center.x - centerDotRadius/2, center.y - centerDotRadius/2, centerDotRadius, centerDotRadius);
    [[NSColor blackColor] setFill];
    [[NSBezierPath bezierPathWithOvalInRect:centerRect] fill];
}

@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSScreen *screen = [NSScreen mainScreen];
    NSRect screenFrame = [screen frame];
    NSRect frame = NSMakeRect(0, 0, 400, 400);
    frame.origin.x = NSMidX(screenFrame) - frame.size.width / 2;
    frame.origin.y = NSMidY(screenFrame) - frame.size.height / 2;

    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled |
                                                         NSWindowStyleMaskClosable |
                                                         NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"Analog Clock"];
    [self.window makeKeyAndOrderFront:nil];

    ClockView *clockView = [[ClockView alloc] initWithFrame:[[self.window contentView] bounds]];
    clockView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window setContentView:clockView];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];

        NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];

        NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
        [mainMenu addItem:appMenuItem];

        NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"App"];
        NSString *appName = [[NSProcessInfo processInfo] processName];

        NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Quit %@", appName]
                                                              action:@selector(terminate:)
                                                       keyEquivalent:@"q"];
        [quitMenuItem setTarget:NSApp];
        [appMenu addItem:quitMenuItem];

        [appMenuItem setSubmenu:appMenu];

        [app setMainMenu:mainMenu];

        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}
