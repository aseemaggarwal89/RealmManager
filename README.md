# RealmManager
Realm Database using multi-threading iOS in Swift

Created this project to demostrate the write way to use Realm Database instance that provide thread safe facility.
Write Queue is used to execute write database operation to support heavy operation and avoid main thread from blocking.
Read Queue is used to execute read database operation to fetch large data using filtering.
Realm Database instance should be used properly to avoid crashes realted to thread.

Therefore created a layered structure using abstraction and dependency injection to facilite RealmDatabaseService instance 
that could execute database operation in a thread safe manner and prevent UI thread from blocking.
