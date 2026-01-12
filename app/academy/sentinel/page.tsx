import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

export default function SentinelIndex() {
  const lessons = loadCanonLessons("sentinel");

  return (
    <main className="max-w-5xl mx-auto px-6 py-12">
      <h1 className="text-3xl font-semibold mb-6">Sentinel Division</h1>
      <p className="text-white/60">
        Prestige Add-on. Clearance-gated operational tier.
      </p>
    </main>
  );
}