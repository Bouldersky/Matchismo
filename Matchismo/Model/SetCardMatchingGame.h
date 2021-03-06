//
//  SetCardMatchingGame.h
//  Matchismo
//
//  Created by Skyler Arnold on 12/5/13.
//  Copyright (c) 2013 Skyler Arnold. All rights reserved.
//

#import "CardMatchingGame.h"

@interface SetCardMatchingGame : CardMatchingGame

- (void)selectCardAtIndex:(NSUInteger)index;
@property (nonatomic, strong, readonly) NSMutableArray *currentlySelectedCards;
@property (nonatomic, strong, readonly) NSMutableArray *selectedCardsCache;
@property (nonatomic, readonly) int scoreOnLastSelection;
@end
