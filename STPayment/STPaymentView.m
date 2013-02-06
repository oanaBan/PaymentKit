//
//  STPaymentField.m
//  STPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor RGB(59,61,66)
#define RedColor RGB(253,0,17)
#define DefaultBoldFont [UIFont boldSystemFontOfSize:16]

#import <QuartzCore/QuartzCore.h>
#import "STPaymentView.h"

@interface STPaymentView ()
- (void)setup;
- (void)setupCardTypeImageView;
- (void)setupCardNumberField;
- (void)setupCardExpiryField;
- (void)setupCardCVCField;
- (void)setupZipField;

- (void)stateCardNumber;
- (void)stateMeta;
- (void)stateCardCVC;
- (void)stateZip;
- (void)updateCardTypeImageView;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardNumberFieldShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardCVCShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)addressZipShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString;

- (void)checkValid;
- (void)textFieldIsValid:(UITextField *)textField;
- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors;
@end

@implementation STPaymentView

@synthesize innerView, cardNumberField,
            cardExpiryField, cardCVCField, addressZipField,
            cardTypeImageView, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    isInitialState = YES;
    isValidState   = NO;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 290, 55);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [RGB(153,153,153) CGColor];
    self.clipsToBounds = YES;
    
    self.innerView = [[UIView alloc] initWithFrame:CGRectMake(12, 18, self.frame.size.width - 12, 20)];
    self.innerView.clipsToBounds = YES;
    
    [self setupCardTypeImageView];
    [self setupCardNumberField];
    [self setupCardExpiryField];
    [self setupCardCVCField];
    [self setupZipField];
    
    [self.innerView addSubview:cardNumberField];
    [self.innerView addSubview:cardTypeImageView];
    [self addSubview:self.innerView];
    
    [self stateCardNumber];
}


- (void)setupCardTypeImageView
{
    cardTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 20)];
    cardTypeImageView.backgroundColor = [UIColor whiteColor];
    cardTypeImageView.image = [UIImage imageNamed:@"placeholder"];
}

- (void)setupCardNumberField
{
    cardNumberField = [[UITextField alloc] initWithFrame:CGRectMake(39,0,160,20)];
    
    cardNumberField.delegate = self;
    
    cardNumberField.placeholder = @"1234 5678 9012 3456";
    cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    cardNumberField.textColor = DarkGreyColor;
    cardNumberField.font = DefaultBoldFont;

//    cardNumberField.secureTextEntry = YES;
    
    [cardNumberField.layer setMasksToBounds:YES];
}

- (void)setupCardExpiryField
{
    cardExpiryField = [[UITextField alloc] initWithFrame:CGRectMake(98,0,60,20)];

    cardExpiryField.delegate = self;
    
    cardExpiryField.placeholder = @"MM/YY";
    cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    cardExpiryField.textColor = DarkGreyColor;
    cardExpiryField.font = DefaultBoldFont;
    
    [cardExpiryField.layer setMasksToBounds:YES];
}

- (void)setupCardCVCField
{
    cardCVCField = [[UITextField alloc] initWithFrame:CGRectMake(163,0,55,20)];
    
    cardCVCField.delegate = self;
    
    cardCVCField.placeholder = @"CVC";
    cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    cardCVCField.textColor = DarkGreyColor;
    cardCVCField.font = DefaultBoldFont;
    
    [cardCVCField.layer setMasksToBounds:YES];
}

- (void)setupZipField
{
    addressZipField = [[UITextField alloc] initWithFrame:CGRectMake(213,0,50,20)];
    
    addressZipField.delegate = self;
    
    addressZipField.placeholder = @"ZIP";
    addressZipField.keyboardType = UIKeyboardTypeNumberPad;
    addressZipField.textColor = DarkGreyColor;
    addressZipField.font = DefaultBoldFont;
    addressZipField.textAlignment = NSTextAlignmentCenter;
    
    [addressZipField.layer setMasksToBounds:YES];
}

// Accessors

- (STCardNumber*)cardNumber
{
    return [STCardNumber cardNumberWithString:cardNumberField.text];
}

- (STCardExpiry*)cardExpiry
{
    return [STCardExpiry cardExpiryWithString:cardExpiryField.text];
}

- (STCardCVC*)cardCVC
{
    return [STCardCVC cardCVCWithString:cardCVCField.text];
}

- (STAddressZip*)addressZip
{
    return [STAddressZip addressZipWithString:addressZipField.text];
}

// State

- (void)stateCardNumber
{
    [cardExpiryField removeFromSuperview];
    [cardCVCField removeFromSuperview];
    [addressZipField removeFromSuperview];
    
    if (!isInitialState) {
        // Animate left
        isInitialState = YES;
        
        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                            cardNumberField.frame = CGRectMake(32 + 7,
                                                               cardNumberField.frame.origin.y,
                                                               cardNumberField.frame.size.width,
                                                               cardNumberField.frame.size.height);
                         }
                         completion:nil];
    }
    
    [self.cardNumberField becomeFirstResponder];
}

- (void)stateMeta
{
    isInitialState = NO;
    
    CGSize cardNumberSize = [self.cardNumber.formattedString sizeWithFont:DefaultBoldFont];
    CGSize lastGroupSize = [self.cardNumber.lastGroup sizeWithFont:DefaultBoldFont];
    CGFloat frameX = self.cardNumberField.frame.origin.x - (cardNumberSize.width - lastGroupSize.width) - 3;
        
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardNumberField.frame = CGRectMake(frameX,
                                           cardNumberField.frame.origin.y,
                                           cardNumberField.frame.size.width,
                                           cardNumberField.frame.size.height);
    } completion:nil];
    
    [self.innerView addSubview:cardTypeImageView];
    [self.innerView addSubview:cardExpiryField];
    [self.innerView addSubview:cardCVCField];
    [self.innerView addSubview:addressZipField];
    [cardExpiryField becomeFirstResponder];
}

- (void)stateCardCVC
{
    [cardCVCField becomeFirstResponder];
}

- (void)stateZip
{
    [addressZipField becomeFirstResponder];
}

- (BOOL)isValid
{    
    return [self.cardNumber isValid] && [self.cardExpiry isValid] &&
           [self.cardCVC isValid] && [self.addressZip isValid];
}

- (STCard*)card
{
    STCard* card    = [[STCard alloc] init];
    card.number     = [self.cardNumber string];
    card.cvc        = [self.cardCVC string];
    card.expMonth   = [self.cardExpiry month];
    card.expYear    = [self.cardExpiry year];
    card.addressZip = [self.addressZip string];
    
    return card;
}

- (void)updateCardTypeImageView {
    STCardNumber *cardNumber = [STCardNumber cardNumberWithString:cardNumberField.text];
    STCardType cardType      = [cardNumber cardType];
    NSString* cardTypeName   = @"placeholder";
    
    switch (cardType) {
        case STCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case STCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case STCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case STCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case STCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case STCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }
    
    cardTypeImageView.image  = [UIImage imageNamed:cardTypeName];
}

// Delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:cardExpiryField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:cardCVCField]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    if ([textField isEqual:addressZipField]) {
        return [self addressZipShouldChangeCharactersInRange:range replacementString:replacementString];
    }
    
    return YES;
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    STCardNumber *cardNumber = [STCardNumber cardNumberWithString:resultString];
    
    if ( ![cardNumber isPartiallyValid] )
        return NO;
    
    if (replacementString.length > 0) {
        cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        cardNumberField.text = [cardNumber formattedString];
    }
    
    [self updateCardTypeImageView];
    
    if ([cardNumber isValid]) {
        [self textFieldIsValid:cardNumberField];
        [self stateMeta];
        
    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:cardNumberField withErrors:YES];
        
    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:cardNumberField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardExpiryField.text stringByReplacingCharactersInRange:range withString:replacementString];
    STCardExpiry *cardExpiry = [STCardExpiry cardExpiryWithString:resultString];
    
    if (![cardExpiry isPartiallyValid]) return NO;
    
    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;
    
    if (replacementString.length > 0) {
        cardExpiryField.text = [cardExpiry formattedStringWithTrail];
    } else {
        cardExpiryField.text = [cardExpiry formattedString];
    }
    
    if ([cardExpiry isValid]) {
        [self textFieldIsValid:cardExpiryField];
        [self stateCardCVC];
        
    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:cardExpiryField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:cardExpiryField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [cardCVCField.text stringByReplacingCharactersInRange:range withString:replacementString];
    STCardCVC *cardCVC = [STCardCVC cardCVCWithString:resultString];
    STCardType cardType = [[STCardNumber cardNumberWithString:cardNumberField.text] cardType];
    
    // Restrict length
    if ( ![cardCVC isPartiallyValidWithType:cardType] ) return NO;
    
    // Strip non-digits
    cardCVCField.text = [cardCVC string];
    
    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:cardCVCField];
        [self stateZip];
    } else {
        [self textFieldIsInvalid:cardCVCField withErrors:NO];
    }
    
    return NO;
}

- (BOOL)addressZipShouldChangeCharactersInRange: (NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [addressZipField.text stringByReplacingCharactersInRange:range withString:replacementString];
    STAddressZip *addressZip = [STAddressZip addressZipWithString:resultString];

    // Restrict length
    if ( ![addressZip isPartiallyValid] ) return NO;
    
    addressZipField.text = [addressZip string];
    
    if ([addressZip isValid]) {
        [self textFieldIsValid:addressZipField];
    } else {
        [self textFieldIsInvalid:addressZipField withErrors:NO];
    }
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:cardNumberField]) {
        if ( !isInitialState ) [self stateCardNumber];
    }
}

- (void)checkValid
{
    if ([self isValid] && !isValidState) {
        isValidState = YES;

        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:YES];
        }
        
    } else if (![self isValid] && isValidState) {
        isValidState = NO;
        
        if ([self.delegate respondsToSelector:@selector(paymentView:withCard:isValid:)]) {
            [self.delegate paymentView:self withCard:self.card isValid:NO];
        }
    }
}

- (void)textFieldIsValid:(UITextField *)textField {
    textField.textColor = DarkGreyColor;
    [self checkValid];
}

- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors {
    if (errors) {
        textField.textColor = RedColor;
        
        // Shake view
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:3];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([textField center].x - 6.0f, [textField center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([textField center].x + 6.0f, [textField center].y)]];
        [[textField layer] addAnimation:animation forKey:@"position"];
        
    } else {
        textField.textColor = DarkGreyColor;        
    }

    [self checkValid];
}


@end