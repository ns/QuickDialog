//
// Copyright 2011 ESCOZ Inc  - http://escoz.com
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//


@interface QMultilineTextViewController ()

@end

@implementation QMultilineTextViewController {
    BOOL _viewOnScreen;
    BOOL _keyboardVisible;
    UITextView* _textView;
}

@synthesize textView = _textView;
@synthesize resizeWhenKeyboardPresented = _resizeWhenKeyboardPresented;
@synthesize willDisappearCallback = _willDisappearCallback;


- (id)initWithTitle:(NSString *)title
{
    if ((self = [super init]))
    {
        self.title = (title!=nil) ? title : NSLocalizedString(@"Note", @"Note");
        _textView = [[UITextView alloc] init];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textView.font = [UIFont systemFontOfSize:18.0f];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.view addSubview:_textView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[[UIImage imageNamed:@"nav_back_button.png"] stretchableImageWithLeftCapWidth:30 topCapHeight:10] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 60, 29)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [button setTitle:@"Back" forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton =[[UIBarButtonItem alloc] initWithCustomView:button];

    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    _viewOnScreen = YES;
    [_textView becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    _viewOnScreen = NO;
    if (_willDisappearCallback !=nil){
        _willDisappearCallback();
    }
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) resizeForKeyboard:(NSNotification*)aNotification {
    if (!_viewOnScreen)
        return;

    BOOL up = aNotification.name == UIKeyboardWillShowNotification;

    if (_keyboardVisible == up)
        return;

    _keyboardVisible = up;
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    _textView.frame = CGRectMake(0,44,self.view.frame.size.width, up ? (keyboardFrame.size.height-15) : 0);
}

- (void)setResizeWhenKeyboardPresented:(BOOL)observesKeyboard {
  if (observesKeyboard != _resizeWhenKeyboardPresented) {
    _resizeWhenKeyboardPresented = observesKeyboard;

    if (_resizeWhenKeyboardPresented) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeForKeyboard:) name:UIKeyboardWillShowNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeForKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    } else {
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
  }
}


@end
