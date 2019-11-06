// @ts-ignore
import { Elm } from '../Elm/Backend/Main.elm';
import Server from './server';
import { MockDB } from './model'

const app = Elm.Backend.Main.init();
const repo = new MockDB();

const server = new Server(app, repo);
server.listen(3000);
