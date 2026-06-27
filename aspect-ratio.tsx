// Version format: MM.DD.YYYY.II  (II = iteration number for that day)
export const APP_VERSION = "06.24.2026.02";

export function SiteFooter() {
  return (
    <footer className="border-t border-border bg-background">
      <div className="mx-auto max-w-6xl px-6 py-8 text-center text-sm text-muted-foreground space-y-2">
        <p>
          This tool is a demo support tool and does not replace official school,
          district, state, or federal requirements.
        </p>
        <p className="text-xs">Version: {APP_VERSION}</p>
      </div>
    </footer>
  );
}

