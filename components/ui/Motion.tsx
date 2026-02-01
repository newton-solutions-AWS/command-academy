export function Motion({ children }: { children: React.ReactNode }) {
  return (
    <div className="transition-all duration-300 ease-out hover:translate-y-[-2px] hover:shadow-xl">
      {children}
    </div>
  );
}
