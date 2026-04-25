importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyARTTQz-SuInDbNMmE2v8KwltAFc9pOCEM',
  appId: '1:6540576529:web:9a856acf4c9172d785eeb0',
  messagingSenderId: '6540576529',
  projectId: 'alzajeltravel-e67e1',
  authDomain: 'alzajeltravel-e67e1.firebaseapp.com',
  storageBucket: 'alzajeltravel-e67e1.firebasestorage.app',
});

const messaging = firebase.messaging();

function pickText(data, arKey, enKey, fallbackKey) {
  const lang = (self.navigator && self.navigator.language || 'en').toLowerCase();
  if (lang.startsWith('ar')) {
    return data[arKey] || data[enKey] || data[fallbackKey] || '';
  }
  return data[enKey] || data[arKey] || data[fallbackKey] || '';
}

messaging.onBackgroundMessage((payload) => {
  const data = payload.data || {};
  const title =
    pickText(data, 'title_ar', 'title_en', 'title') ||
    (payload.notification && payload.notification.title) ||
    'Alzajel Travel';
  const body =
    pickText(data, 'body_ar', 'body_en', 'body') ||
    (payload.notification && payload.notification.body) ||
    '';
  const image = data.image || (payload.notification && payload.notification.image);

  self.registration.showNotification(title, {
    body,
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    image: image || undefined,
    data,
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const data = event.notification.data || {};
  const target = data.route && data.route.trim() ? data.route : '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ('focus' in client) {
          client.focus();
          if ('navigate' in client) return client.navigate(target);
          return undefined;
        }
      }
      if (clients.openWindow) return clients.openWindow(target);
      return undefined;
    }),
  );
});
