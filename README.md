LYNetwork
=========

Basic request Network kit  (LYNetwork是完全开源基于get,post请求的网络库)

请高手高抬贵手，不要吐槽。

####Install
 ```ly
 platform :ios, '7.0'
 pod 'LYRequest', '~> 0.1'
```
```install
pod install
```

####Use
* Get
```oc
  NSURL *url = [NSURL URLWithString:@"http://114.215.101.94:83/service/ads.php?type=1&flag=1"];
  LYRequest *request = [LYRequest shareInstance];
  [request requestWithURL:url
                   params:nil
                  method:@"get"
                 useCache:NO
             finishBlock:^(NSData *data) {
                  id obj = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
                  NSLog(@"%@", obj);
             } errorBlock:^(NSURLConnection *connection, NSError *error) {
                  NSLog(@"error");
              }];
```
  
* Post
```oc1
  NSURL *url = [NSURL URLWithString:@"http://114.215.101.94:83/service/ads.php"];
  NSDictionary *dict = @{@"type":@"1", @"flag":@"1"};
  LYRequest *request = [LYRequest shareInstance];
  [request requestWithURL:url
                   params:dict
                   method:@"post"
                 useCache:NO
              finishBlock:^(NSData *data) {
                  id obj = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
                  NSLog(@"%@", obj);
              } errorBlock:^(NSURLConnection *connection, NSError *error) {
                  NSLog(@"error");
              }];
```
  
 * Download
```oc2
  LYRequest *request = [LYRequest shareInstance];
  NSURL *url = [NSURL URLWithString:@"https://d.alipayobjects.com/sec/edit/beta/wkaliedit.dmg"];
  [request downloadWithURL:url progressBlock:^(float progress) {
      self.label.text = [NSString stringWithFormat:@"%d%%",(int)progress];
  } finishBlock:^(NSData *data) {
      NSString *filePath = [[self getDocumentPath] stringByAppendingPathComponent:[url lastPathComponent]];
      [data writeToFile:filePath atomically:YES];
  } errorBlock:^(NSURLConnection *connection, NSError *error) {
      NSLog(@"error");
  }];
```
