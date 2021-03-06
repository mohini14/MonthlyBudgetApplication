//
//  MBIncomeViewController.m
//  MonthlyBudgetApplication
//
//  Created by Mohini on 31/05/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "MBIncomeDetailsViewController.h"
#import "MBNewTransactionView.h"
#import "MBDefine.h"
#import "MBTransactionTableCell.h"
#import "MBTransaction.h"
#import "MBCoreDataManager.h"


#define kTransactiontableCellIdentifier @"TransactionCell"
#define ktransactionTableCellXIBName    @"TransactionTableCell"

#define kIncomeTableViewHieghtConstant 100

@interface MBIncomeDetailsViewController ()

@end

@implementation MBIncomeDetailsViewController
{
    NSArray<MBTransaction* >* _creditDetailsArray;
    NSString*                 _transactionType;
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initialVCSetUp];
}

-(void) viewWillDisappear:(BOOL)animated
{
	// method to remove subview
	[super viewWillDisappear:animated];
	for (UIView* obj in self.view.subviews)
	{
		if(obj.tag == kTransactionViewTag)
			[obj removeFromSuperview];
	}
}

#pragma mark - Initial VC Setups
-(void) setUpSummaryView
{
    self.incomeLabel.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:self.month.totalIncome]];
    self.expenditureLabel.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:self.month.totalExpenditure]];
    
    double balance = self.month.totalIncome - self.month.totalExpenditure;
    if(balance < kConstIntZero)
        self.balanceLabel.textColor = [UIColor redColor];
	else
		self.balanceLabel.textColor = [UIColor blueColor];
	
    self.balanceLabel.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:balance]];
}

// method populates data into Income table view
-(void) populateData
{
    MBCoreDataManager* coreDataManager = [[MBCoreDataManager alloc]init];
    MBTransaction* transaction = [[MBTransaction alloc]init];
    transaction.monthName = self.month.monthName;
    transaction.transactionType = _transactionType;
    
    _creditDetailsArray = [coreDataManager fetchTransactionListFromCoreData:transaction];
    
    [self.month setTotalIncome:[self calculateTotalIncome]];
    [self setUpSummaryView];
    [self.incomeTableView reloadData];
}

-(void) initialVCSetUp
{
    _transactionType = kIncomeRecordType;
    [self populateData];
    
    //Navigation bar with right bar button item
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonPressedForAddingNewIncome)];
    
    self.tabBarController.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - Actions on VC
// action : Navigation right bar button item
-(void) rightBarButtonPressedForAddingNewIncome
{
    __weak typeof(self) weakSelf = self;

    MBNewTransactionView* newTransactionView = [[MBNewTransactionView alloc]initWithNewTransactionView:self forRecordType:_transactionType forMonthName:self.month.monthName];
    
    newTransactionView.onPressingSaveButton = ^(MBTransaction* transaction)
    {
        transaction.monthName = weakSelf.month.monthName;
        [weakSelf saveNewTransactionRecordToDataBase:transaction];
    };
}

#pragma mark - TableView Data source and Dalegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _creditDetailsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBTransactionTableCell* cell = [tableView dequeueReusableCellWithIdentifier:kTransactiontableCellIdentifier];
    if(cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:ktransactionTableCellXIBName owner:nil options:nil]firstObject];
    
    [cell setUpCellAttribiute:_creditDetailsArray[indexPath.row]];
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kIncomeTableViewHieghtConstant;
}


#pragma mark - Helper Methods
// method calculates total income
-(double) calculateTotalIncome
{
    double income = kConstDoubleZero;
    if(_creditDetailsArray.count > kConstIntZero)
    {
        for(MBTransaction* obj in _creditDetailsArray)
        {
            income = income + obj.amount;
        }
    }
    return income;
}

// method saves new Income record to Database
-(void) saveNewTransactionRecordToDataBase:(MBTransaction* )transaction
{
    MBCoreDataManager* coreDataManager = [[MBCoreDataManager alloc]init];
    [coreDataManager saveTransactionDetailsToCoreData:transaction];
    [self populateData];
    
    [self.month setTotalIncome:[self calculateTotalIncome]];
	
    [coreDataManager updateMonthRecord:self.month];
    [self setUpSummaryView];
}

@end
