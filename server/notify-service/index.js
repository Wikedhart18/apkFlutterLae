import express from 'express';
import cors from 'cors';
import admin from 'firebase-admin';

// Expect FIREBASE_SERVICE_ACCOUNT to contain the JSON string
const svcJson = process.env.FIREBASE_SERVICE_ACCOUNT;
if (!svcJson) {
  console.error(
    'FIREBASE_SERVICE_ACCOUNT env var missing. Paste your service-account JSON there.',
  );
  process.exit(1);
}
const serviceAccount = JSON.parse(svcJson);

if (admin.apps.length === 0) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id,
  });
}
const db = admin.firestore();
const messaging = admin.messaging();

const app = express();
app.use(cors());
app.use(express.json());

const API_KEY = process.env.API_KEY || '';

app.get('/health', (_req, res) => {
  res.json({ ok: true, ts: new Date().toISOString() });
});

// POST /notifyPackageStatus
// body: { clienteId, packageId, estado, title?, body? }
app.post('/notifyPackageStatus', async (req, res) => {
  try {
    if (!API_KEY || req.headers['x-api-key'] !== API_KEY) {
      return res.status(401).json({ error: 'unauthorized' });
    }
    const { clienteId, packageId, estado, title, body } = req.body || {};
    if (!clienteId || !packageId) {
      return res.status(400).json({ error: 'missing params' });
    }

    const tokenSnap = await db
      .collection('users')
      .doc(String(clienteId))
      .collection('fcmTokens')
      .get();
    const tokens = tokenSnap.docs.map((d) => d.id).filter(Boolean);
    if (tokens.length === 0) {
      return res.json({ message: 'no tokens', sent: 0 });
    }

    const notifTitle =
      title ||
      (estado === 'entregado'
        ? 'Tu paquete fue entregado'
        : 'Actualización de tu envío');
    const notifBody =
      body ||
      (estado ? `Estado: ${estado} (${packageId})` : `Paquete ${packageId}`);

    const resp = await messaging.sendEachForMulticast({
      notification: { title: notifTitle, body: notifBody },
      data: {
        type: 'PACKAGE_STATUS',
        packageId: String(packageId),
        estado: String(estado || ''),
        clienteId: String(clienteId),
      },
      tokens,
    });

    res.json({ success: resp.successCount, failure: resp.failureCount });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e?.message || 'internal error' });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`notify-service listening on :${port}`);
});


