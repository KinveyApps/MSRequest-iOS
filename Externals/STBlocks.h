/*
 *  STBlocks.h
 *  STLib
 *
 *  Created by Softteco on 2010-08-26.
 *  Softteco LLC. All rights reserved.
 *
 */

typedef void (^STEmptyBlock)();
typedef void (^STErrorBlock)(NSError *);
typedef void (^DataBlock)(NSData *);
typedef void (^ObjectBlock)(id);
