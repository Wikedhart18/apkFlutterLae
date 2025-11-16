import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Dispara una notificación cuando cambia el campo `estado` de un documento de paquete.
 * Observa: /packages/{packageId}
 */
export const onPackageWriteNotify = onDocumentWritten(
  { document: "packages/{packageId}", region: "us-central1" },
  async (event) => {
    const before = event.data?.before?.data() as any | undefined;
    const after = event.data?.after?.data() as any | undefined;
    if (!after) return;

    const prevStatus = before?.estado;
    const newStatus = after?.estado;
    if (prevStatus === newStatus) {
      // No cambió el estado; evita ruido por actualizaciones de coordenadas.
      return;
    }

    const packageId = event.params.packageId as string;
    const clienteId = String(after?.clienteId ?? "");
    if (!clienteId) {
      logger.warn("No se encontró clienteId para el paquete", packageId);
      return;
    }

    // Recuperar tokens del cliente
    const tokenSnap = await db
      .collection("users")
      .doc(clienteId)
      .collection("fcmTokens")
      .get();
    const tokens = tokenSnap.docs.map((d) => d.id).filter(Boolean);
    if (tokens.length === 0) {
      logger.info(`Sin tokens FCM para cliente ${clienteId}`);
      return;
    }

    const title =
      newStatus === "entregado"
        ? "Tu paquete fue entregado"
        : "Actualización de tu envío";
    const body =
      newStatus != null
        ? `Estado: ${newStatus} (${packageId})`
        : `Se actualizó el paquete ${packageId}`;

    const message = {
      notification: { title, body },
      data: {
        type: "PACKAGE_STATUS",
        packageId,
        estado: String(newStatus ?? ""),
        clienteId
      },
      tokens
    };

    const resp = await messaging.sendEachForMulticast(message);
    logger.info("FCM enviado", {
      packageId,
      success: resp.successCount,
      failure: resp.failureCount
    });
  }
);

/**
 * Endpoint de prueba manual:
 * curl -X POST https://<region>-<project>.cloudfunctions.net/notifyTest \
 *  -H "Content-Type: application/json" \
 *  -d '{ "userId":"<UID>", "title":"Hola", "body":"Mensaje de prueba" }'
 */
export const notifyTest = onRequest({ region: "us-central1" }, async (req, res) => {
  try {
    if (req.method !== "POST") {
      res.status(405).send("Use POST");
      return;
    }
    const { userId, title, body } = req.body ?? {};
    if (!userId || !title) {
      res.status(400).send("Faltan parámetros: userId, title");
      return;
    }
    const tokenSnap = await db
      .collection("users")
      .doc(String(userId))
      .collection("fcmTokens")
      .get();
    const tokens = tokenSnap.docs.map((d) => d.id).filter(Boolean);
    if (tokens.length === 0) {
      res.status(200).send("Usuario sin tokens");
      return;
    }
    const resp = await messaging.sendEachForMulticast({
      notification: { title, body: body ?? "" },
      data: { type: "TEST" },
      tokens
    });
    res.status(200).send({ success: resp.successCount, failure: resp.failureCount });
  } catch (e: any) {
    logger.error("notifyTest error", e);
    res.status(500).send(e?.message ?? "Error");
  }
});

