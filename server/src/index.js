import RtmpServer from 'rtmp-server';
import socketIo from 'socket.io';
import { createServer } from 'http';

const rtmpServer = new RtmpServer();

rtmpServer.on('error', (err) => {
  throw err;
});

rtmpServer.on('client', (client) => {
  client.on('connect', () => {
    console.log('connect', client.app);
  });

  client.on('play', ({ streamName }) => {
    console.log('PLAY', streamName);
  });

  client.on('publish', ({ streamName }) => {
    console.log('PUBLISH', streamName);
  });

  client.on('stop', () => {
    console.log('rmtp client disconnected');
  });
});

rtmpServer.listen(1935);

const server = createServer();
const io = socketIo(server);

let isAsking = false;
const socketsPlaying = [];
const socketsToBeAdded = [];

const sendQuestion = ({ text, options, correctAnswer }) => {
  isAsking = true;
  const votes = [0, 0, 0];

  socketsPlaying.forEach((socket) => {
    socket.emit('question', { text, options }, (chosenAnswer) => {
      votes[chosenAnswer] += 1;
    });
  });

  setTimeout(() => {
    socketsPlaying.forEach((socket) => {
      socket.emit('answer', { votes, correctAnswer });
    });

    const socketsToBeAddedLength = socketsToBeAdded.length;
    for (let idx = 0; idx < socketsToBeAddedLength; idx += 1) {
      const socket = socketsToBeAdded.pop();
      socketsPlaying.push(socket);
    }
    isAsking = false;
  }, 20000);
};

io.on('connection', (socket) => {
  (isAsking ? socketsToBeAdded : socketsPlaying).push(socket);

  // setTimeout(() => {
  //   sendQuestion({
  //     text: 'who was the first prez',
  //     options: ['me', 'u', 'a dog named blue'],
  //     correctAnswer: 2,
  //   });
  // }, 2000);
});

server.listen(8080);
