//
//  SKStoreProductViewCell.h
//  LS
//
//  Created by John Scott on 09/02/2011.
//  Copyright 2011 jjrscott. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>

@interface SKStoreProductViewCell : UITableViewCell {
  UILabel *descriptionLabel;
}

+(id)reusableCellWithIdentifier:(NSString*)CellIdentifier forTableView:(UITableView*)tableView;

-(void)setProduct:(SKProduct*)product;

+(CGFloat)heightForProduct:(SKProduct*)product tableView:(UITableView*)tableView;

@end
