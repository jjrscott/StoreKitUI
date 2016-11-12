//
//  SKStoreProductViewCell.m
//  LS
//
//  Created by John Scott on 09/02/2011.
//  Copyright 2011 jjrscott. All rights reserved.
//

#import "SKStoreProductViewCell.h"
#import "SKProductsManager.h"

@implementation SKStoreProductViewCell


+(id)reusableCellWithIdentifier:(NSString*)CellIdentifier forTableView:(UITableView*)tableView
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[self alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
  }
  return cell;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      // Initialization code.
      
      self.textLabel.backgroundColor = [UIColor clearColor];
      self.detailTextLabel.backgroundColor = [UIColor clearColor];
      descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      descriptionLabel.backgroundColor = [UIColor clearColor];
      descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
      descriptionLabel.font = [UIFont systemFontOfSize:14.];
      descriptionLabel.highlightedTextColor = [UIColor whiteColor];

      descriptionLabel.numberOfLines = 0;
      [self.contentView addSubview:descriptionLabel];
    }
    return self;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  CGRect remainderRect;
  CGRect sliceRect;
  
  remainderRect = self.contentView.bounds;

//  remainderRect.size.width = 240.;
  
  remainderRect = CGRectInset(remainderRect, 5, 5);
  
  CGRectDivide(remainderRect, &sliceRect, &remainderRect, 30,CGRectMinYEdge);
  self.textLabel.frame = sliceRect;
  
  descriptionLabel.backgroundColor = [UIColor clearColor];

  CGRectDivide(remainderRect, &sliceRect, &remainderRect, 5,CGRectMinXEdge);
  
  descriptionLabel.frame = remainderRect;
}
    

- (void)dealloc {
  [descriptionLabel release];
  [super dealloc];
}

+(CGFloat)heightForProduct:(SKProduct*)product tableView:(UITableView*)tableView
{
    CGFloat height = 5;
    CGSize constrainedSize = CGSizeMake(tableView.bounds.size.width-10, CGFLOAT_MAX);
    
    height += [product.localizedTitle sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping].height;
    
    height += 5;
    
    height += [product.localizedDescription sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constrainedSize lineBreakMode:NSLineBreakByWordWrapping].height;
    
    height += 5;
    
    return height;
}

-(void)setProduct:(SKProduct*)product
{
  self.textLabel.text = [product localizedTitle];
  descriptionLabel.text = [product localizedDescription];
	
	if([[SKProductsManager productManager] isProductPurchased:product.productIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryCheckmark;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.detailTextLabel.text = @"";
	} else {
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
		[currencyStyle setLocale:product.priceLocale];
		[currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
		
		self.detailTextLabel.text = [currencyStyle stringFromNumber:product.price];
		[currencyStyle release];
	}
}

@end
