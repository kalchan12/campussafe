export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold mb-4">CampusSafe Dashboard</h1>
      <p className="text-lg text-gray-600">
        Emergency Operations Dashboard
      </p>
      <a
        href="/login"
        className="mt-8 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
      >
        Access Dashboard
      </a>
    </main>
  );
}
