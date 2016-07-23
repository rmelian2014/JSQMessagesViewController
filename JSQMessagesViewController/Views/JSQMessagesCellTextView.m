//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesCellTextView.h"

@interface JSQMessagesCellTextView()
@property (nonatomic,strong) UIColor * originalTextColor;
@property (nonatomic,strong) NSMutableArray *customLinkExpresions;
@end


@implementation JSQMessagesCellTextView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.textColor = [UIColor whiteColor];
    self.editable = NO;
    self.selectable = YES;
    self.userInteractionEnabled = YES;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.scrollEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.contentInset = UIEdgeInsetsZero;
    self.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.contentOffset = CGPointZero;
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    self.linkTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
}

-(void)addCustomLinkRegularExpresion:(NSRegularExpression*)expresion
{
    if(_customLinkExpresions == nil)
        _customLinkExpresions = [NSMutableArray array];
    
    [_customLinkExpresions addObject:expresion];
}

- (void)setSelectedRange:(NSRange)selectedRange
{
    //  attempt to prevent selecting text
    [super setSelectedRange:NSMakeRange(NSNotFound, 0)];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    _originalTextColor = textColor;
}


- (NSRange)selectedRange
{
    //  attempt to prevent selecting text
    return NSMakeRange(NSNotFound, NSNotFound);
}

- (BOOL)detectCustomLinks
{
    NSMutableArray<NSTextCheckingResult*>  *textCheckingResults = [NSMutableArray<NSTextCheckingResult*> array];
    for (NSRegularExpression *exp in [self.regularExpressionsDelegate getRegularExpressions]) {
        NSArray<NSTextCheckingResult*> * matches = [exp matchesInString:self.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, self.text.length)];
        [textCheckingResults addObjectsFromArray:matches];
    }
    
    NSMutableAttributedString * str2 = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    [str2 removeAttribute:NSLinkAttributeName range:NSMakeRange(0, str2.string.length)];
    for (NSTextCheckingResult * match in textCheckingResults) {
        [str2 addAttribute: NSLinkAttributeName value:[str2 attributedSubstringFromRange:match.range].string range:match.range];
    }
    
    self.attributedText = str2;
    
    return [textCheckingResults count] > 0 ? YES : NO;
}

- (BOOL)haveValidLinks
{
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress
                                | NSTextCheckingTypePhoneNumber | NSTextCheckingTypeDate
                                                               error:&error];
    NSInteger number = [detector numberOfMatchesInString:self.text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, self.text.length)];
    
    if(number > 0 /*|| [self detectCustomLinks]*/)
        return YES;
    
    return NO;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{

    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if(![self haveValidLinks] && ![self customLinkExpresions])
        {
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        self.textColor = self.originalTextColor;
        }
    }
    self.dataDetectorTypes = UIDataDetectorTypeAll;
    //  ignore double-tap to prevent copy/define/etc. menu from showing
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
        if (tap.numberOfTapsRequired == 2) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //  ignore double-tap to prevent copy/define/etc. menu from showing
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
        if (tap.numberOfTapsRequired == 2) {
            return NO;
        }
    }
    
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self detectCustomLinks];
}

@end
