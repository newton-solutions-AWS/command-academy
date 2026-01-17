export default function Panel({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}) {
  return (
    <section className="rounded-xl border border-neutral-800 bg-neutral-950 p-6 space-y-4">
      <div>
        <h2 className="text-sm tracking-widest text-neutral-400">{title}</h2>
        {subtitle && <p className="text-xs text-neutral-500">{subtitle}</p>}
      </div>
      {children}
    </section>
  );
}
