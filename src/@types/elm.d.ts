export type Cmd<T = any> = {
    subscribe: (func: (msg: T) => void) => void;
    unsubscribe: (func: (msg: T) => void) => void;
}

export type Sub<T = any> = {
    send: (data: T) => void;
}