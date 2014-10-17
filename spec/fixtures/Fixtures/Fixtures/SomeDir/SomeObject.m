//
//  SomeObject.m
//  Fixtures
//
//  Created by Mark Larsen on 10/16/14.
//  Copyright (c) 2014 marklarr. All rights reserved.
//

#import "SomeObject.h"

@implementation SomeObject

- (void) willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects // Long line is long.
{
    [self validateValue:nil forKeyPath:nil error:nil] && [self validateValue:nil forKeyPath:nil error:nil] && [self validateValue:nil forKeyPath:nil error:nil];
}

@end
