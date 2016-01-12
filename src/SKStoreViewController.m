//
//  SKStoreRootViewController.m
//  StoreKitUI
//
//  Created by Jason C. Martin on 12/28/09.
//  Copyright 2009 New Media Geekz. All rights reserved.
//

#import "StoreKitUI/SKStoreViewController.h"
#import "StoreKitUI/SKProductsManager.h"
#import "SKProgressView.h"
#import "SKDebug.h"

#import "SKStoreProductViewCell.h"
#import <StoreKit/StoreKit.h>

@implementation SKStoreViewController

@synthesize productIDs;

- (void)dismissModalViewController {
	if(self.parentViewController != self.navigationController) {
		[self.parentViewController dismissViewControllerAnimated:YES completion:NULL];
	} else {
		if(self.navigationController == self.navigationController.parentViewController.modalViewController) {
			[self.navigationController.parentViewController dismissViewControllerAnimated:YES completion:NULL];
		}
	}
}

- (id)init {
	if((self = [super initWithStyle:UITableViewStyleGrouped])) {
		if(![SKPaymentQueue canMakePayments]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"In-app purchase is disabled. Please enable it to activate more features.", @"In-app purchase is disabled. Please enable it to activate more features.") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			return nil;
		}
		
		[[SKProductsManager productManager] addObserver:self forKeyPath:@"products" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPurchase:) name:SKProductsManagerFinishedPurchaseNotification object:nil];
		
		self.navigationItem.title = NSLocalizedString(@"Store", @"Store");
		
		progressView = [[SKProgressView alloc] init];
		progressView.label.text = NSLocalizedString(@"Loading...", @"Loading...");
		[progressView.label sizeToFit];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restoreCompletedTransactions)] autorelease];
	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"products"]) {
		[progressView hide];
		
		[[self tableView] reloadData];
    }
}

- (void)didPurchase:(id)unused {
	[progressView hide];
	
	[[self tableView] reloadData];
}

- (void)setProductIDs:(NSSet *)newProducts {
	@synchronized(self) {
		if(newProducts != productIDs) {
			[productIDs release];
			productIDs = [newProducts copy];
			
			if(productIDs) {
				[[SKProductsManager productManager] loadProducts:productIDs];
				
				[progressView performSelector:@selector(showInView:) withObject:self.view afterDelay:0.3];
			}
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
	BOOL isModal = NO;
	
	// How to determine if we're modal or not...
	if(self.navigationController && self.navigationController.parentViewController) {
		isModal = (self.navigationController == self.navigationController.parentViewController.modalViewController);
	} else {
		isModal = (self == self.parentViewController.modalViewController);
	}
	
	if(isModal) {
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewController)] autorelease];
	}
	
	[super viewWillAppear:animated];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[SKProductsManager productManager] products] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SKUIStoreCell";
    
  SKStoreProductViewCell *cell = [SKStoreProductViewCell reusableCellWithIdentifier:CellIdentifier forTableView:tableView];
	
	SKProduct *product = [[[SKProductsManager productManager] products] objectAtIndex:indexPath.row];
  
  [cell setProduct:product];
	
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (section > 0)
    {
        return UITableViewAutomaticDimension;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([[SKProductsManager productManager] isProductPurchased:[(SKProduct *)[[[SKProductsManager productManager] products] objectAtIndex:indexPath.row] productIdentifier]])
	   return;
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	progressView.label.text = NSLocalizedString(@"Purchasing...", @"Purchasing...");
	[progressView.label sizeToFit];
	[progressView showInView:self.view];
	
	[[SKProductsManager productManager] purchaseProductAtIndex:indexPath.row];
}

-(IBAction)restoreCompletedTransactions
{
  progressView.label.text = NSLocalizedString(@"Restoring...", @"Restoring...");
	[progressView.label sizeToFit];
	[progressView showInView:self.view];

  [[SKProductsManager productManager] restoreCompletedTransactions];
}


- (void)dealloc {
	[[SKProductsManager productManager] removeObserver:self forKeyPath:@"products"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[progressView release];
	progressView = nil;
	
	[productIDs release];
	productIDs = nil;
	
    [super dealloc];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  SKProduct *product = [[[SKProductsManager productManager] products] objectAtIndex:indexPath.row];

  return [SKStoreProductViewCell heightForProduct:product];
}


@end

