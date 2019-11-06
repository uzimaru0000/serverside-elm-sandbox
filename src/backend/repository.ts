export interface Repository<T, ID> {
    Store(data: T): boolean
    GetAll(): T[]
    Get(id: ID): T
    Update(id: ID, data: T): boolean
    Delete(id: ID): boolean
}

