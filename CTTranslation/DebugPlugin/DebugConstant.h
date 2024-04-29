//
//  DebugConstant.h
//  Co Translation
//
//  Created by  cttranslation on 2024/1/4.
//

#ifndef DebugConstant_h
#define DebugConstant_h

#ifdef DEBUG
#define TEST
#ifndef TEST
#define NSLog(fmt, ...) NSLog((@"<%s:%d> " fmt), [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, ##__VA_ARGS__);
#else
#define NSLog(fmt, ...) NSLog((@"<APP Words> " fmt), ##__VA_ARGS__);
#endif
#else
#define NSLog(...) {}
#endif

#endif /* DebugConstant_h */
