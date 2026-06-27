import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import { PageHeader } from "@/components/page-header";
import { Star } from "lucide-react";

export const Route = createFileRoute("/_authenticated/forms/$formId/responses")({
  head: () => ({ meta: [{ title: "Responses" }] }),
  component: ResponsesPage,
});

type Answer = { question_id: string; label: string; type: string; answer: string | number | null };
type ResponseRow = { id: string; submitted_at: string; answers: Answer[] };

function ResponsesPage() {
  const { formId } = Route.useParams();
  const [title, setTitle] = useState("");
  const [rows, setRows] = useState<ResponseRow[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      const [{ data: f }, { data: rs }] = await Promise.all([
        supabase.from("forms").select("title").eq("id", formId).maybeSingle(),
        supabase.from("responses").select("*").eq("form_id", formId).order("submitted_at", { ascending: false }),
      ]);
      setTitle(f?.title ?? "");
      setRows(((rs ?? []) as any[]).map((r) => ({
        id: r.id,
        submitted_at: r.submitted_at,
        answers: Array.isArray(r.answers) ? r.answers : [],
      })));
      setLoading(false);
    })();
  }, [formId]);

  const renderAnswer = (a: Answer) => {
    if (a.answer === null || a.answer === "") return <span className="text-muted-foreground italic">No answer</span>;
    if (a.type === "rating") {
      const n = Number(a.answer);
      return (
        <span className="inline-flex items-center gap-1">
          {Array.from({ length: n }).map((_, i) => (
            <Star key={i} className="h-4 w-4 fill-yellow-400 text-yellow-400" />
          ))}
          <span className="text-muted-foreground text-sm ml-1">({n})</span>
        </span>
      );
    }
    return <span>{String(a.answer)}</span>;
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <SiteHeader />
      <main className="flex-1 mx-auto w-full max-w-4xl px-6 py-16">
        <Link to="/dashboard" className="text-sm text-muted-foreground hover:text-foreground">
          ← Back to dashboard
        </Link>
        <div className="mt-4">
          <PageHeader
            eyebrow="Insights"
            title="Responses"
            description={`${title} · ${rows.length} response${rows.length === 1 ? "" : "s"}`}
          />
        </div>


        {loading ? (
          <p className="mt-6 text-muted-foreground">Loading…</p>
        ) : rows.length === 0 ? (
          <p className="mt-6 text-muted-foreground">No responses yet.</p>
        ) : (
          <div className="mt-6 space-y-6">
            {rows.map((r, idx) => (
              <div
                key={r.id}
                className="surface-card overflow-hidden"
              >
                <div className="flex items-center justify-between px-5 py-3 border-b border-border bg-muted/30">
                  <span className="text-sm font-medium text-card-foreground">
                    Response #{rows.length - idx}
                  </span>
                  <span className="text-xs text-muted-foreground">
                    {new Date(r.submitted_at).toLocaleString()}
                  </span>
                </div>
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-xs uppercase tracking-wide text-muted-foreground">
                      <th className="px-5 py-2 w-1/2 font-medium">Question</th>
                      <th className="px-5 py-2 font-medium">Answer</th>
                    </tr>
                  </thead>
                  <tbody>
                    {r.answers.length === 0 ? (
                      <tr>
                        <td colSpan={2} className="px-5 py-3 text-muted-foreground italic">
                          No answers recorded
                        </td>
                      </tr>
                    ) : (
                      r.answers.map((a, i) => (
                        <tr key={i} className="border-t border-border align-top">
                          <td className="px-5 py-3 text-card-foreground">
                            {a.label || <span className="italic text-muted-foreground">(untitled)</span>}
                          </td>
                          <td className="px-5 py-3">{renderAnswer(a)}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
        )}
      </main>
      <SiteFooter />
    </div>
  );
}
