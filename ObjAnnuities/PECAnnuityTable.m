//
//  PECAnnuityTable.m
//  ObjAnnuities
//
//  Created by Peter Cerhan on 7/4/16.
//  Copyright © 2016 Peter Cerhan. All rights reserved.
//

#import "PECAnnuityTable.h"
#import "PECMortalityTableReference.h"

static double _defaultInterest;
static int _defaultTerm;
static int _defaultDeferralPeriod;
static NSArray *_defaultMortalityTable;

@implementation PECAnnuityTable {
    NSUInteger _maxAge;
}

@synthesize interest = _interest;
@synthesize term = _term;
@synthesize deferralPeriod = _deferralPeriod;
@synthesize mortalityTable = _mortalityTable;

-(void)setInterest:(double)interest {
    _interest = interest;
    [self recalculate];
}

-(void)setTerm:(int)term {
    _term = term;
    [self recalculate];
}

-(void)setDeferralPeriod:(int)deferralPeriod {
    _deferralPeriod = deferralPeriod;
    [self recalculate];
}

-(void)setMortalityTable:(NSArray *)mortalityTable {
    _mortalityTable = [mortalityTable copy];
    [self recalculate];
}

//MARK: Initialization

+(void)initialize {
    if(self == [PECAnnuityTable class]) {
        _defaultInterest = 0.04;
        _defaultTerm = 20;
        _defaultDeferralPeriod = 20;
        _defaultMortalityTable = [[PECMortalityTableReference alloc] init].ppa_2016_blended;
    }
}

-(id)initWithInterest:(double)interest term:(int)term deferralPeriod:(int)deferralPeriod mortalityTable:(NSArray *)mortalityTable {
    self = [super init];
    if (self) {
        _interest = interest;
        _term = term;
        _deferralPeriod = deferralPeriod;
        _mortalityTable = mortalityTable;
        
        [self recalculate];
    }
    
    return self;
}

-(id)init {
    return [self initWithInterest:_defaultInterest term:_defaultTerm deferralPeriod:_defaultDeferralPeriod mortalityTable:_defaultMortalityTable];
}

//MARK: Recalculate Table

-(void)recalculate {
    _maxAge = [_mortalityTable count] - 1;
    _l_x = [self recalculate_l_x];
    _d_x = [self recalculate_d_x];
    _v_x = [self recalculate_v_x];
    _commutation_D_x = [self recalculate_commutation_D_x];
    _commutation_N_x = [self recalculate_commutation_N_x];
    _commutation_C_x = [self recalculate_commutation_C_x];
    _commutation_M_x = [self recalculate_commutation_M_x];
}

-(NSArray *)recalculate_l_x {
    NSMutableArray *build_l_x = [[NSMutableArray alloc] init];
    
    [_mortalityTable enumerateObjectsUsingBlock:^(id q_x_value, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [build_l_x addObject:@10000000.0];
        } else {
            [build_l_x addObject:@([build_l_x[idx - 1] doubleValue] * (1 - [q_x_value doubleValue]))];
        }
    }];
    
    return [build_l_x copy];
}

-(NSArray *)recalculate_d_x {
    NSMutableArray *build_d_x = [[NSMutableArray alloc] init];
    
    [_l_x enumerateObjectsUsingBlock:^(id l_x_value, NSUInteger idx, BOOL *stop) {
        if (idx == _maxAge) {
            [build_d_x addObject:@0.0];
        } else {
            [build_d_x addObject:@([l_x_value doubleValue] - [_l_x[idx + 1] doubleValue])];
        }
    }];
    
    return [build_d_x copy];
}

-(NSArray *)recalculate_v_x {
    NSMutableArray *build_v_x = [[NSMutableArray alloc] init];
    
    for (int i = 0; i <= _maxAge; i++) {
        [build_v_x addObject:@(pow((1 + _interest), -(double)i))];
    }
    
    return [build_v_x copy];
}

-(NSArray *)recalculate_commutation_D_x {
    NSMutableArray *build_commutation_D_x = [[NSMutableArray alloc] init];
    
    [_l_x enumerateObjectsUsingBlock:^(id l_x_value, NSUInteger idx, BOOL *stop) {
        [build_commutation_D_x addObject:@([l_x_value doubleValue] * [_v_x[idx] doubleValue])];
    }];
    
    return [build_commutation_D_x copy];
}

-(NSArray *)recalculate_commutation_N_x {
    NSMutableArray *build_commutation_N_x = [[NSMutableArray alloc] init];
    
    [build_commutation_N_x addObject:[_commutation_D_x valueForKeyPath:@"@sum.self"]];
    
    for (int i = 1; i <= _maxAge; i++) {
        [build_commutation_N_x addObject:@([build_commutation_N_x[i - 1] doubleValue] - [_commutation_D_x[i - 1] doubleValue])];
    }
    
    return [build_commutation_N_x copy];
}

-(NSArray *)recalculate_commutation_C_x {
    NSMutableArray *build_commutation_C_x = [[NSMutableArray alloc] init];
    
    [_d_x enumerateObjectsUsingBlock:^(id d_x_value, NSUInteger idx, BOOL *stop) {
        if (idx == _maxAge) {
            [build_commutation_C_x addObject:@(0.0)];
        } else {
            [build_commutation_C_x addObject:@([d_x_value doubleValue] * [_v_x[idx + 1] doubleValue])];
        }
    }];
    
    return [build_commutation_C_x copy];
}

-(NSArray *)recalculate_commutation_M_x {
    NSMutableArray *build_commutation_M_x = [[NSMutableArray alloc] init];
    
    [build_commutation_M_x addObject:[_commutation_C_x valueForKeyPath:@"@sum.self"]];
    
    for (int i = 1; i <= _maxAge; i++) {
        [build_commutation_M_x addObject:@([build_commutation_M_x[i - 1] doubleValue] - [_commutation_C_x[i - 1] doubleValue])];
    }
    
    return [build_commutation_M_x copy];
}

//MARK: Annuities

//Life Annuity Immediate
-(NSArray *)lifeAnnuityImmediate {
    NSMutableArray *buildAnnuityArray = [[NSMutableArray alloc] init];
    
    [_commutation_D_x enumerateObjectsUsingBlock:^(id value_D_x, NSUInteger idx, BOOL *stop) {
        if (idx == _maxAge) {
            [buildAnnuityArray addObject:@0.0];
        } else {
            [buildAnnuityArray addObject:@([_commutation_N_x[idx + 1] doubleValue] / [value_D_x doubleValue])];
        }
    }];
    
    return [buildAnnuityArray copy];
}

//Life Annuity Due

//Term Annuity Immediate

//Term Annuity Due

//Deferred Annuity Immediate

//Deferred Annuity Due

@end













