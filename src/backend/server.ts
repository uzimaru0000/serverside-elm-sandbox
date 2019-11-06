import http from 'http';
import { Repository } from './repository';
import { Todo } from './model';
import { Sub, Cmd } from '../@types/elm'

export default interface Elm {
    ports: {
        request: Sub;
        response: Cmd<[number, any]>;

        requestTodo: Cmd<string>;
        requestAllTodo: Cmd<[]>;
        storeTodo: Cmd<Todo>;
        updateTodo: Cmd<[string, Todo]>;
        deleteTodo: Cmd<string>;

        result: Sub<boolean>;
        getTodo: Sub<Todo>;
        getAllTodo: Sub<Todo[]>;
    }
}

export default class Server {
    static response: http.ServerResponse;

    server: http.Server;

    constructor(app: Elm, repo: Repository<Todo, string>) {
        this.server = http.createServer((req, res) => {
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader(
                'Access-Control-Allow-Headers',
                'content-type'
            );
            res.setHeader(
                'Access-Control-Allow-Methods',
                'GET, POST, PUT, DELETE'
            );
            res.setHeader(
                'Content-Type',
                'application/json'
            );
            Server.response = res;

            if (req.method === "OPTIONS") {
                res.statusCode = 200;
                res.end();
                return;
            };

            if (req.method === "GET") {
                const data = {
                    url: `http://${req.headers.host}${req.url}`,
                    method: req.method,
                    header: req.headers,
                    body: null
                };
                app.ports.request.send(data);
            } else {
                let body = [] as String[];

                req.on('data', chunk => body.push(chunk));
                req.on('end', () => {
                    const data = { url: `http://${req.headers.host}${req.url}`,
                        method: req.method,
                        header: req.headers,
                        body: JSON.parse(body.length > 0 ? body.join("") : null)
                    };
                    app.ports.request.send(data);
                });
            }
        });

        app.ports.response.subscribe(([status, msg]) => {
            Server.response.statusCode = status;
            Server.response.write(JSON.stringify(msg));
            Server.response.end();
        });

        this.effect(app, repo);
    }

    effect(app: Elm, repo: Repository<Todo, string>) {
        app.ports.requestTodo.subscribe(id => {
            app.ports.getTodo.send(repo.Get(id));
        });

        app.ports.requestAllTodo.subscribe(_ => {
            app.ports.getAllTodo.send(repo.GetAll());
        });

        app.ports.storeTodo.subscribe((todo: Todo) => {
            app.ports.result.send(repo.Store(todo));
        });

        app.ports.updateTodo.subscribe(([id, todo]) => {
            app.ports.result.send(repo.Update(id, todo));
        });

        app.ports.deleteTodo.subscribe(id => {
            app.ports.result.send(repo.Delete(id));
        });
    }

    listen(port: number) {
        this.server.listen(port);
    }
}