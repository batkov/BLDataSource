//
//  BLFetchDataSource.h
//  BLListDataSource
//
//  Created by Hariton Batkov on 10/26/17.
//

#import "BLDataSource.h"
#import "BLBaseFetch.h"

@interface BLFetchDataSource : BLDataSource
@property (nonatomic, assign) BLFetchMode fetchMode; // BLFetchModeOnlineOffline by default
@property (nonatomic, assign) NSTimeInterval defaultFetchDelay; // 15 second. How long till we reload data
@property (nonatomic, assign) NSTimeInterval defaultErrorFetchDelay; // 5 second. How long till we reload data if error occurred
@property (nonatomic, strong) id<BLBaseFetch> fetch;
@property (nonatomic, assign) BOOL storeFetchedObject; // Default NO
@property (nonatomic, strong, readonly) id fetchedObject;
@property (nonatomic, copy) dispatch_block_t fetchedObjectChanged;
@property (nonatomic, copy) BLFetchResultBlock fetchResultBlock; // Will return results from BLSimpleListFetchResult by default

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) new NS_UNAVAILABLE;
- (instancetype) initWithFetch:(id<BLBaseFetch>) fetch NS_DESIGNATED_INITIALIZER;

- (BOOL) failIfNeeded:(NSError *)error;
@end