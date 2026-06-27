import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import { PageHeader } from "@/components/page-header";
import { ProfileDialog, applyTheme, type ProfilePrefs } from "@/components/profile-dialog";
import { toast } from "sonner";
import { UserCog, Pencil, Share2, BarChart3 } from "lucide-react";

export const Route = createFileRoute("/_authenticated/dashboard")({
  head: () => ({
    meta: [
      { title: "Dashboard — Home Language Screener" },
      { name: "description", content: "Create and manage your forms." },
    ],
  }),
  component: Dashboard,
});

type Form = {
  id: string;
  title: string;
  description: string | null;
  created_at: string;
};

const DEFAULT_PROFILE: ProfilePrefs = {
  display_name: null,
  theme: "light",
  forms_view: "list",
};

function Dashboard() {
  const navigate = useNavigate();
  const [userId, setUserId] = useState<string | null>(null);
  const [userEmail, setUserEmail] = useState<string>("");
  const [profile, setProfile] = useState<ProfilePrefs>(DEFAULT_PROFILE);
  const [profileOpen, setProfileOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [forms, setForms] = useState<Form[]>([]);
  const [counts, setCounts] = useState<Record<string, number>>({});
  const [qStats, setQStats] = useState<Record<string, { total: number; text: number; multiple_choice: number; rating: number }>>({});
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(true);
  const [sortBy, setSortBy] = useState<"created_at" | "title">("created_at");
  const [sortDir, setSortDir] = useState<"asc" | "desc">("desc");

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      if (!data.user) return;
      setUserId(data.user.id);
      setUserEmail(data.user.email ?? "");
    });
  }, []);

  useEffect(() => {
    if (!userId) return;
    (async () => {
      const { data } = await supabase
        .from("profiles")
        .select("display_name, theme, forms_view")
        .eq("id", userId)
        .maybeSingle();
      if (data) {
        const p: ProfilePrefs = {
          display_name: data.display_name,
          theme: (data.theme as "light" | "dark") ?? "light",
          forms_view: (data.forms_view as "list" | "cards") ?? "list",
        };
        setProfile(p);
        applyTheme(p.theme);
      }
    })();
  }, [userId]);

  const loadCounts = async (ids: string[]) => {
    if (ids.length === 0) {
      setCounts({});
      setQStats({});
      return;
    }
    const [{ data: resp }, { data: qs }] = await Promise.all([
      supabase.from("responses").select("form_id").in("form_id", ids),
      supabase.from("questions").select("form_id, type").in("form_id", ids),
    ]);
    const c: Record<string, number> = {};
    (resp ?? []).forEach((r: any) => {
      c[r.form_id] = (c[r.form_id] ?? 0) + 1;
    });
    setCounts(c);
    const s: Record<string, { total: number; text: number; multiple_choice: number; rating: number }> = {};
    ids.forEach((id) => (s[id] = { total: 0, text: 0, multiple_choice: 0, rating: 0 }));
    (qs ?? []).forEach((q: any) => {
      const bucket = s[q.form_id];
      if (!bucket) return;
      bucket.total += 1;
      if (q.type === "text" || q.type === "multiple_choice" || q.type === "rating") {
        bucket[q.type as "text" | "multiple_choice" | "rating"] += 1;
      }
    });
    setQStats(s);
  };

  useEffect(() => {
    if (!userId) return;
    const loadForms = async () => {
      const { data, error } = await supabase
        .from("forms")
        .select("*")
        .eq("user_id", userId)
        .order("created_at", { ascending: false });
      if (error) toast.error("Failed to load forms");
      else {
        setForms(data ?? []);
        loadCounts((data ?? []).map((f) => f.id));
      }
      setLoading(false);
    };
    loadForms();
  }, [userId]);

  const reload = async () => {
    if (!userId) return;
    const { data } = await supabase
      .from("forms")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });
    setForms(data ?? []);
    loadCounts((data ?? []).map((f) => f.id));
  };

  const copyShareLink = async (id: string) => {
    const url = `${window.location.origin}/forms/${id}`;
    try {
      await navigator.clipboard.writeText(url);
      toast.success("Share link copied");
    } catch {
      toast.error("Could not copy link");
    }
  };

  const sortedForms = [...forms].sort((a, b) => {
    let cmp = 0;
    if (sortBy === "title") {
      cmp = a.title.localeCompare(b.title);
    } else {
      cmp = new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
    }
    return sortDir === "asc" ? cmp : -cmp;
  });

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      toast.error("Title is required");
      return;
    }
    if (!userId) {
      toast.error("You must be signed in");
      return;
    }
    setSaving(true);
    const { error } = await supabase
      .from("forms")
      .insert({
        title: title.trim(),
        description: description.trim() || null,
        user_id: userId,
      });
    setSaving(false);
    if (error) {
      toast.error("Failed to save form");
      return;
    }
    toast.success("Form saved");
    setTitle("");
    setDescription("");
    reload();
  };

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    applyTheme("light");
    navigate({ to: "/auth", replace: true });
  };

  const greeting = profile.display_name?.trim() || userEmail;

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <SiteHeader />
      <main className="flex-1 mx-auto w-full max-w-5xl px-6 py-16">
        <PageHeader
          eyebrow="Your workspace"
          title="Dashboard"
          description={
            greeting ? (
              <>Welcome, <span className="text-foreground font-semibold">{greeting}</span></>
            ) : undefined
          }
          actions={
            <>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setProfileOpen(true)}
                disabled={!userId}
              >
                <UserCog className="h-4 w-4" />
                Profile
              </Button>
              <Button variant="outline" size="sm" onClick={handleSignOut}>
                Sign out
              </Button>
            </>
          }
        />

        <form
          onSubmit={handleSave}
          className="mt-12 surface-card p-8 sm:p-10 space-y-6"
        >
          <div className="space-y-2">
            <Label htmlFor="title">Form title</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. Kindergarten Home Language Survey"
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="description">Description (optional)</Label>
            <Textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Short description of this form"
              rows={3}
            />
            <p className="text-xs text-muted-foreground">
              Helps parents understand what this form is for.
            </p>
          </div>
          <div className="pt-2">
            <Button
              type="submit"
              size="lg"
              disabled={saving}
              className="uppercase tracking-[0.14em]"
            >
              {saving ? "Saving…" : "Save form"}
            </Button>
          </div>
        </form>

        <section className="mt-12">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-xs font-bold uppercase tracking-[0.22em] text-primary">Forms</p>
              <h2 className="mt-2 font-display font-extrabold text-2xl sm:text-3xl tracking-tight text-foreground">
                Your forms
              </h2>
            </div>
            <div className="flex flex-wrap items-center gap-2">
              <Label htmlFor="sort-by" className="text-sm text-muted-foreground">
                Sort by
              </Label>
              <select
                id="sort-by"
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as "created_at" | "title")}
                className="h-9 rounded-full border border-input bg-background px-3 text-sm"
              >
                <option value="created_at">Date created</option>
                <option value="title">Title (A–Z)</option>
              </select>
              <select
                value={sortDir}
                onChange={(e) => setSortDir(e.target.value as "asc" | "desc")}
                className="h-9 rounded-full border border-input bg-background px-3 text-sm"
                aria-label="Sort direction"
              >
                <option value="desc">Descending</option>
                <option value="asc">Ascending</option>
              </select>
            </div>
          </div>
          {loading ? (
            <p className="mt-4 text-muted-foreground">Loading…</p>
          ) : sortedForms.length === 0 ? (
            <p className="mt-4 text-muted-foreground">
              No forms yet. Create your first one above.
            </p>
          ) : profile.forms_view === "cards" ? (
            <div className="mt-4 grid gap-4 sm:grid-cols-2">
              {sortedForms.map((f) => (
                <div
                  key={f.id}
                  className="surface-card p-6 flex flex-col"
                >
                  <div className="font-semibold text-card-foreground text-lg">{f.title}</div>
                  {f.description && (
                    <p className="mt-2 text-sm text-muted-foreground flex-1">{f.description}</p>
                  )}
                  <p className="mt-3 text-xs text-muted-foreground">
                    {new Date(f.created_at).toLocaleString()}
                  </p>
                  <FormStats stats={qStats[f.id]} completions={counts[f.id] ?? 0} />
                  <FormActions formId={f.id} onCopy={copyShareLink} />
                </div>
              ))}
            </div>
          ) : (
            <ul className="mt-4 space-y-3">
              {sortedForms.map((f) => (
                <li
                  key={f.id}
                  className="surface-card p-6"
                >
                  <div className="font-medium text-card-foreground">{f.title}</div>
                  {f.description && (
                    <p className="mt-1 text-sm text-muted-foreground">{f.description}</p>
                  )}
                  <p className="mt-2 text-xs text-muted-foreground">
                    {new Date(f.created_at).toLocaleString()}
                  </p>
                  <FormStats stats={qStats[f.id]} completions={counts[f.id] ?? 0} />
                  <FormActions formId={f.id} onCopy={copyShareLink} />
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>
      <SiteFooter />

      {userId && (
        <ProfileDialog
          open={profileOpen}
          onOpenChange={setProfileOpen}
          userId={userId}
          profile={profile}
          onSaved={(next) => {
            setProfile(next);
            applyTheme(next.theme);
          }}
        />
      )}
    </div>
  );
}

function FormActions({ formId, onCopy }: { formId: string; onCopy: (id: string) => void }) {
  return (
    <div className="mt-3 flex flex-wrap gap-2">
      <Button asChild size="sm" variant="outline">
        <Link to="/forms/$formId/edit" params={{ formId }}>
          <Pencil className="h-3.5 w-3.5 mr-1" /> Edit
        </Link>
      </Button>
      <Button size="sm" variant="outline" onClick={() => onCopy(formId)}>
        <Share2 className="h-3.5 w-3.5 mr-1" /> Share link
      </Button>
      <Button asChild size="sm" variant="outline">
        <Link to="/forms/$formId/responses" params={{ formId }}>
          <BarChart3 className="h-3.5 w-3.5 mr-1" /> View responses
        </Link>
      </Button>
    </div>
  );
}

function FormStats({
  stats,
  completions,
}: {
  stats?: { total: number; text: number; multiple_choice: number; rating: number };
  completions: number;
}) {
  const s = stats ?? { total: 0, text: 0, multiple_choice: 0, rating: 0 };
  return (
    <div className="mt-3 flex flex-wrap gap-1.5">
      <span className="inline-flex items-center rounded-full border border-border bg-muted/40 px-2 py-0.5 text-xs text-foreground">
        {s.total} question{s.total === 1 ? "" : "s"}
      </span>
      <span className="inline-flex items-center rounded-full border border-border px-2 py-0.5 text-xs text-muted-foreground">
        Short: {s.text}
      </span>
      <span className="inline-flex items-center rounded-full border border-border px-2 py-0.5 text-xs text-muted-foreground">
        Choice: {s.multiple_choice}
      </span>
      <span className="inline-flex items-center rounded-full border border-border px-2 py-0.5 text-xs text-muted-foreground">
        Rating: {s.rating}
      </span>
      <span className="inline-flex items-center rounded-full border border-border bg-primary/10 px-2 py-0.5 text-xs text-foreground">
        {completions} completion{completions === 1 ? "" : "s"}
      </span>
    </div>
  );
}
