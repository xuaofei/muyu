// FeedbackPanelController.m
#import "FeedbackPanelController.h"
#import "LocalizedStringManager.h"
#import <Cocoa/Cocoa.h>

@interface FeedbackPanel : NSPanel
@end

@implementation FeedbackPanel
- (BOOL)canBecomeKeyWindow { return YES; }
- (BOOL)canBecomeMainWindow { return YES; }
@end

@interface FeedbackPanelController () <NSWindowDelegate>
@property (nonatomic, strong) NSTextField *titleField;
@property (nonatomic, strong) NSTextView *contentTextView;

@property (nonatomic, assign) NSApplicationActivationPolicy oldPolicy;
@property (nonatomic, assign) BOOL changedPolicy;

@property (nonatomic, copy) NSString *sendKey;
@end

@implementation FeedbackPanelController

+ (instancetype)shared {
    static FeedbackPanelController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FeedbackPanelController alloc] init];
    });
    return instance;
}

- (instancetype)init {
    NSRect rect = NSMakeRect(0, 0, 420, 280);
    FeedbackPanel *panel = [[FeedbackPanel alloc] initWithContentRect:rect
                                                           styleMask:(NSWindowStyleMaskTitled |
                                                                      NSWindowStyleMaskClosable)
                                                             backing:NSBackingStoreBuffered
                                                               defer:NO];

    panel.title = [LocalizedStringManager localizedStringForKey:@"feedback_win_title"];
    panel.floatingPanel = YES;
    panel.hidesOnDeactivate = NO;
    panel.releasedWhenClosed = NO;
    panel.delegate = self;
    panel.collectionBehavior = NSWindowCollectionBehaviorMoveToActiveSpace;
    panel.becomesKeyOnlyIfNeeded = NO;

    self = [super initWithWindow:panel];
    if (!self) return nil;

    self.sendKey = @"sctp14966tr3bmw8zbevfe76rpkhhyqt";

    [self buildUIInView:panel.contentView];
    return self;
}

- (void)buildUIInView:(NSView *)contentView {
    contentView.wantsLayer = YES;

    NSTextField *titleLabel = [NSTextField labelWithString:[LocalizedStringManager localizedStringForKey:@"feedback_title"]];
    NSTextField *contentLabel = [NSTextField labelWithString:[LocalizedStringManager localizedStringForKey:@"feedback_content"]];

    self.titleField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    self.titleField.placeholderString = [LocalizedStringManager localizedStringForKey:@"feedback_title_placeholder"];

    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    scrollView.hasVerticalScroller = YES;
    scrollView.borderType = NSBezelBorder;
    scrollView.drawsBackground = YES;

    self.contentTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 100, 50)];
    self.contentTextView.font = [NSFont systemFontOfSize:13];
    self.contentTextView.editable = YES;
    self.contentTextView.selectable = YES;
    self.contentTextView.richText = NO;
    self.contentTextView.importsGraphics = NO;
    self.contentTextView.allowsUndo = YES;
    self.contentTextView.textContainerInset = NSMakeSize(6, 6);

    self.contentTextView.verticallyResizable = YES;
    self.contentTextView.horizontallyResizable = NO;
    self.contentTextView.textContainer.widthTracksTextView = YES;
    self.contentTextView.textContainer.containerSize = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);

    scrollView.documentView = self.contentTextView;

    // 关键修复：给 documentView 加约束，避免尺寸为 0 导致无法输入
    self.contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    NSView *clipView = scrollView.contentView;
    [NSLayoutConstraint activateConstraints:@[
        [self.contentTextView.leadingAnchor constraintEqualToAnchor:clipView.leadingAnchor],
        [self.contentTextView.trailingAnchor constraintEqualToAnchor:clipView.trailingAnchor],
        [self.contentTextView.topAnchor constraintEqualToAnchor:clipView.topAnchor],
        [self.contentTextView.bottomAnchor constraintEqualToAnchor:clipView.bottomAnchor],
        [self.contentTextView.widthAnchor constraintEqualToAnchor:clipView.widthAnchor],
        [self.contentTextView.heightAnchor constraintGreaterThanOrEqualToAnchor:clipView.heightAnchor],
    ]];

    NSButton *submitBtn = [NSButton buttonWithTitle:[LocalizedStringManager localizedStringForKey:@"feedback_submit"]
                                             target:self
                                             action:@selector(onSubmit:)];
    submitBtn.bezelStyle = NSBezelStyleRounded;

    NSButton *cancelBtn = [NSButton buttonWithTitle:[LocalizedStringManager localizedStringForKey:@"feedback_cancle"]
                                             target:self
                                             action:@selector(onCancel:)];
    cancelBtn.bezelStyle = NSBezelStyleRounded;
    cancelBtn.keyEquivalent = @"\e"; // ESC

    for (NSView *v in @[titleLabel, self.titleField, contentLabel, scrollView, submitBtn, cancelBtn]) {
        v.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:v];
    }

    CGFloat pad = 16.0;

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:pad],
        [titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:pad],

        [self.titleField.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:6],
        [self.titleField.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:pad],
        [self.titleField.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-pad],

        [contentLabel.topAnchor constraintEqualToAnchor:self.titleField.bottomAnchor constant:12],
        [contentLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:pad],

        [scrollView.topAnchor constraintEqualToAnchor:contentLabel.bottomAnchor constant:6],
        [scrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:pad],
        [scrollView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-pad],
        [scrollView.bottomAnchor constraintEqualToAnchor:submitBtn.topAnchor constant:-12],

        [cancelBtn.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-pad],
        [cancelBtn.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-pad],

        [submitBtn.trailingAnchor constraintEqualToAnchor:cancelBtn.leadingAnchor constant:-10],
        [submitBtn.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-pad],
    ]];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.changedPolicy = NO;
        self.oldPolicy = NSApp.activationPolicy;
        if (self.oldPolicy != NSApplicationActivationPolicyRegular) {
            self.changedPolicy = [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        }

        [[NSRunningApplication currentApplication]
            activateWithOptions:(NSApplicationActivateAllWindows |
                                NSApplicationActivateIgnoringOtherApps)];

        [self.window center];
        [self showWindow:nil];
        [self.window makeKeyAndOrderFront:nil];
        [self.window makeFirstResponder:self.titleField];
    });
}

- (void)onSubmit:(id)sender {
    NSString *title = self.titleField.stringValue ?: @"";
    NSString *content = self.contentTextView.string ?: @"";

    [self sc_sendText:title desp:content completion:^(NSString *resp, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err) {
                NSLog(@"Feedback send failed: %@", err);
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"提交失败";
                alert.informativeText = err.localizedDescription ?: @"未知错误";
                [alert runModal];
                return;
            }

            NSLog(@"ServerChan response: %@", resp);
            [self.window close];
        });
    }];
}

- (void)onCancel:(id)sender {
    [self.window close];
}

- (void)windowWillClose:(NSNotification *)notification {
    self.titleField.stringValue = @"";
    self.contentTextView.string = @"";

    if (self.changedPolicy) {
        [NSApp setActivationPolicy:self.oldPolicy];
    }
}

#pragma mark - ServerChan

- (NSString *)sc_formEncode:(NSString *)s {
    if (!s) return @"";
    NSMutableCharacterSet *allowed = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [allowed addCharactersInString:@"-._~"];
    NSString *encoded = [s stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    return [encoded stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (NSString *)sc_buildURLStringWithSendKey:(NSString *)sendKey {
    return [NSString stringWithFormat:@"https://14966.push.ft07.com/send/%@.send", sendKey];
}

- (void)sc_sendText:(NSString *)text
               desp:(NSString *)desp
         completion:(void (^)(NSString *resp, NSError *err))completion {

    if (self.sendKey.length == 0) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"Feedback"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey: @"SENDKEY 为空"}]);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:[self sc_buildURLStringWithSendKey:self.sendKey]];
    NSString *bodyString = [NSString stringWithFormat:@"text=%@&desp=%@",
                            [self sc_formEncode:text ?: @""],
                            [self sc_formEncode:desp ?: @""]];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    req.HTTPBody = bodyData;
    [req setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *task =
    [[NSURLSession sharedSession] dataTaskWithRequest:req
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        NSString *respString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (completion) completion(respString ?: @"<non-utf8 response>", nil);
    }];
    [task resume];
}

@end
