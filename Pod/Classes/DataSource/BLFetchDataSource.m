//
//  BLFetchDataSource.m
//  BLListDataSource
//
//  Created by Hariton Batkov on 10/26/17.
//

#import "BLFetchDataSource.h"
#import "BLDataSource+Subclass.h"

@interface BLFetchDataSource ()

@property (nonatomic, strong) id fetchedObject;

@end

@implementation BLFetchDataSource

- (instancetype) initWithFetch:(id<BLBaseFetch>) fetch {
    NSAssert(fetch, @"You need to provide fetch");
    if (self = [super init]) {
        self.fetch = fetch;
        self.defaultFetchDelay = 15;
        self.defaultErrorFetchDelay = 15;
        self.storeFetchedObject = NO;
    }
    return self;
}

- (void)fetchOfflineData:(BOOL) refresh {
    if (self.fetchMode == BLFetchModeOnlineOnly) {
        return; // Offline disabled
    }
    __weak typeof(self) selff = self;
    [self.fetch fetchOffline:^(id  _Nullable object, NSError * _Nullable error) {
        if (error) {
            // TODO implement loging ?
        } else if (!selff.fetchedObject || refresh) {
            if (selff.fetchMode == BLFetchModeOfflineOnly) {
                selff.fetchedObject = nil;
            }
            BLBaseFetchResult * result = [selff createFetchResultForLocalObject:object];
            [selff processFetchResult:result];
        }
        if (refresh) {
            [selff contentLoaded:error];
        }
    }];
}

- (BOOL) hasContent {
    return self.fetchedObject != nil;
}

- (void) resetData {
    self.fetchedObject = nil;
}

- (void) runRequest {
    if (self.fetchMode == BLFetchModeOfflineOnly) {
        [self fetchOfflineData:YES];
        return;
    }
    [self.fetch fetchOnline:nil
                   callback:[self createResultBlock]];
}

- (BLIdResultBlock) createResultBlock {
    return ^(id object, NSError * error){
        if ([self failIfNeeded:error])
            return;
        BLBaseFetchResult * fetchResult = [self createFetchResultFor:object];
        if (![fetchResult isValid]) {
            [self contentLoaded:fetchResult.lastError];
            return;
        }
        [self itemsLoaded:fetchResult];
    };
}

- (BOOL) failIfNeeded:(NSError *)error {
    if (error) {
        [self contentLoaded:error];
        return YES;
    }
    return NO;
}

- (void) itemsLoaded:(BLBaseFetchResult *) fetchResult {
    self.fetchedObject = nil;
    if (self.storeFetchedObject) {
        [self storeItems:fetchResult];
    }
    [self processFetchResult:fetchResult];
    [self contentLoaded:nil];
}

- (void) storeItems:(BLBaseFetchResult *) fetchResult {
    [self.fetch storeItems:fetchResult callback:^(BOOL result, NSError * _Nullable error) {
       
    }];
}

- (void) startContentLoading {
    [super startContentLoading];
    if (self.fetchMode != BLFetchModeOfflineOnly) {
        [self fetchOfflineData:NO];
    }
    [self runRequest];
}

- (void) startContentRefreshing {
    [super startContentRefreshing];
    [self runRequest];
}

- (BOOL) refreshContentIfPossible {
    NSAssert(self.state != BLDataSourceStateInit, @"We actually shouldn't be here");
    if (self.state == BLDataSourceStateLoadContent)
        return NO;
    if (self.state == BLDataSourceStateRefreshContent)
        return NO;
    [self startContentRefreshing];
    return YES;
}

- (BOOL) loadMoreIfPossible {
    if (self.state == BLDataSourceStateLoadContent)
        return NO;
    if (self.state == BLDataSourceStateRefreshContent)
        return NO;
    
    if (self.state != BLDataSourceStateContent)
        return NO;
    [self startContentRefreshing];
    return YES;
}

- (void) processFetchResult:(BLBaseFetchResult *) fetchResult {
    id object = fetchResult.items;
    if ([fetchResult.items count] == 0) {
        object = [fetchResult.items firstObject];
    }
    self.fetchedObject = object;
    if (self.fetchedObjectChanged) {
        self.fetchedObjectChanged ();
    }
}

#pragma mark -
-(void)reloadDataWithDelay {
    int delay = self.defaultFetchDelay;
    switch (self.state) {
        case BLDataSourceStateInit:
        case BLDataSourceStateLoadContent:
        case BLDataSourceStateRefreshContent:
            return;
        case BLDataSourceStateError:
            delay = self.defaultErrorFetchDelay;
            return;
        default:
            break;
    }
    __weak typeof(self) selff = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [selff refreshContentIfPossible];
    });
}

-(void)setState:(BLDataSourceState)state {
    [super setState:state];
    [self reloadDataWithDelay];
}

#pragma mark - Abstract Methods
- (BLBaseFetchResult * __nonnull) createFetchResultFor:(id)object {
    if (self.fetchResultBlock) {
        return self.fetchResultBlock(object, NO);
    }
    return nil; // For subclassing
}

- (BLBaseFetchResult * __nonnull) createFetchResultForLocalObject:(id)object {
    if (self.fetchResultBlock) {
        return self.fetchResultBlock(object, YES);
    }
    return nil; // For subclassing
}

#pragma mark -
-(NSString *)description {
    NSString * fetchMode = @"OnlineAndOffline";
    if (self.fetchMode == BLFetchModeOnlineOnly) {
        fetchMode = @"Online";
    } else if (self.fetchMode == BLFetchModeOfflineOnly) {
        fetchMode = @"Offline";
    }
    return [NSString stringWithFormat:@"%@\nMode: %@\nFetch: %@\nFetchedObject: %@", [super description], fetchMode, [self.fetch description], self.fetchedObject];
}
@end