export function get(url: string) {
  return fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    method: 'GET',
  })
}
