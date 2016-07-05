//
//  ViewController.m
//  ObjAnnuities
//
//  Created by Peter Cerhan on 7/1/16.
//  Copyright © 2016 Peter Cerhan. All rights reserved.
//

#import "ViewController.h"
#import "PECAnnuityTable.h"
#import "CustomTableViewCell.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSArray *_contingencyArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PECAnnuityTable *table = [[PECAnnuityTable alloc] init];
    
    _contingencyArray = [table lifeAnnuityImmediate];
}

//MARK: TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contingencyArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options: nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.ageLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    //round to 6 decimals
    double value = round([_contingencyArray[indexPath.row] doubleValue] * 1000000) / 1000000.0;
    
    cell.valueLabel.text = [NSString stringWithFormat:@"%f", value];
    
    return cell;
}

//MARK: TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Do nothing
}

@end
