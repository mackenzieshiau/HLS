import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import { PageHeader } from "@/components/page-header";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { toast } from "sonner";
import { ArrowUp, ArrowDown, Trash2, Plus, Eye, X, Star, Save, CheckCircle2 } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";

export const Route = createFileRoute("/_authenticated/forms/$formId/edit")({
  head: () => ({ meta: [{ title: "Edit form" }] }),
  component: EditForm,
});

type QType = "text" | "multiple_choice" | "rating";
type Question = {
  id: string;
  type: QType;
  label: string;
  options: { choices?: string[]; max?: number };
  order: number;
};
type FormRow = { id: string; title: string; description: string | null; user_id: string | null; require_login: boolean };

function EditForm() {
  const { formId } = Route.useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState<FormRow | null>(null);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loading, setLoading] = useState(true);
  const [previewOpen, setPreviewOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [savedOpen, setSavedOpen] = useState(false);
  const [requireLogin, setRequireLogin] = useState(false);

  const saveAll = async () => {
    setSaving(true);
    const [{ error: formErr }, ...qResults] = await Promise.all([
      supabase.from("forms").update({ require_login: requireLogin }).eq("id", formId),
      ...questions.map((q) =>
        supabase
          .from("questions")
          .update({ label: q.label, options: q.options, order: q.order })
          .eq("id", q.id),
      ),
    ]);
    setSaving(false);
    if (formErr || qResults.find((r) => r.error)) {
      toast.error("Some changes failed to save");
      return;
    }
    setSavedOpen(true);
  };

  const load = async () => {
    const [{ data: f }, { data: qs }] = await Promise.all([
      supabase.from("forms").select("*").eq("id", formId).maybeSingle(),
      supabase.from("questions").select("*").eq("form_id", formId).order("order", { ascending: true }),
    ]);
    if (!f) {
      toast.error("Form not found");
      navigate({ to: "/dashboard" });
      return;
    }
    setForm(f as FormRow);
    setRequireLogin(!!(f as any).require_login);
    setQuestions(
      ((qs ?? []) as any[]).map((q) => ({
        id: q.id,
        type: q.type,
        label: q.label,
        options: q.options ?? {},
        order: q.order,
      })),
    );
    setLoading(false);
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [formId]);

  const addQuestion = async (type: QType) => {
    const order = questions.length;
    const defaults =
      type === "multiple_choice"
        ? { choices: ["Option 1", "Option 2"] }
        : type === "rating"
          ? { max: 5 }
          : {};
    const { data, error } = await supabase
      .from("questions")
      .insert({ form_id: formId, type, label: "", options: defaults, order })
      .select()
      .single();
    if (error || !data) {
      toast.error("Failed to add question");
      return;
    }
    setQuestions((qs) => [
      ...qs,
      { id: data.id, type, label: "", options: defaults, order },
    ]);
  };

  const updateQuestion = (id: string, patch: Partial<Question>) => {
    setQuestions((qs) => qs.map((q) => (q.id === id ? { ...q, ...patch } : q)));
  };

  const persistQuestion = async (q: Question) => {
    const { error } = await supabase
      .from("questions")
      .update({ label: q.label, options: q.options })
      .eq("id", q.id);
    if (error) toast.error("Failed to save question");
  };

  const deleteQuestion = async (id: string) => {
    const { error } = await supabase.from("questions").delete().eq("id", id);
    if (error) {
      toast.error("Failed to delete");
      return;
    }
    const remaining = questions.filter((q) => q.id !== id).map((q, i) => ({ ...q, order: i }));
    setQuestions(remaining);
    await Promise.all(
      remaining.map((q) => supabase.from("questions").update({ order: q.order }).eq("id", q.id)),
    );
  };

  const move = async (id: string, dir: -1 | 1) => {
    const idx = questions.findIndex((q) => q.id === id);
    const swap = idx + dir;
    if (idx < 0 || swap < 0 || swap >= questions.length) return;
    const next = [...questions];
    [next[idx], next[swap]] = [next[swap], next[idx]];
    const reordered = next.map((q, i) => ({ ...q, order: i }));
    setQuestions(reordered);
    await Promise.all(
      reordered.map((q) => supabase.from("questions").update({ order: q.order }).eq("id", q.id)),
    );
  };

  if (loading) {
    return (
      <div className="min-h-screen flex flex-col bg-background">
        <SiteHeader />
        <main className="flex-1 mx-auto w-full max-w-3xl px-6 py-12">
          <p className="text-muted-foreground">Loading…</p>
        </main>
        <SiteFooter />
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <SiteHeader />
      <main className="flex-1 mx-auto w-full max-w-3xl px-6 py-16">
        <Link to="/dashboard" className="text-sm text-muted-foreground hover:text-foreground">
          ← Back to dashboard
        </Link>
        <div className="mt-4">
          <PageHeader
            eyebrow="Form builder"
            title={form?.title ?? "Edit form"}
            description={form?.description ?? undefined}
            actions={
              <>
                <Button variant="outline" size="sm" onClick={() => setPreviewOpen(true)}>
                  <Eye className="h-4 w-4 mr-1.5" /> Preview
                </Button>
                <Button size="sm" onClick={saveAll} disabled={saving || questions.length === 0}>
                  <Save className="h-4 w-4 mr-1.5" /> {saving ? "Saving…" : "Save"}
                </Button>
              </>
            }
          />
        </div>


        <section className="mt-8 space-y-4">
          {questions.length === 0 && (
            <p className="text-muted-foreground">No questions yet. Add one below.</p>
          )}
          {questions.map((q, i) => (
            <div key={q.id} className="surface-card p-6">
              <div className="flex items-start justify-between gap-2">
                <span className="text-xs uppercase tracking-wide text-muted-foreground">
                  {i + 1}. {q.type === "multiple_choice" ? "Multiple choice" : q.type === "rating" ? "Rating" : "Short answer"}
                </span>
                <div className="flex gap-1">
                  <Button size="icon" variant="ghost" onClick={() => move(q.id, -1)} disabled={i === 0}>
                    <ArrowUp className="h-4 w-4" />
                  </Button>
                  <Button size="icon" variant="ghost" onClick={() => move(q.id, 1)} disabled={i === questions.length - 1}>
                    <ArrowDown className="h-4 w-4" />
                  </Button>
                  <Button size="icon" variant="ghost" onClick={() => deleteQuestion(q.id)}>
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>
              <div className="mt-3 space-y-2">
                <Label>Question</Label>
                <Input
                  value={q.label}
                  onChange={(e) => updateQuestion(q.id, { label: e.target.value })}
                  onBlur={() => persistQuestion(q)}
                  placeholder="Enter question text"
                />
              </div>

              {q.type === "multiple_choice" && (
                <div className="mt-4 space-y-2">
                  <Label>Choices</Label>
                  {(q.options.choices ?? []).map((c, ci) => (
                    <div key={ci} className="flex gap-2">
                      <Input
                        value={c}
                        onChange={(e) => {
                          const choices = [...(q.options.choices ?? [])];
                          choices[ci] = e.target.value;
                          updateQuestion(q.id, { options: { ...q.options, choices } });
                        }}
                        onBlur={() => persistQuestion(q)}
                      />
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => {
                          const choices = (q.options.choices ?? []).filter((_, x) => x !== ci);
                          const next = { ...q, options: { ...q.options, choices } };
                          updateQuestion(q.id, { options: next.options });
                          persistQuestion(next);
                        }}
                      >
                        <X className="h-4 w-4" />
                      </Button>
                    </div>
                  ))}
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => {
                      const choices = [...(q.options.choices ?? []), `Option ${(q.options.choices?.length ?? 0) + 1}`];
                      const next = { ...q, options: { ...q.options, choices } };
                      updateQuestion(q.id, { options: next.options });
                      persistQuestion(next);
                    }}
                  >
                    <Plus className="h-4 w-4 mr-1" /> Add choice
                  </Button>
                </div>
              )}

              {q.type === "rating" && (
                <div className="mt-4 space-y-2">
                  <Label>Scale (1 to N)</Label>
                  <Input
                    type="number"
                    min={2}
                    max={10}
                    value={q.options.max ?? 5}
                    onChange={(e) => updateQuestion(q.id, { options: { ...q.options, max: Number(e.target.value) || 5 } })}
                    onBlur={() => persistQuestion(q)}
                    className="w-24"
                  />
                </div>
              )}
            </div>
          ))}
        </section>

        <section className="mt-6 surface-card p-6">
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-sm font-medium text-foreground">Require sign-in to respond</p>
              <p className="mt-1 text-xs text-muted-foreground">
                When on, respondents must sign in before they can submit this form. When off, anyone with the link can submit anonymously.
              </p>
            </div>
            <Switch checked={requireLogin} onCheckedChange={setRequireLogin} aria-label="Require sign-in" />
          </div>
          <p className="mt-3 text-xs text-muted-foreground">
            Changes apply after you click <span className="font-medium">Save</span>.
          </p>
        </section>


        <section className="mt-6 rounded-xl border border-dashed border-border p-5">
          <p className="text-sm font-medium mb-3">Add a question</p>
          <div className="flex flex-wrap gap-2">
            <Button variant="outline" onClick={() => addQuestion("text")}>
              <Plus className="h-4 w-4 mr-1" /> Short answer
            </Button>
            <Button variant="outline" onClick={() => addQuestion("multiple_choice")}>
              <Plus className="h-4 w-4 mr-1" /> Multiple choice
            </Button>
            <Button variant="outline" onClick={() => addQuestion("rating")}>
              <Plus className="h-4 w-4 mr-1" /> Rating
            </Button>
          </div>
        </section>
      </main>
      <SiteFooter />

      {previewOpen && form && (
        <div className="fixed inset-0 z-50 bg-black/60 flex items-start justify-center overflow-y-auto p-4">
          <div className="bg-card text-card-foreground rounded-2xl shadow-xl max-w-2xl w-full p-8 my-8">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-semibold">Preview</h2>
              <Button variant="ghost" size="icon" onClick={() => setPreviewOpen(false)}>
                <X className="h-5 w-5" />
              </Button>
            </div>
            <h1 className="font-display font-extrabold text-3xl">{form.title}</h1>
            {form.description && <p className="mt-1 text-muted-foreground">{form.description}</p>}
            <div className="mt-6 space-y-5">
              {questions.map((q, i) => (
                <div key={q.id}>
                  <p className="font-medium">{i + 1}. {q.label || <span className="text-muted-foreground italic">(no label)</span>}</p>
                  {q.type === "text" && <Input className="mt-2" disabled placeholder="Their answer" />}
                  {q.type === "multiple_choice" && (
                    <div className="mt-2 space-y-1">
                      {(q.options.choices ?? []).map((c, ci) => (
                        <label key={ci} className="flex items-center gap-2 text-sm">
                          <input type="radio" disabled /> {c}
                        </label>
                      ))}
                    </div>
                  )}
                  {q.type === "rating" && (
                    <div className="mt-2 flex gap-1">
                      {Array.from({ length: q.options.max ?? 5 }).map((_, ri) => (
                        <Star key={ri} className="h-6 w-6 text-muted-foreground" />
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      <Dialog open={savedOpen} onOpenChange={setSavedOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <CheckCircle2 className="h-5 w-5 text-green-500" />
              Form saved
            </DialogTitle>
            <DialogDescription>
              Your changes have been saved successfully.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="gap-2 sm:gap-2">
            <Button variant="outline" onClick={() => setSavedOpen(false)}>
              Continue editing
            </Button>
            <Button onClick={() => navigate({ to: "/dashboard" })}>
              Return to dashboard
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
