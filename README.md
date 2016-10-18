# DMChatBase
Chat basically functionality for iOS

## Introduction

Chat messages list application based on UITableView, NSFetchResultController


## Install

**Via cocoapods**

1. Add into your Podfile file: 

```
pod 'DMChatBase', :git => 'https://github.com/DimaAvvakumov/DMChatBase.git'
```

2. Import header file

```objectiv-c
#import <DMChatBase/DMChatBase.h>
```

**Copy files**

1. Simple drag and drop DMChatBase category files into your project
2. Add header file 

```objectiv-c
#import "DMChatBase.h"
```

## Usage

First subclass DMChatMessagesViewController

```objectiv-c
    @interface ChatMessagesViewController : DMChatMessagesViewController
```
