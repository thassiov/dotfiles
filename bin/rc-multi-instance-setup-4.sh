#!/usr/bin/env node
const { spawn } = require('child_process');

let port = '3034';
if (process.argv.length > 2) {
    port = process.argv[2];
}

console.log(`A new Rocket.Chat instance is running at https://localhost:${port}`);
const ROCKETCHAT_BUILD_PATH = `${ process.cwd() }/.meteor/local/build`;

const env = {
  ...process.env,
  NODE_ENV:'production',
  INSTANCE_IP:'127.0.0.1',
  PORT:port,
  ROOT_URL:`http://localhost:${port}`,
  MONGO_URL:'mongodb://localhost:3001/meteor',
  MONGO_OPLOG_URL:'mongodb://localhost:3001/local',
}

const rc_instance = spawn('nodemon', ['main.js'], {
  env,
  cwd: ROCKETCHAT_BUILD_PATH,
});

rc_instance.stdout.on('data', function (data) {
  console.log('stdout: ' + data.toString());
});

rc_instance.stderr.on('data', function (data) {
  console.log('stderr: ' + data.toString());
});

rc_instance.on('exit', function (code) {
  console.log('child process exited with code ' + code.toString());
});
