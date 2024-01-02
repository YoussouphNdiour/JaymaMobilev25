importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  databaseURL: "https://jayma-88682-default-rtdb.europe-west1.firebasedatabase.app/",
  authDomain: "jayma-88682.firebaseapp.com",
  projectId: "jayma-88682",
  storageBucket: "jayma-88682.appspot.com",
  messagingSenderId: "484779040551",
  appId: "1:484779040551:web:fcc1614cfd2dfd52341302",
  measurementId: "G-FNV6D046C0",
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});