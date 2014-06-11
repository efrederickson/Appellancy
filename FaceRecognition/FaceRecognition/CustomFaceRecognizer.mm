#import "CustomFaceRecognizer.h"
#import "OpenCVData.h"
#import <opencv2/highgui/cap_ios.h>

@implementation CustomFaceRecognizer

- (id)init
{
    self = [super init];
    if (self) {
        [self loadDatabase];
    }
    
    return self;
}

- (id)initWithEigenFaceRecognizer
{
    self = [self init];
    _model = cv::createEigenFaceRecognizer();
    
    [self loadModel];
    
    return self;
}

- (id)initWithFisherFaceRecognizer
{
    self = [self init];
    _model = cv::createFisherFaceRecognizer();
    
    [self loadModel];
    
    return self;
}

- (id)initWithLBPHFaceRecognizer
{
    self = [self init];
    _model = cv::createLBPHFaceRecognizer(1, 8, 16, 16);
    
    [self loadModel];
    
    return self;
}

-(void) dealloc
{
    sqlite3_close(_db);
    
#if !__has_feature(objc_arc)
    [super dealloc];
#else
    //Usually do nothing...
#endif
}

-(void) saveModel
{
    [self trainModel];
    //NSString *p = [self recognizerPath];
    
    //NSString *p = @"/tmp/test.xml";
    
    //cv::FileStorage fs([p cStringUsingEncoding:NSUTF8StringEncoding], cv::FileStorage::WRITE);
    
    //_model->save(fs);
    
    //fs.release();
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *vocabPath = [docs stringByAppendingPathComponent:@"vocabulary.xml"];
    cv::FileStorage fs([vocabPath UTF8String], cv::FileStorage::WRITE);
    @try {
        try {
            _model->save(fs);
        }
        catch (NSException *exception) {
            NSLog(@"exception");
        }
        catch (const std::exception& e)
        {
            
        } catch (const std::string& ex) {
            // ...
        } catch (...) {
            // ...
        }
    }
    @catch (NSException *exception) {
        
    }
    

    fs.release();

}

-(void) loadModel
{
    // Load FaceRecognizer data from file if it exists
    NSString *rPath = [self recognizerPath];
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:rPath isDirectory:&isDir])
    {
        _model->load([rPath cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (void)loadDatabase
{
    // Load actual DB
    
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:[self dbPath]];
    
    if (sqlite3_open([[self dbPath] UTF8String], &_db) != SQLITE_OK) {
        NSLog(@"Appellancy: Cannot open the database.");
    }
    
    if (!existed)
        [self createTablesIfNeeded];
    
    /*const char *renameSql = "UPDATE people SET name='Deny' WHERE id=1;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, renameSql, -1, &statement, nil) == SQLITE_OK) {
    }
    sqlite3_finalize(statement);*/
}

- (NSString *)dbPath
{
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Appellancy/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    return [filePath stringByAppendingPathComponent:@"recognition-data.sqlite"];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentDirectory = [paths objectAtIndex:0];
    //return [documentDirectory stringByAppendingPathComponent:@"recognition-data.sqlite"];
}

- (NSString *)recognizerPath
{
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Appellancy/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    return [filePath stringByAppendingPathComponent:@"recognizer-data.xml"];
}

- (int)newPersonWithName:(NSString *)name
{
    const char *newPersonSQL = "INSERT INTO people (name) VALUES (?)";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, newPersonSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
    
    return (int)sqlite3_last_insert_rowid(_db);
}

- (NSMutableArray *)getAllPeople
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    const char *findPeopleSQL = "SELECT id, name FROM people ORDER BY name";
    sqlite3_stmt *statement;
    
    //int index = 0;
    
    if (sqlite3_prepare_v2(_db, findPeopleSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSNumber *personID = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
            NSString *personName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            //NSNumber *person_ID = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
            
            //[results insertObject:@{@"id": personID, @"name": personName} atIndex:index++];
            
            [results addObject:@{@"id": personID, @"name": personName,/* @"person_id": person_ID*/}];
        }
    }
    
    sqlite3_finalize(statement);
    
    return results;
}

- (BOOL)trainModel
{
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    const char* selectSQL = "SELECT person_id, image FROM images";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, selectSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int personID = sqlite3_column_int(statement, 0);
            
            // First pull out the image into NSData
            int imageSize = sqlite3_column_bytes(statement, 1);
            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
            
            // Then convert NSData to a cv::Mat. Images are standardized into 300x300
            cv::Mat faceData = [OpenCVData dataToMat:imageData
                                               width:[NSNumber numberWithInt:300]
                                              height:[NSNumber numberWithInt:300]];
            
            // Put this image into the model
            images.push_back(faceData);
            labels.push_back(personID);
        }
    }
    
    sqlite3_finalize(statement);
    
    if (images.size() > 0 && labels.size() > 0) {
        _model->train(images, labels);
        return YES;
    }
    else {
        return NO;
    }
}

- (void)forgetAllFacesForPersonID:(int)personID
{
    const char* deleteSQL = "DELETE FROM images WHERE person_id = ?";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, deleteSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, personID);
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
}

-(void)removePerson:(int)personID
{
    [self forgetAllFacesForPersonID:personID];
    const char* del = "DELETE FROM people WHERE id = ?";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, del, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, personID);
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
}

- (void)learnFace:(cv::Rect)face ofPersonID:(int)personID fromImage:(cv::Mat&)image
{
    cv::Mat faceData = [self pullStandardizedFace:face fromImage:image toGray:NO];
    NSData *serialized = [OpenCVData serializeCvMat:faceData];
    
    const char* insertSQL = "INSERT INTO images (person_id, image) VALUES (?, ?)";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, insertSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, personID);
        sqlite3_bind_blob(statement, 2, serialized.bytes, (int)serialized.length, SQLITE_TRANSIENT);
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
}

- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image toGray:(BOOL)toGray
{
    toGray = YES;
    // Pull the grayscale face ROI out of the captured image
    cv::Mat onlyTheFace;
    cv::cvtColor(image(face), onlyTheFace, CV_RGB2GRAY);
    
    cv::resize(onlyTheFace, onlyTheFace, cv::Size(300, 300), 0, 0);
    
    if (!toGray)
        cv::cvtColor(onlyTheFace, onlyTheFace, CV_GRAY2RGB);
    
    return onlyTheFace;
}

- (NSDictionary *)recognizeFace:(cv::Rect)face inImage:(cv::Mat&)image
{
    int predictedLabel = -1;
    double confidence = 0.0;
    _model->predict([self pullStandardizedFace:face fromImage:image toGray:YES], predictedLabel, confidence);
    
    NSString *personName = @"";
    
    // If a match was found, lookup the person's name
    if (predictedLabel != -1) {
        const char* selectSQL = "SELECT name FROM people WHERE id = ?";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(_db, selectSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, predictedLabel);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                personName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            }
        }
        
        sqlite3_finalize(statement);
    }
    
    return @{
        @"personID": [NSNumber numberWithInt:predictedLabel],
        @"personName": personName,
        @"confidence": [NSNumber numberWithDouble:confidence]
    };
}

- (void)createTablesIfNeeded
{
    // People table
    const char *peopleSQL = "CREATE TABLE IF NOT EXISTS people ("
                            "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
                            "'name' text NOT NULL)";
    
    if (sqlite3_exec(_db, peopleSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"Appellancy: The people table could not be created.");
    }
    
    // Images table
    const char *imagesSQL = "CREATE TABLE IF NOT EXISTS images ("
                            "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
                            "'person_id' integer NOT NULL, "
                            "'image' blob NOT NULL)";
    
    if (sqlite3_exec(_db, imagesSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"Appellancy: The images table could not be created.");
    }
    
    const char *loadSQL = "ATTACH DATABASE '/Applications/Appellancy.app/recognition-data-default.sqlite' AS attachedDB";
    if (sqlite3_exec(_db, loadSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"Appellancy: The database could not be loaded.");
    }
    
    const char *denySQL = "INSERT INTO main.people (name) SELECT name FROM attachedDB.people";
    if (sqlite3_exec(_db, denySQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"Appellancy: The people table could not be injected.");
    }
    
    denySQL = "INSERT INTO main.images (person_id, image) SELECT person_id,image FROM attachedDB.images";
    if (sqlite3_exec(_db, denySQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"Appellancy: The images table could not be injected.");
    }
}

-(int) imageCountForPerson:(int)person
{
    int count = 0;
    
    const char* selectSQL = "SELECT person_id, image FROM images";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, selectSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int personID = sqlite3_column_int(statement, 0);
            if (personID == person)
                count++;
        }
    }
    
    sqlite3_finalize(statement);
    
    return count;
}
@end
