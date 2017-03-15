
#import "EpubParser.h"
#import "GDataXMLNode.h"
#import <CoreText/CoreText.h>
#import "NSMutableAttributedString+Add.h"
#import "NSString+UrlEncode.h"
#import "CTFunction.h"

static dispatch_queue_t parse_progress_serial_queue(){
    static dispatch_queue_t epub_parse_progress_serial_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        epub_parse_progress_serial_queue = dispatch_queue_create("com.unknown.epub.progress.creation", DISPATCH_QUEUE_SERIAL);
    });
    return epub_parse_progress_serial_queue;
}


NSString *absolutePath(NSString *currentPath,NSString *relativePath){
    if ([relativePath hasPrefix:@"../"]) {
        NSArray *components = [relativePath componentsSeparatedByString:@"/"];
        NSMutableArray *componentArr = [NSMutableArray arrayWithArray:components];
        [componentArr removeObject:components.firstObject];
        relativePath = [NSString pathWithComponents:componentArr];
        NSString *lastPath = [currentPath stringByDeletingLastPathComponent];
        relativePath = [lastPath stringByAppendingPathComponent:relativePath];
    }else
        if ([relativePath hasPrefix:@"/"]) {
            NSArray *components = [relativePath componentsSeparatedByString:@"/"];
            NSMutableArray *componentArr = [NSMutableArray arrayWithArray:components];
            [componentArr removeObject:components.firstObject];
            relativePath = [NSString pathWithComponents:componentArr];
            relativePath = [NSString pathWithComponents:componentArr];
            relativePath = [currentPath stringByAppendingPathComponent:relativePath];
        }else{
            relativePath = [currentPath stringByAppendingPathComponent:relativePath];
        }
    return relativePath;
}


@implementation EpubPage{
    
}
#if 1
- (instancetype)init
{
    self = [super init];
    if (self) {
        _images = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc{
    CFRelease(_frameRef);
}




#endif
@end


@implementation EpubTitleInfo

@end

@implementation EpubLinkInfo

@end

@implementation EpubImageInfo

- (void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    
    _imageSize = CGSizeZero;
    UIImage *image = [UIImage imageWithContentsOfFile:_filePath];
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    CGFloat kRatio1 = w/h;
    CGFloat kRatio2 = [EpubReadStyle sharedInstance].showSize.width/[EpubReadStyle sharedInstance].showSize.height;
    if (kRatio1 > kRatio2) {
        _imageSize.width = [EpubReadStyle sharedInstance].showSize.width;
        _imageSize.height = _imageSize.width/kRatio1;
        if (_imageSize.height>[EpubReadStyle sharedInstance].showSize.height-40) {
            _imageSize.height = [EpubReadStyle sharedInstance].showSize.height-40;
            _imageSize.width = _imageSize.height*kRatio1;
        }
    }else{
        _imageSize.height = [EpubReadStyle sharedInstance].showSize.height-40;
        _imageSize.width = _imageSize.height*kRatio1;
    }
//    _imageSize = [ReadStyle sharedInstance].showSize;
}

@end

/* Callbacks */
static void deallocCallback( void* ref ){
    EpubImageInfo *imageInfo = (__bridge EpubImageInfo *)ref;
    imageInfo = nil;
}
static CGFloat ascentCallback( void *ref ){
    EpubImageInfo *imageInfo = (__bridge EpubImageInfo *)ref;
    return imageInfo.imageSize.height/1.00;
}
static CGFloat descentCallback( void *ref ){
    //    ImageInfo *imageInfo = (__bridge ImageInfo *)ref;
    return 0.0f;
}
static CGFloat widthCallback( void* ref ){
    EpubImageInfo *imageInfo = (__bridge EpubImageInfo *)ref;
    return imageInfo.imageSize.width/1.00;
}

@implementation EpubContent{
    NSMutableString *_content;
    NSAttributedString *_attributedText;
    NSMutableArray *_titles;
    NSMutableArray *_images;
    NSMutableArray *_links;
    NSString *_title;
    NSArray *_pages;
    
    UIColor *_textColor;
    UIFont *_font;
}

+ (instancetype)epubContentWithEpubChapter:(EpubChapter *)epubChapter{
    EpubContent *epubContent = [self new];
    epubContent.epubChapter = epubChapter;
    [epubContent parseContent];
    return epubContent;
}

- (NSString *)content{
    if (!_content) {
        [self parseContent];
    }
    return [_content copy];
}

- (NSArray<EpubImageInfo *> *)images{
    if (!_images) {
        [self parseContent];
    }
    return [_images copy];
}

- (NSArray<EpubLinkInfo *> *)links{
    if (!_links) {
        [self parseContent];
    }
    return [_links copy];
}

- (NSArray<EpubTitleInfo *> *)titles{
    if (!_titles) {
        [self parseContent];
    }
    return [_titles copy];
}

- (NSAttributedString *)attributedText{
    if (!_attributedText) {
        _attributedText = [self parseAttributedText];
    }else
        if (![EpubReadStyle isSameFont:_font color:_textColor]) {
            _attributedText = [self parseAttributedText];
        }
    return _attributedText;
}

- (NSArray<EpubPage *> *)pages{
    if (!_pages) {
        _pages = [self parsePages];
    }
    else
        if (![EpubReadStyle isSameFont:_font color:_textColor]) {
            _pages = [self parsePages];
        }
    return _pages;
}

- (NSAttributedString *)parseAttributedText{
    NSString *content = _content;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    if (content) {
        //正文的样式
        NSDictionary *attributes = [EpubReadStyle attributesForContent];
        NSAttributedString *string = [[NSAttributedString alloc]initWithString:content attributes:attributes];
        [attributedText appendAttributedString:string];
        
        //标题的样式
        for (EpubTitleInfo *titleInfo in _titles) {
            @autoreleasepool {
                NSDictionary *attributes = [EpubReadStyle attributesForTitle];
                [attributedText removeAttributes:@[NSForegroundColorAttributeName,NSFontAttributeName,NSKernAttributeName,NSParagraphStyleAttributeName] range:titleInfo.range];
                [attributedText addAttributes:attributes range:titleInfo.range];
            }
        }
        //链接的样式
        for (EpubLinkInfo *linkInfo in _links) {
            @autoreleasepool {
                NSDictionary *attributes = [EpubReadStyle attributesForLink];
                [attributedText removeAttributes:@[NSForegroundColorAttributeName,NSFontAttributeName,NSKernAttributeName,NSParagraphStyleAttributeName] range:linkInfo.range];
                [attributedText addAttributes:attributes range:linkInfo.range];
            }
        }
        //图片的样式
        for (EpubImageInfo *imageInfo in _images) {
            @autoreleasepool {
                CTRunDelegateCallbacks callbacks;
                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocCallback;
                
                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(imageInfo)); //设置代理
                NSDictionary *attrDictionaryDelegate =
                [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate, (NSString*)kCTRunDelegateAttributeName,nil];
                [attributedText removeAttributes:@[NSForegroundColorAttributeName,NSFontAttributeName,NSKernAttributeName,NSParagraphStyleAttributeName] range:NSMakeRange(imageInfo.location, 1)];
                [attributedText addAttributes:attrDictionaryDelegate range:NSMakeRange(imageInfo.location, 1)];
            }
        }
    }
    
    return [attributedText copy];
}

- (void)parseContent{
    _titles = [NSMutableArray array];
    _images = [NSMutableArray array];
    _content = [NSMutableString string];
    _links = [NSMutableArray array];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:_epubChapter.contentPath];
    //    使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    //获取根节点下的节点
    GDataXMLElement *contentEle = rootElement.children.lastObject;
    
    NSArray *eles = contentEle.children;
    
    for (GDataXMLElement *ele in eles) {
        [self parseContentWithXmlElement:ele titleSize:0];
    }
    
}

- (void)parseContentWithXmlElement:(GDataXMLElement *)xmlElement titleSize:(NSInteger)titleSize{
    NSString *chapterLastPath = _epubChapter.contentPath.stringByDeletingLastPathComponent;
    NSArray *subXmlElementArray = [xmlElement children];
    //判断是否是标题
    if ([xmlElement.name hasPrefix:@"h"]) {
        NSInteger subTitleSize = [[xmlElement.name substringWithRange:NSMakeRange(1, xmlElement.name.length-1)] integerValue];
        for (GDataXMLElement *subXmlElement in subXmlElementArray) {
            [self parseContentWithXmlElement:subXmlElement titleSize:subTitleSize];
        }

        return;
    }
    
    //判断是否是跳转链接
    if ([xmlElement.name isEqualToString:@"a"]&&[xmlElement attributeForName:@"href"]) {
        NSString *redirectionLink = [xmlElement stringValue];
        if (redirectionLink.length) {
            NSString *redirectionURL = [[xmlElement attributeForName:@"href"] stringValue];
            redirectionURL = absolutePath(chapterLastPath, redirectionURL);
            EpubLinkInfo *linkInfo = [[EpubLinkInfo alloc]init];
            linkInfo.range = NSMakeRange(_content.length, redirectionLink.length);
            linkInfo.redirectionURL = redirectionURL;
            [_links addObject:linkInfo];
            [_content appendFormat:@"%@\n",redirectionLink];
        }
        return;
    }


    //递归找到子节点
    if (subXmlElementArray.count) {
        for (GDataXMLElement *subXmlElement in subXmlElementArray) {
            [self parseContentWithXmlElement:subXmlElement titleSize:titleSize];
        }
        return;
    }
    //判断是否是图片
    if ([xmlElement.name isEqualToString:@"img"]||[xmlElement.name isEqualToString:@"image"]) {
        EpubImageInfo *imageInfo = [[EpubImageInfo alloc]init];
        NSString *filePath = [[xmlElement attributeForName:@"src"] stringValue];
        if (!filePath) {
            filePath = [[xmlElement attributeForName:@"xlink:href"] stringValue];
        }
        filePath = filePath.URLDecoded;
        imageInfo.filePath = absolutePath(chapterLastPath, filePath);
        //计算得到当前图片的range
        imageInfo.location = _content.length;
        [_images addObject:imageInfo];
        
        [_content appendFormat:@"\1\n"];//用ASCII的\1来代替图片位置
        return;
    }
    
    if (titleSize) {
        NSString *title = [NSString stringWithFormat:@"%@",[xmlElement stringValue]];
        if (title.length) {
            if (!self.title) {
                _title = title;
            }
            title = [NSString stringWithFormat:@"%@\n",title];
            EpubTitleInfo *titleInfo = [[EpubTitleInfo alloc]init];
            titleInfo.range = NSMakeRange(_content.length, title.length);
            titleInfo.size = [[xmlElement.name substringWithRange:NSMakeRange(1, xmlElement.name.length-1)] integerValue];
            [_titles addObject:titleInfo];
            [_content appendString:title];
        }
    }else{
        NSString *text = [NSString stringWithFormat:@"%@\n",xmlElement.stringValue];
        
        [_content appendString:text];
    }
}

- (NSArray<EpubPage *> *)parsePages{
    
    NSMutableArray *pageArray = [NSMutableArray array];
    
    CGMutablePathRef path = CGPathCreateMutable(); //2
    //文本显示区域
    CGRect textFrame = {16,40,[EpubReadStyle sharedInstance].showSize};
    
    CGPathAddRect(path, NULL, textFrame );
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    NSInteger textPos = 0;
    NSInteger page = 0;
    
    while (textPos < [self.attributedText length]) {
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        
        //use the column path
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        
        EpubPage *pageModel = [[EpubPage alloc]init];
        pageModel.epubContent = self;
        pageModel.currentPage = page;
        pageModel.frameRef = frame;
        pageModel.range = NSMakeRange(frameRange.location, frameRange.length);
        pageModel.attributeText = [self.attributedText attributedSubstringFromRange:pageModel.range];
        [self attachImagesWithEpubPage:pageModel];
        
        EpubPage *lastPage = pageArray.lastObject;
        if (lastPage) {
            pageModel.lastPage = lastPage;
            lastPage.nextPage = pageModel;
        }
        [pageArray addObject:pageModel];
        
        textPos += frameRange.length;
        page++;
        
        CFRelease(path);
        
    }
    CFRelease(framesetter);
    CFRelease(path);
    return [pageArray copy];
}

- (void)attachImagesWithEpubPage:(EpubPage *)pageModel{
    
    if (!self.images.count) {
        return;
    }
    
    //CTLine数组
    NSArray *lines = (NSArray *)CTFrameGetLines(pageModel.frameRef);
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(pageModel.frameRef, CFRangeMake(0, 0), origins);
    
    NSInteger imgIndex = 0;
    EpubImageInfo* imageInfo = [self.images objectAtIndex:imgIndex];
    //拿到图片的起始位置
    NSInteger imgLocation = imageInfo.location;
    
    CFRange frameRange = NSRangeTransferToCFRange(pageModel.range);
    while (imgLocation < frameRange.location) {
        imgIndex++;
        if (imgIndex>=[self.images count]) return; //quit if no images for this column
        imageInfo = [self.images objectAtIndex:imgIndex];
        imgLocation = imageInfo.location;
    }
    
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (__bridge CTLineRef)lineObj;
        CFRange lineRange = CTLineGetStringRange(line);
        if (CFRangeContainsLocation(lineRange, imgLocation)) {
            NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
            for (id runObj in runs) { //6
                CTRunRef run = (__bridge CTRunRef)runObj;
                CFRange runRange = CTRunGetStringRange(run);
                
                //获取每个图片的大小
                if (CFRangeContainsLocation(runRange, imgLocation)) {
                    CGRect runBounds;
                    CGFloat ascent;
                    CGFloat descent;
                    runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
                    runBounds.size.height = ascent + descent;
                    
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //可以省略，xOffset在此处恒为零
                    runBounds.origin.x = origins[lineIndex].x + 16 + xOffset;
                    runBounds.origin.y = origins[lineIndex].y + 40;
                    runBounds.origin.y -= descent;
                    
                    CGPathRef pathRef = CTFrameGetPath(pageModel.frameRef); //10
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    
                    CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x-16, colRect.origin.y - 40);
                    imageInfo.imgFrame = imgBounds;
                    
                    [pageModel.images addObject:imageInfo];
                    
                    imgIndex++;
                    if (imgIndex < [self.images count]) {
                        imageInfo = [self.images objectAtIndex: imgIndex];
                        imgLocation = imageInfo.location;
                    }
                    break;
                }
            }
            if (imgIndex >= [self.images count]) {
                break;
            }
            EpubImageInfo* imageInfo = [self.images objectAtIndex:imgIndex];
            if (imageInfo.location>NSRangeGetEndLocation(pageModel.range)) {
                break;
            }
        }
        lineIndex++;
    }
}

@end

@interface EpubChapter()



@end

@implementation EpubChapter{
    
}

-(EpubContent *)epubContent{
    if (!_epubContent) {
        _epubContent = [self parseEpubContent];
    }
    return _epubContent;
}

- (EpubContent *)parseEpubContent{
    if (_epubContent) {
        return _epubContent;
    }
    return [EpubContent epubContentWithEpubChapter:self];;
}


@end

@implementation EpubCatalog


@end




@implementation EpubParser

- (EpubCatalog *)parseToCatalogWithRootPath:(NSString *)rootPath{
    EpubCatalog *catalog = [[EpubCatalog alloc]init];
    catalog.rootPath = rootPath;
    catalog.opfPath = [self getOpfPathWithRootPath:rootPath];
    catalog.menifestItems = [self parseToManifestWithCatalog:catalog];
    catalog.chapters = [self parseToOrderChaptersWithCatalog:catalog];
    [self parseToDirectoryTreesWithEpubCatalog:catalog];
    _epubCatalog = catalog;
    return catalog;
}

- (void)parseToDirectoryTreesWithEpubCatalog:(EpubCatalog *)catalog{
    NSString *ncxPath = [self getNcxPathWithCatalog:catalog];
    catalog.ncxPath = ncxPath;
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:ncxPath];
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    //获取根节点下的节点
    NSArray *elements = rootElement.children;
    
//    EpubCatalog *catalog = [[EpubCatalog alloc]init];

    for (GDataXMLElement *ele in elements) {
        if ([ele.localName isEqualToString:@"docTitle"]) {
            catalog.bookName = ele.stringValue;
            continue;
        }
        if ([ele.localName isEqualToString:@"docAuthor"]) {
            catalog.bookAuthor = ele.stringValue;
            continue;
        }
        if ([ele.localName isEqualToString:@"navMap"]) {
            NSMutableArray *directory_trees = [NSMutableArray array];
            NSMutableArray *chapters_order = [NSMutableArray array];
            NSArray *navElements = ele.children;
            for (GDataXMLElement *navElement in navElements) {
                EpubChapter *chapter = [self parseToContentWithNavPoint:navElement epubCatalog:catalog hierarchy:0 chapters_order:chapters_order];
                if (chapter) {
                    [directory_trees addObject:chapter];
                    [chapters_order addObject:chapter];
                }
            }
            catalog.directory_trees = directory_trees;
            catalog.chapters_order = chapters_order;
            continue;
        }
    }
}

- (NSString *)getNcxPathWithCatalog:(EpubCatalog *)catalog{
    NSString *opfPath = catalog.opfPath?:[self getOpfPathWithRootPath:catalog.rootPath];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:opfPath];
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    GDataXMLElement *manifest = [rootElement elementsForLocalName:@"manifest" URI:rootElement.URI].firstObject;
    NSArray *items = [manifest elementsForLocalName:@"item" URI:manifest.URI];
    
    NSString *ncxPath = nil;
    for (GDataXMLElement *item in items) {//href
        if ([[[item attributeForName:@"media-type"] stringValue] isEqualToString:@"application/x-dtbncx+xml"]) {
            ncxPath = [[item attributeForName:@"href"] stringValue];
            return [opfPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:ncxPath];
        }
    }
    
    return ncxPath;
}


- (NSString *)getOpfPathWithRootPath:(NSString *)rootPath{
    NSString *path = [NSString stringWithFormat:@"%@/META-INF/container.xml",rootPath];
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:path];
    //    使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    
    GDataXMLElement *rootfiles = [[rootElement elementsForLocalName:@"rootfiles" URI:rootElement.URI] firstObject];
    NSString *opfPath = nil;
    for (GDataXMLElement *rootfile in rootfiles.children) {
        if ([[[rootfile attributeForName:@"media-type"] stringValue] isEqualToString:@"application/oebps-package+xml"]) {
            opfPath = [[rootfile attributeForName:@"full-path"] stringValue];
            break;
        }
    }
    return [rootPath stringByAppendingPathComponent:opfPath];
}


- (EpubChapter *)parseToContentWithNavPoint:(GDataXMLElement *)navPoint epubCatalog:(EpubCatalog *)catalog hierarchy:(NSInteger)hierarchy chapters_order:(NSMutableArray *)chapters_order{
    
    EpubChapter *chapter = nil;
//    NSString *contentPathId = [[navPoint attributeForName:@"id"] stringValue];
    NSString *src = [[[navPoint elementsForName:@"content"].firstObject attributeForName:@"src"] stringValue];
//    NSInteger playOrder = [[[navPoint attributeForName:@"playOrder"] stringValue] integerValue];
    NSString *ncxPath = catalog.ncxPath;
    NSString *chapterLastPath = [ncxPath stringByDeletingLastPathComponent];
    src = absolutePath(chapterLastPath, src);
    for (EpubChapter *subchapter in catalog.chapters) {
        
        if ([subchapter.contentPath isEqualToString:src]) {
            chapter = subchapter;
            break;
        }
    }
    
    
    
    if (!chapter) {
        return chapter;
    }
//    EpubChapter *chapter = [[EpubChapter alloc]init];
    chapter.hierarchy = hierarchy;
    chapter.epubCatalog = catalog;

    GDataXMLElement *navLabel = [navPoint elementsForName:@"navLabel"].lastObject;
    chapter.title = navLabel.stringValue;
    
    NSMutableArray<EpubChapter *> *subTitles = [NSMutableArray array];
    NSArray *subNavElements = [navPoint elementsForName:@"navPoint"];
    if(subNavElements.count){
        for (GDataXMLElement *subNavElement in subNavElements) {
            EpubChapter *subChapter = [self parseToContentWithNavPoint:subNavElement epubCatalog:catalog hierarchy:hierarchy+1 chapters_order:chapters_order];
            subChapter.parentChapter = chapter;
            if (subChapter) {
                [subTitles addObject:subChapter];
                [chapters_order addObject:subChapter];
            }
        }
    }
    chapter.subchapters = [subTitles copy];
    return chapter;
}

- (EpubChapter *)parseToChapterWithNavElement:(GDataXMLElement *)navElement epubCatalog:(EpubCatalog *)catalog hierarchy:(NSInteger)hierarchy{
    EpubChapter *chapter = [[EpubChapter alloc]init];
    chapter.hierarchy = hierarchy;
    chapter.epubCatalog = catalog;
    chapter.contentPathId = [[navElement attributeForName:@"id"] stringValue];
    chapter.playOrder = [[navElement attributeForName:@"playOrder"] stringValue].integerValue;
    GDataXMLElement *navLabel = [navElement elementsForName:@"navLabel"].lastObject;
    chapter.title = navLabel.stringValue;
    GDataXMLElement *content = [navElement elementsForName:@"content"].lastObject;
    
    chapter.contentPath = [[content attributes].lastObject stringValue];
    
    
    NSMutableArray<EpubChapter *> *subTitles = [NSMutableArray array];
    NSArray *subNavElements = [navElement elementsForName:@"navPoint"];
    if(subNavElements.count){
        for (GDataXMLElement *subNavElement in subNavElements) {
            EpubChapter *subChapter = [self parseToChapterWithNavElement:subNavElement epubCatalog:catalog hierarchy:hierarchy+1];
            subChapter.parentChapter = chapter;
            [subTitles addObject:subChapter];
        }
    }
    chapter.subchapters = [subTitles copy];
    return chapter;
}



- (NSArray<EpubChapter *> *)parseToOrderChaptersWithCatalog:(EpubCatalog *)catalog{
    NSArray *epubManifestArray = catalog.menifestItems.count?catalog.menifestItems:[self parseToManifestWithOpfPath:catalog.opfPath];
    NSMutableArray *chapterArray = [NSMutableArray array];
    NSMutableDictionary *pathDictionay = [[NSMutableDictionary alloc]init];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:catalog.opfPath];
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    GDataXMLElement *spine = [rootElement elementsForLocalName:@"spine" URI:rootElement.URI].firstObject;
    NSArray *itemrefs = [spine elementsForLocalName:@"itemref" URI:spine.URI];
    NSInteger playOrder = 0;
    for (GDataXMLElement *itemref in itemrefs) {
        
        NSString *contentPathId = [[itemref attributeForName:@"idref"] stringValue];
        EpubChapter *epubChapter = nil;
        
        for (EpubChapter *epubManifest in epubManifestArray) {
            if ([contentPathId isEqualToString:epubManifest.contentPathId]) {
                epubChapter = epubManifest;
                epubChapter.playOrder = playOrder++;
                break;
            }
        }
        
        EpubChapter *lastEpubChapter = chapterArray.lastObject;
        if (lastEpubChapter) {
            epubChapter.lastChapter = lastEpubChapter;
            lastEpubChapter.nextChapter = epubChapter;
        }
        if (epubChapter) {
            [chapterArray addObject:epubChapter];
            NSString *key = [NSString stringWithFormat:@"%ld",epubChapter.contentPath.hash];
            [pathDictionay setValue:epubChapter forKey:key];
        }
    }
    
    catalog.pathDictionary = [pathDictionay copy];
    
    return [chapterArray copy];
}



- (NSArray<EpubChapter *> *)parseToManifestWithCatalog:(EpubCatalog *)catalog{
    NSString *opfLastPath = catalog.opfPath.stringByDeletingLastPathComponent;
    NSMutableArray *epubManifestArray = [NSMutableArray array];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:catalog.opfPath];
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    GDataXMLElement *manifest = [rootElement elementsForLocalName:@"manifest" URI:rootElement.URI].firstObject;
    NSArray *items = [manifest elementsForLocalName:@"item" URI:manifest.URI];
    for (GDataXMLElement *item in items) {
        if ([[[item attributeForName:@"media-type"] stringValue] isEqualToString:@"application/xhtml+xml"]) {
            EpubChapter *epubManifest = [[EpubChapter alloc]init];
            epubManifest.epubCatalog = catalog;
            NSString *contentPath = [[item attributeForName:@"href"] stringValue];
            epubManifest.contentPath = [opfLastPath stringByAppendingPathComponent:contentPath];
            epubManifest.contentPathId = [[item attributeForName:@"id"] stringValue];
            [epubManifestArray addObject:epubManifest];
        }
    }
    
    return [epubManifestArray copy];
}

- (NSArray<EpubChapter *> *)parseToManifestWithOpfPath:(NSString *)opfPath{
    NSString *opfLastPath = opfPath.stringByDeletingLastPathComponent;
    NSMutableArray *epubManifestArray = [NSMutableArray array];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:opfPath];
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    GDataXMLElement *manifest = [rootElement elementsForLocalName:@"manifest" URI:rootElement.URI].firstObject;
    NSArray *items = [manifest elementsForLocalName:@"item" URI:manifest.URI];
    for (GDataXMLElement *item in items) {
        if ([[[item attributeForName:@"media-type"] stringValue] isEqualToString:@"application/xhtml+xml"]) {
            EpubChapter *epubManifest = [[EpubChapter alloc]init];
            NSString *contentPath = [[item attributeForName:@"href"] stringValue];
            epubManifest.contentPath = [opfLastPath stringByAppendingPathComponent:contentPath];
            epubManifest.contentPathId = [[item attributeForName:@"id"] stringValue];
            [epubManifestArray addObject:epubManifest];
        }
    }
    
    return [epubManifestArray copy];
}

- (void)parseProgressCompletion:(void(^)(NSInteger totalLength))completion{
    dispatch_async(parse_progress_serial_queue(), ^{
        NSInteger totalLength = 0;
        for (EpubChapter *chapter in _epubCatalog.chapters) {
            @autoreleasepool {
                EpubContent *epubContent = chapter.parseEpubContent;
                chapter.rangeInTotal = NSMakeRange(totalLength, epubContent.content.length);
                totalLength += epubContent.content.length;
            }
        }
        _epubCatalog.totalLength = totalLength;
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion?:completion(totalLength);
        });
    });
}

#pragma mark - 以下方法暂时废弃
#if 0

//获取.opf中的.ncx路径
- (NSString *)getNcxPathWithRootPath:(NSString *)rootPath{
    NSString *opfPath = [self getOpfPathWithRootPath:rootPath];
    opfPath = [NSString stringWithFormat:@"%@/%@",rootPath,opfPath];
    //获取工程目录的opf文件
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:opfPath];
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    //获取根节点下的节点
    GDataXMLElement *manifest = [[rootElement elementsForLocalName:@"manifest" URI:rootElement.URI] lastObject];
    
    NSArray *items = [manifest elementsForLocalName:@"item" URI:rootElement.URI];
    
    NSString *ncxPath = nil;
    for (GDataXMLElement *item in items) {//href
        if ([[[item attributeForName:@"media-type"] stringValue] isEqualToString:@"application/x-dtbncx+xml"]) {
            ncxPath = [[item attributeForName:@"href"] stringValue];
            return [opfPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:ncxPath];
        }
    }
    
    return ncxPath;
}

//解析epub里面的html文件中的文字和图片
- (EpubContent *)parseToContentWithEpubChapter:(EpubChapter *)epubChapter rootPath:(NSString *)rootPath{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",rootPath,epubChapter.contentPath];
    //获取工程目录的xml文件
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    
    //获取根节点下的节点
    GDataXMLElement *content = rootElement.children.lastObject;
    NSArray *eles = content.children;
    
    EpubContent *epubContent = [[EpubContent alloc]init];
    epubContent.epubChapter = epubChapter;
    for (GDataXMLElement *ele in eles) {
        [self parseWithEpubContent:epubContent xmlElement:ele];
    }
    return epubContent;
}

- (NSArray<EpubChapter *> *)parseToOrderChaptersWithEpubCatalog:(EpubCatalog *)epubCatalog{
    
    NSArray *menifestItems = epubCatalog.menifestItems;
    NSMutableArray *chapterArray = [NSMutableArray array];
    //获取工程目录的opf文件
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:epubCatalog.opfPath];
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    //获取根节点下的节点
    GDataXMLElement *spine = [[rootElement elementsForName:@"spine"] lastObject];
    NSArray *itemrefs = [spine elementsForName:@"itemref"];
    NSInteger playOrder = 0;
    for (GDataXMLElement *itemref in itemrefs) {
        EpubChapter *epubChapter = [[EpubChapter alloc]init];
        epubChapter.playOrder = playOrder++;
        epubChapter.contentPathId = [[itemref attributeForName:@"idref"] stringValue];
        for (EpubChapter *epubManifest in menifestItems) {
            if ([epubChapter.contentPathId isEqualToString:epubManifest.contentPathId]) {
                epubChapter.contentPath = epubManifest.contentPath;
                break;
            }
        }
        
        EpubChapter *lastEpubChapter = chapterArray.lastObject;
        if (lastEpubChapter) {
            epubChapter.lastChapter = lastEpubChapter;
            lastEpubChapter.nextChapter = epubChapter;
        }
        [chapterArray addObject:epubChapter];
    }
    
    return [chapterArray copy];
    
}

//解析epub目录
- (EpubCatalog *)parseToCatalogWithNcxPath:(NSString *)ncxPath{
    //获取工程目录的ncx文件
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:ncxPath];
    
    //使用NSData对象初始化
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData  options:0 error:nil];
    
    //获取根节点
    GDataXMLElement *rootElement = [doc rootElement];
    
    //获取根节点下的节点
    NSArray *elements = rootElement.children;
    
    EpubCatalog *catalog = [[EpubCatalog alloc]init];
    
    for (GDataXMLElement *ele in elements) {
        if ([ele.name isEqualToString:@"docTitle"]) {
            catalog.bookName = ele.stringValue;
            continue;
        }
        if ([ele.name isEqualToString:@"docAuthor"]) {
            catalog.bookAuthor = ele.stringValue;
            continue;
        }
        if ([ele.name isEqualToString:@"navMap"]) {
            NSMutableArray *directory_trees = [NSMutableArray array];
            NSArray *navElements = ele.children;
            for (GDataXMLElement *navElement in navElements) {
                EpubChapter *chapter = [self parseToContentWithNavElement:navElement epubCatalog:catalog hierarchy:0];
                [directory_trees addObject:chapter];
            }
            catalog.directory_trees = directory_trees;
            
            continue;
        }
    }
    
    catalog.chapters = [self parseToOrderChaptersWithEpubCatalog:catalog];
    
    return catalog;
}

//解析epub章节顺序
- (NSArray<EpubChapter *> *)parseToOrderChaptersWithOpfPath:(NSString *)opfPath{
    
    NSArray *epubManifestArray = [self parseToManifestWithOpfPath:opfPath];
    NSMutableArray *chapterArray = [NSMutableArray array];
    GDataXMLElement *spine = [self xmlElementWithLocalName:@"spine" xmlPath:opfPath];
    NSArray *itemrefs = [spine elementsForLocalName:@"itemref" URI:spine.URI];
    NSInteger playOrder = 0;
    for (GDataXMLElement *itemref in itemrefs) {
        
        NSString *contentPathId = [[itemref attributeForName:@"idref"] stringValue];
        EpubChapter *epubChapter = nil;
        
        for (EpubChapter *epubManifest in epubManifestArray) {
            if ([contentPathId isEqualToString:epubManifest.contentPathId]) {
                epubChapter = epubManifest;
                epubChapter.playOrder = playOrder++;
                break;
            }
        }
        
        EpubChapter *lastEpubChapter = chapterArray.lastObject;
        if (lastEpubChapter) {
            epubChapter.lastChapter = lastEpubChapter;
            lastEpubChapter.nextChapter = epubChapter;
        }
        if (epubChapter) {
            [chapterArray addObject:epubChapter];
        }
    }
    
    return [chapterArray copy];
}

#endif


@end
