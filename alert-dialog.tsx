import type { ReactNode } from "react";

type PageHeaderProps = {
  eyebrow?: string;
  title: ReactNode;
  description?: ReactNode;
  actions?: ReactNode;
  align?: "left" | "center";
};

export function PageHeader({
  eyebrow,
  title,
  description,
  actions,
  align = "left",
}: PageHeaderProps) {
  const alignClass = align === "center" ? "text-center items-center" : "items-start";
  return (
    <div className={`flex flex-wrap gap-x-8 gap-y-6 justify-between ${alignClass}`}>
      <div className={align === "center" ? "mx-auto max-w-2xl" : "max-w-3xl"}>
        {eyebrow && (
          <span className="eyebrow inline-flex items-center gap-2 rounded-full bg-primary/10 px-3 py-1 text-primary">
            <span className="h-1.5 w-1.5 rounded-full bg-primary" />
            {eyebrow}
          </span>
        )}
        <h1 className="mt-4 font-display font-extrabold text-5xl sm:text-6xl tracking-[-0.03em] text-foreground leading-[1.02]">
          {title}
        </h1>
        {description && (
          <p className="mt-4 text-base sm:text-lg text-muted-foreground leading-relaxed max-w-2xl">
            {description}
          </p>
        )}
      </div>
      {actions && (
        <div className="flex flex-wrap items-center gap-2 self-start">{actions}</div>
      )}
    </div>
  );
}
