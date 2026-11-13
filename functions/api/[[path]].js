
export async function onRequest({ request, env }) {
  if (!env.API_WORKER) {
    return new Response("API_WORKER service binding is not configured", {
      status: 503
    });
  }

  const url = new URL(request.url);

  return env.API_WORKER.fetch(
    new Request(
      "https://worker.internal" + url.pathname + url.search,
      request
    )
  );
}
