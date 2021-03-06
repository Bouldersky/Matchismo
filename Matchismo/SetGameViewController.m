//
//  SetGameViewController.m
//  Matchismo
//
//  Created by David Leserman on 6/5/13.
//  Copyright (c) 2013 Skyler Arnold. All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCardMatchingGame.h"
#import "SetCardDeck.h"
#import "CoreImage/CIColor.h"
#import "CoreImage/CIImage.h"

@interface SetGameViewController ()
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *setGameFlipResults;
@property (strong, nonatomic) IBOutlet UILabel *flipsLabel;
@end

@implementation SetGameViewController

- (SetCardMatchingGame *) game
{
    if (!super.game) {
        SetCardDeck *scDeck = [[SetCardDeck alloc] init];
        super.game = [[SetCardMatchingGame alloc] initWithCardCount:self.cardButtons.count usingDeck:scDeck];
    }
    return (SetCardMatchingGame *) super.game;
}

- (IBAction) newGame
{
    SetCardDeck *scDeck = [[SetCardDeck alloc] init];
    self.game = [self.game initWithCardCount:self.cardButtons.count usingDeck:scDeck];
    self.flipsLabel.text = @"Flips: 0";
    [self updateUI];
    self.setGameFlipResults.text = @"Flip a card!";
}


+ (NSString *)getCardString:(SetCard *)card
{
    NSString *placeHolderVariable = [[NSString alloc] init];
    return placeHolderVariable;
}

- (IBAction)setCard:(UIButton *)sender
{
    [(SetCardMatchingGame *) super.game selectCardAtIndex: [self.cardButtons indexOfObject:sender]];
    [self updateUI];
}

- (void)viewDidLoad
{
    [self updateUI];
	// Do any additional setup after loading the view.
}

- (NSString *)getDisplayCharacter:(int)shapeCode
{
    NSString *returnShape;
    switch (shapeCode) {
        case 1: returnShape = @"■"; break; // \u2583 \u2588 \uFFED, has funky fill: ◼
        case 2: returnShape = @"\u25CF"; break; // \u25EF, ●
        case 3: returnShape = @"\u25B2"; break; // ▲
        default: returnShape = @"!"; break;
    }
    
    return returnShape;
}

- (UIColor *)getDisplayColor:(int)colorCode
{
    UIColor *color;
    switch (colorCode) {
        case 1: color = [UIColor redColor]; break;
        case 2: color = [UIColor greenColor]; break;
        case 3: color = [UIColor blueColor]; break;
        default: color = [UIColor magentaColor]; break;
    }
    return color;
}

- (UIColor *)getDisplayColorWithAlpha:(UIColor *)originalColor fillCode:(int)fillCode
{
    float alpha;
    switch (fillCode) {
        case 1: alpha = 0.0; break;
        case 2: alpha = 0.2; break;
        case 3: alpha = 1.0; break;
        default: alpha = -1.0; break;
    }
    UIColor *returnColor = [originalColor colorWithAlphaComponent:alpha];
    return returnColor;
}

- (NSString *) getDisplayString:(NSString *) shapeChar shapeCount:(int) numberOfShapes
{
    NSString *outputString = @"";
    for (int i = 1; i <= numberOfShapes; i++) {
        outputString = [NSString stringWithFormat:@"%@%@", outputString, shapeChar];
    }
    return outputString;
}

- (float)getFontSize:(int)shapeCode
{
    float fontSize;
    switch (shapeCode) {
        case 1: fontSize = 18.0; break; // ◼
        case 2: fontSize = 30.0; break; // ●
        case 3: fontSize = 18.0; break; // ▲
        default: fontSize = 30.0; break;
    }
    
    return fontSize;
}

- (NSNumber *)getBaselineOffset:(int)shapeCode
{
    float baselineOffset;
    switch (shapeCode) {
        case 1: baselineOffset = 0; break; // ◼
        case 2: baselineOffset = 1; break; // ●
        case 3: baselineOffset = -1; break; // ▲
        default: baselineOffset = 20; break;
    }
    return [NSNumber numberWithFloat: baselineOffset];

}

-(NSAttributedString *)getAttributedStringFromCard:(SetCard *) card ignorePlayablility:(BOOL) ignorePlayablility
{
    NSString *shapeCharacter = [self getDisplayCharacter:card.shape];
    NSString *displayString = [self getDisplayString:shapeCharacter shapeCount:card.count];
    UIColor *color = [self getDisplayColor:card.color];
    UIColor *colorWithAlpha = [self getDisplayColorWithAlpha:color fillCode:card.fill];
    float fontSize = [self getFontSize:card.shape];
    UIFont *fontWithSize = [UIFont fontWithName:@"Helvetica" size: fontSize];
    NSNumber *strokeWidth = [NSNumber numberWithFloat: -3.0];
    NSNumber *baselineOffset = [self getBaselineOffset:card.shape];
    
    if (!(((Card *)card).isPlayable || ignorePlayablility)) {
        displayString = @"";
    }
    
    NSAttributedString *cardText = [[NSAttributedString alloc] initWithString:displayString
                                                                   attributes:@{NSFontAttributeName: fontWithSize,
                                                                                NSStrokeWidthAttributeName: strokeWidth,
                                                                                NSStrokeColorAttributeName: color,
                                                                                NSForegroundColorAttributeName: colorWithAlpha,
                                                                                NSBaselineOffsetAttributeName: baselineOffset}];

    return cardText;
}

- (NSAttributedString *)convertStringToNSAttributedString:(NSString *)inputString
{
    NSAttributedString *returnAttributedString = [[NSAttributedString alloc] initWithString:inputString attributes: @{}];
    return returnAttributedString;
}

- (NSAttributedString *)getEnglishListOfTheThreeCards
{
    SetCardMatchingGame *setCardMatchingGame = (SetCardMatchingGame *) self.game;
    NSArray *selectedCards = (NSArray *) setCardMatchingGame.selectedCardsCache;
    NSMutableAttributedString *threeCardsText = [[NSMutableAttributedString alloc] init];

    [threeCardsText appendAttributedString:[self getAttributedStringFromCard:selectedCards[0] ignorePlayablility:true]];
    [threeCardsText appendAttributedString:[self convertStringToNSAttributedString:@", "]];
    [threeCardsText appendAttributedString:[self getAttributedStringFromCard:selectedCards[1] ignorePlayablility:true]];
    [threeCardsText appendAttributedString:[self convertStringToNSAttributedString:@" and "]];
    [threeCardsText appendAttributedString:[self getAttributedStringFromCard:selectedCards[2] ignorePlayablility:true]];
    [threeCardsText appendAttributedString:[self convertStringToNSAttributedString:@" "]];
    return threeCardsText;
}

- (void)updateUI
{
    // count -- 0 = undefined, 1-3 are valid values
    // shape -- 0 = undefined, 1 = square, 2 = circle, 3 = triangle
    // fill -- 0 = undefined, 1 = none, 2 = shaded, 3 = solid
    // color -- 0 = undefined, 1 = red, 2 = green, 3 = blue
    
    [super updateUI];
    
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %i", self.game.flipCount];
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %i", self.game.totalScore];
    
    // Compute and set the UI state for each cardButton.
    for (UIButton *cardButton in self.cardButtons) {
        SetCard *card = (SetCard *) [self.game cardAtIndex:[self.cardButtons indexOfObject:cardButton]];
    
        NSAttributedString *cardText = [self getAttributedStringFromCard:card ignorePlayablility:false];
        
        [cardButton setAttributedTitle:cardText forState:UIControlStateNormal];
        [cardButton setAttributedTitle:cardText forState:UIControlStateSelected];
        
        
        // If the card associated with this cardButton is in the list of currentlySelectedCards,
        // then we'll set the background of the cardButton to illustrate this.
        cardButton.selected = [((SetCardMatchingGame *) self.game).currentlySelectedCards containsObject:card];
    }
    SetCardMatchingGame *setCardMatchingGame = (SetCardMatchingGame *) self.game;
    
    NSMutableAttributedString *flipResultsText = [[NSMutableAttributedString alloc] init];
    
    if (setCardMatchingGame.scoreOnLastSelection == 0) {
        [flipResultsText appendAttributedString:[self convertStringToNSAttributedString:@"Flip a card."]];
    } else if (setCardMatchingGame.scoreOnLastSelection > 0) {
        [flipResultsText appendAttributedString:[self convertStringToNSAttributedString:@"Matched "]];
        [flipResultsText appendAttributedString:[self getEnglishListOfTheThreeCards]];
        [flipResultsText appendAttributedString:[self convertStringToNSAttributedString:@" for "]];
        [flipResultsText appendAttributedString:[self convertStringToNSAttributedString:[NSString stringWithFormat:@"%i points!", setCardMatchingGame.scoreOnLastSelection]]];
    } else {
        [flipResultsText appendAttributedString:[self getEnglishListOfTheThreeCards]];
        [flipResultsText appendAttributedString:[self convertStringToNSAttributedString:@"do not match."]];
        [flipResultsText appendAttributedString:[self convertStringToNSAttributedString:[NSString stringWithFormat:@" %i point penalty!", -setCardMatchingGame.scoreOnLastSelection]]];
    }
    
    [self.setGameFlipResults setAttributedText:flipResultsText];
}

@end
