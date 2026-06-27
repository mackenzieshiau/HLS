import { Link } from "@tanstack/react-router";
import { GraduationCap } from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";

export function SiteHeader() {
  const [signedIn, setSignedIn] = useState(false);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setSignedIn(!!data.session));
    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      setSignedIn(!!session);
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  return (
    <header className="border-b border-border bg-background/85 backdrop-blur sticky top-0 z-10">
      <div className="mx-auto max-w-7xl px-6 h-20 flex items-center justify-between">
        <Link
          to="/"
          className="flex items-center gap-3 font-display font-extrabold text-foreground"
        >
          <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-sm">
            <GraduationCap className="h-5 w-5" />
          </span>
          <span className="tracking-tight text-lg">Home Language Screener</span>
        </Link>
        <nav className="flex items-center gap-2">
          {signedIn ? (
            <Button asChild variant="ghost" size="sm">
              <Link to="/dashboard">Dashboard</Link>
            </Button>
          ) : (
            <Button asChild variant="ghost" size="sm">
              <Link to="/auth">Sign in</Link>
            </Button>
          )}
          <Button
            asChild
            size="sm"
            className="uppercase tracking-[0.14em] font-bold"
          >
            <Link to="/demo">Try the Demo</Link>
          </Button>
        </nav>
      </div>
    </header>
  );
}
