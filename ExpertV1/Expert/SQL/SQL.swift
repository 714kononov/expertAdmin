import SQLite3
import UIKit

class SQL: UIViewController {
    var db: OpaquePointer?
    
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("expert.sqlite")
        
        print("DB path:\(fileURL)")
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Ошибка при открытии базы данных")
            return nil
        } else {
            print("База данных успешно открыта!")
            return db
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Открываем базу данных
        db = openDatabase()
        
        // Создаем таблицы
        if db != nil { // Убедимся, что база данных была успешно открыта
            createTables()
        }
    }
    
    func createTables() {
        // Создаем таблицу users
        let createUsersTableString = """
        CREATE TABLE IF NOT EXISTS users(
        Id INTEGER PRIMARY KEY,
        Name TEXT,
        password TEXT,
        phone TEXT);
        """
        
        // Создаем таблицу orders
        let createOrdersTableString = """
        CREATE TABLE IF NOT EXISTS orders(
            id INTEGER PRIMARY KEY,
            UserName TEXT,
            date TEXT,
            UserText TEXT,
            photo1 TEXT,
            photo2 TEXT,
            photo3 TEXT,
            photo4 TEXT,
            typeExpertiz INTEGER,
            pay INTEGER,
            answerExpert TEXT,
            result INT
        );
        """

        createTable(query: createUsersTableString)
        createTable(query: createOrdersTableString)
    }
    
    func createTable(query: String) {
        var createTableStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Таблица успешно создана.")
            } else {
                print("Таблица не была создана.")
            }
        } else {
            print("Ошибка при подготовке SQL-запроса.")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    // Функция для сохранения данных в таблицу users
    func safeToDB(username: String, password: String, phone: String) {
        let insertStatementString = "INSERT INTO users (Name, password, phone) VALUES (?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (password as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (phone as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Данные успешно сохранены.")
            } else {
                print("Не удалось сохранить данные.")
            }
        } else {
            print("Ошибка при подготовке SQL-запроса для вставки данных.")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func saveOrder(userName: String, date: String, userText: String, photo1: Data?, photo2: Data?, photo3: Data?, photo4: Data?, typeExpertiz: Int, pay: Int, result: Int) {
        let insertStatementString = """
        INSERT INTO orders (UserName, date, UserText, photo1, photo2, photo3, photo4, typeExpertiz, pay, result)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (userName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (date as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (userText as NSString).utf8String, -1, nil)
            
            if let photo1 = photo1 {
                sqlite3_bind_blob(insertStatement, 4, (photo1 as NSData).bytes, Int32(photo1.count), nil)
            } else {
                sqlite3_bind_null(insertStatement, 4)
            }
            
            if let photo2 = photo2 {
                sqlite3_bind_blob(insertStatement, 5, (photo2 as NSData).bytes, Int32(photo2.count), nil)
            } else {
                sqlite3_bind_null(insertStatement, 5)
            }
            
            if let photo3 = photo3 {
                sqlite3_bind_blob(insertStatement, 6, (photo3 as NSData).bytes, Int32(photo3.count), nil)
            } else {
                sqlite3_bind_null(insertStatement, 6)
            }
            
            if let photo4 = photo4 {
                sqlite3_bind_blob(insertStatement, 7, (photo4 as NSData).bytes, Int32(photo4.count), nil)
            } else {
                sqlite3_bind_null(insertStatement, 7)
            }
            
            sqlite3_bind_int(insertStatement, 8, Int32(typeExpertiz))
            sqlite3_bind_int(insertStatement, 9, Int32(pay))
            sqlite3_bind_int(insertStatement, 10, Int32(result))
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Заказ успешно сохранен.")
            } else {
                print("Не удалось сохранить заказ.")
            }
        } else {
            print("Ошибка при подготовке SQL-запроса для вставки заказа.")
        }
        
        sqlite3_finalize(insertStatement)
    }


    
    // Функция для проверки авторизации
    func checkAuthorization(name: String, password: String) -> Int {
        let queryStatementString = "SELECT * FROM users WHERE Name = ? AND password = ?;"
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, (password as NSString).utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                print("Пользователь найден.")
                sqlite3_finalize(queryStatement)
                return 0 // Пользователь существует
            } else {
                print("Пользователь не найден.")
                sqlite3_finalize(queryStatement)
                return 1 // Пользователь не существует
            }
        } else {
            print("Ошибка при подготовке SQL-запроса для проверки авторизации.")
            sqlite3_finalize(queryStatement)
            return 1 // Возвращаем 1 в случае ошибки
        }
    }
}
