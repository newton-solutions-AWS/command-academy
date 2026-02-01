type Props = {
  title: string;
  subtitle?: string;
  right?: React.ReactNode;
};

export default function CommandHeader({ title, subtitle, right }: Props) {
  return (
    <header className="flex items-center justify-between gap-6 rounded-3xl border border-white/10 bg-black/40 backdrop-blur-xl px-6 py-5">
      <div>
        <div className="text-xs tracking-[0.28em] text-white/45">
          COMMAND INTERFACE
        </div>
        <h1 className="text-2xl font-semibold text-white mt-2">
          {title}
        </h1>
        {subtitle && (
          <div className="text-sm text-white/60 mt-1">
            {subtitle}
          </div>
        )}
      </div>

      {right && <div>{right}</div>}
    </header>
  );
}