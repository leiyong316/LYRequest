LYNetwork
=========

Basic request Network kit  (LYNetwork是完全开源基于get,post请求的网络库)


####Install
 ```ly
 platform :ios, '7.0'
 pod 'LYRequest', '~> 0.2'
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

* Upload
```oc3
    LYRequest *request = [LYRequest shareInstance];
    NSURL *url = [NSURL URLWithString:@"http://115.29.249.23:8081/Receive.ashx?operation=fqsp"]; // your fileupload address
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_1710.JPG" ofType:nil];
    NSDictionary *params = @{@"approvalid":@"9",
                             @"approvalname":@"ok",
                             @"categoryid":@"2",
                             @"contents":@"Try",
                             @"title":@"Leon",
                             @"userid":@"260",
                             @"username":@"admin",
                             @"workname":@"WorkApproval"};
    [request uploadWithURL:url filename:@"IMG_1710.JPG" params:params filePath:path progress:^(float progress) {
        self.label.text = [NSString stringWithFormat:@"%d%%",(int)progress];
    } finish:^(NSData *data) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"result =%@", result);
    } error:^(NSURLConnection *connection, NSError *error) {
        NSLog(@"error");
    }];
```
