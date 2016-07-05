//
//  PECAnnuityTable.h
//  ObjAnnuities
//
//  Created by Peter Cerhan on 7/4/16.
//  Copyright © 2016 Peter Cerhan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PECAnnuityTable : NSObject

@property (nonatomic) double interest;
@property (nonatomic) int term;
@property (nonatomic) int deferralPeriod;
@property (nonatomic, copy) NSArray *mortalityTable;

@property (nonatomic, readonly) NSArray *l_x;
@property (nonatomic, readonly) NSArray *d_x;
@property (nonatomic, readonly) NSArray *v_x;
@property (nonatomic, readonly) NSArray *commutation_D_x;
@property (nonatomic, readonly) NSArray *commutation_N_x;
@property (nonatomic, readonly) NSArray *commutation_C_x;
@property (nonatomic, readonly) NSArray *commutation_M_x;

-(NSArray *)lifeAnnuityImmediate;

@end