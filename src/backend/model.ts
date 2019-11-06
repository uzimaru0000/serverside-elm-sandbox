import { Repository } from "./repository";

export interface Todo {
    id: string;
    title: string
    ts: number
    done: boolean
}

export class MockDB implements Repository<Todo, string> {
    private db: { [key: string]: Todo };

    constructor() {
        this.db = {};
    }

    GetAll() {
        return Object.values(this.db);
    }

    Get(id: string) {
        return this.db[id];
    }

    Store(data: Todo) {
        const id = Math.random().toString(36).substr(2, 8);
        this.db[id] = { ...data, id };
        return true;
    }

    Update(id: string, data: Todo) {
        this.db[id] = { ...data, id };
        return true;
    }

    Delete(id: string) {
        delete this.db[id];
        return true;
    }
}
