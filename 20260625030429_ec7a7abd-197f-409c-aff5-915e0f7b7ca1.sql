import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useMemo, useState, type FormEvent, type ReactNode } from "react";
import { CheckCircle2, AlertCircle, ArrowLeft, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import { GOOGLE_TRANSLATE_LANGUAGES, translateStrings } from "@/lib/languages";

export const Route = createFileRoute("/demo")({
  head: () => ({
    meta: [
      { title: "Demo Home Language Survey — Home Language Screener" },
      {
        name: "description",
        content:
          "Try the demo Home Language Survey. A parent-friendly screener that flags when a language other than English is reported.",
      },
      { property: "og:title", content: "Demo Home Language Survey" },
      {
        property: "og:description",
        content:
          "Try the parent-facing Home Language Survey and see the next-step recommendation.",
      },
    ],
  }),
  component: DemoPage,
});

const GRADES = [
  "Pre-K",
  "Kindergarten",
  "1st",
  "2nd",
  "3rd",
  "4th",
  "5th",
  "6th",
  "7th",
  "8th",
  "9th",
  "10th",
  "11th",
  "12th",
];

// Strings shown on the form that we offer translations for.
// Keys are stable IDs; values are the source English strings.
const STRINGS = {
  intro:
    "Please answer the questions below about your child's home language. Your answers help the school support your child.",
  sectionStart: "Before we begin",
  parentLanguage: "What language do you, the parent/guardian, speak?",
  parentLanguageHelp:
    "This helps the school know how to communicate with your family.",
  sectionStudent: "Student information",
  firstName: "Student first name",
  lastName: "Student last name",
  birthDate: "Student date of birth",
  birthDateHelp:
    "Grade levels are not the same in every country, so we ask for date of birth.",
  grade: "Grade level (optional)",
  guardian: "Parent/guardian name",
  sectionSurvey: "Home language questions",
  q1: "What language(s) is/are used in the child's home most of the time?",
  q2: "What language(s) does the child use most of the time?",
  q3: "If the child had a previous home setting, what language(s) was/were used for communication in that home setting? If no previous home setting, answer Not Applicable (N/A).",
  pickLanguage: "Choose a language",
  otherLanguage: "Or type the language if it is not in the list",
  sectionOptional: "Optional",
  preferredLang:
    "Parent/guardian preferred language for school communication",
  submit: "Submit survey",
} as const;

type StringKey = keyof typeof STRINGS;
type Translations = Partial<Record<StringKey, string>>;

const OTHER_VALUE = "__other__";

type FormState = {
  parentLanguage: string; // ISO code
  firstName: string;
  lastName: string;
  birthDate: string;
  grade: string;
  guardianName: string;
  q1Lang: string;
  q1Other: string;
  q2Lang: string;
  q2Other: string;
  q3: string;
  preferredLang: string;
};

const EMPTY: FormState = {
  parentLanguage: "",
  firstName: "",
  lastName: "",
  birthDate: "",
  grade: "",
  guardianName: "",
  q1Lang: "",
  q1Other: "",
  q2Lang: "",
  q2Other: "",
  q3: "",
  preferredLang: "",
};

const ENGLISH_OR_NA = new Set([
  "english",
  "english only",
  "only english",
  "n/a",
  "na",
  "not applicable",
]);

function isEnglishOrNA(value: string, allowEmpty = false): boolean {
  const v = value.trim().toLowerCase();
  if (!v) return allowEmpty;
  return ENGLISH_OR_NA.has(v);
}

// Combine a language dropdown selection with an optional free-text override.
function effectiveLanguage(lang: string, other: string): string {
  const o = other.trim();
  if (o) return o;
  if (lang === OTHER_VALUE) return "";
  return lang;
}

function DemoPage() {
  const [form, setForm] = useState<FormState>(EMPTY);
  const [submitted, setSubmitted] = useState(false);
  const [translations, setTranslations] = useState<Translations>({});
  const [translating, setTranslating] = useState(false);

  const update = (key: keyof FormState) => (value: string) =>
    setForm((f) => ({ ...f, [key]: value }));

  // Fetch translations whenever the parent's language changes.
  useEffect(() => {
    const code = form.parentLanguage;
    if (!code || code === "en") {
      setTranslations({});
      return;
    }
    let cancelled = false;
    setTranslating(true);
    const keys = Object.keys(STRINGS) as StringKey[];
    const sources = keys.map((k) => STRINGS[k]);
    translateStrings(sources, code)
      .then((out) => {
        if (cancelled) return;
        const next: Translations = {};
        keys.forEach((k, i) => {
          if (out[i] && out[i] !== STRINGS[k]) next[k] = out[i];
        });
        setTranslations(next);
      })
      .catch(() => {
        if (!cancelled) setTranslations({});
      })
      .finally(() => {
        if (!cancelled) setTranslating(false);
      });
    return () => {
      cancelled = true;
    };
  }, [form.parentLanguage]);

  const T = useMemo(
    () =>
      function T({ k }: { k: StringKey }): ReactNode {
        const t = translations[k];
        if (!t) return null;
        return (
          <span className="block text-sm font-normal text-muted-foreground italic mt-0.5">
            {t}
          </span>
        );
      },
    [translations],
  );

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const reset = () => {
    setForm(EMPTY);
    setSubmitted(false);
  };

  const englishOnly =
    isEnglishOrNA(effectiveLanguage(form.q1Lang, form.q1Other)) &&
    isEnglishOrNA(effectiveLanguage(form.q2Lang, form.q2Other)) &&
    isEnglishOrNA(form.q3, true);

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <SiteHeader />

      <main className="flex-1">
        <div className="mx-auto max-w-2xl px-6 py-12">
          {!submitted ? (
            <>
              <div className="mb-8">
                <Link
                  to="/"
                  className="inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground"
                >
                  <ArrowLeft className="h-4 w-4" />
                  Back to home
                </Link>
                <h1 className="mt-4 font-display font-extrabold text-4xl tracking-tight text-foreground leading-[1.05]">
                  Home Language Survey
                </h1>
                <p className="mt-2 text-muted-foreground">{STRINGS.intro}</p>
                {translations.intro && (
                  <p className="mt-1 text-muted-foreground italic">
                    {translations.intro}
                  </p>
                )}
                {translating && (
                  <p className="mt-3 inline-flex items-center gap-2 text-xs text-muted-foreground">
                    <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    Loading translation…
                  </p>
                )}
              </div>

              <form onSubmit={handleSubmit} className="space-y-10">
                {/* Parent language */}
                <section className="space-y-4">
                  <h2 className="text-lg font-semibold text-foreground">
                    {STRINGS.sectionStart}
                    {translations.sectionStart && (
                      <span className="block text-sm font-normal text-muted-foreground italic">
                        {translations.sectionStart}
                      </span>
                    )}
                  </h2>
                  <div className="space-y-2">
                    <Label htmlFor="parentLanguage">
                      {STRINGS.parentLanguage}
                      <T k="parentLanguage" />
                    </Label>
                    <Select
                      value={form.parentLanguage}
                      onValueChange={update("parentLanguage")}
                      required
                    >
                      <SelectTrigger id="parentLanguage">
                        <SelectValue placeholder="Select a language" />
                      </SelectTrigger>
                      <SelectContent className="max-h-72">
                        {GOOGLE_TRANSLATE_LANGUAGES.map((lang) => (
                          <SelectItem key={lang.code} value={lang.code}>
                            {lang.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <p className="text-xs text-muted-foreground">
                      {STRINGS.parentLanguageHelp}
                      {translations.parentLanguageHelp && (
                        <span className="block italic">
                          {translations.parentLanguageHelp}
                        </span>
                      )}
                    </p>
                  </div>
                </section>

                {/* Student Information */}
                <section className="space-y-4">
                  <h2 className="text-lg font-semibold text-foreground">
                    {STRINGS.sectionStudent}
                    {translations.sectionStudent && (
                      <span className="block text-sm font-normal text-muted-foreground italic">
                        {translations.sectionStudent}
                      </span>
                    )}
                  </h2>

                  <div className="grid gap-4 sm:grid-cols-2">
                    <div className="space-y-2">
                      <Label htmlFor="firstName">
                        {STRINGS.firstName}
                        <T k="firstName" />
                      </Label>
                      <Input
                        id="firstName"
                        required
                        value={form.firstName}
                        onChange={(e) => update("firstName")(e.target.value)}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="lastName">
                        {STRINGS.lastName}
                        <T k="lastName" />
                      </Label>
                      <Input
                        id="lastName"
                        required
                        value={form.lastName}
                        onChange={(e) => update("lastName")(e.target.value)}
                      />
                    </div>
                  </div>

                  <div className="grid gap-4 sm:grid-cols-2">
                    <div className="space-y-2">
                      <Label htmlFor="birthDate">
                        {STRINGS.birthDate}
                        <T k="birthDate" />
                      </Label>
                      <Input
                        id="birthDate"
                        type="date"
                        required
                        value={form.birthDate}
                        onChange={(e) => update("birthDate")(e.target.value)}
                      />
                      <p className="text-xs text-muted-foreground">
                        {STRINGS.birthDateHelp}
                        {translations.birthDateHelp && (
                          <span className="block italic">
                            {translations.birthDateHelp}
                          </span>
                        )}
                      </p>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="grade">
                        {STRINGS.grade}
                        <T k="grade" />
                      </Label>
                      <Select
                        value={form.grade}
                        onValueChange={update("grade")}
                      >
                        <SelectTrigger id="grade">
                          <SelectValue placeholder="Select a grade" />
                        </SelectTrigger>
                        <SelectContent>
                          {GRADES.map((g) => (
                            <SelectItem key={g} value={g}>
                              {g}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="guardianName">
                      {STRINGS.guardian}
                      <T k="guardian" />
                    </Label>
                    <Input
                      id="guardianName"
                      required
                      value={form.guardianName}
                      onChange={(e) => update("guardianName")(e.target.value)}
                    />
                  </div>
                </section>

                {/* Survey questions */}
                <section className="space-y-6">
                  <h2 className="text-lg font-semibold text-foreground">
                    {STRINGS.sectionSurvey}
                    {translations.sectionSurvey && (
                      <span className="block text-sm font-normal text-muted-foreground italic">
                        {translations.sectionSurvey}
                      </span>
                    )}
                  </h2>

                  <LanguagePickerField
                    idPrefix="q1"
                    labelKey="q1"
                    langValue={form.q1Lang}
                    otherValue={form.q1Other}
                    onLangChange={update("q1Lang")}
                    onOtherChange={update("q1Other")}
                    translations={translations}
                    T={T}
                  />

                  <LanguagePickerField
                    idPrefix="q2"
                    labelKey="q2"
                    langValue={form.q2Lang}
                    otherValue={form.q2Other}
                    onLangChange={update("q2Lang")}
                    onOtherChange={update("q2Other")}
                    translations={translations}
                    T={T}
                  />

                  <div className="space-y-2">
                    <Label htmlFor="q3">
                      {STRINGS.q3}
                      <T k="q3" />
                    </Label>
                    <Textarea
                      id="q3"
                      required
                      rows={2}
                      value={form.q3}
                      onChange={(e) => update("q3")(e.target.value)}
                    />
                  </div>
                </section>

                {/* Optional */}
                <section className="space-y-4">
                  <h2 className="text-lg font-semibold text-foreground">
                    {STRINGS.sectionOptional}
                    {translations.sectionOptional && (
                      <span className="block text-sm font-normal text-muted-foreground italic">
                        {translations.sectionOptional}
                      </span>
                    )}
                  </h2>
                  <div className="space-y-2">
                    <Label htmlFor="preferredLang">
                      {STRINGS.preferredLang}
                      <T k="preferredLang" />
                    </Label>
                    <Input
                      id="preferredLang"
                      value={form.preferredLang}
                      onChange={(e) =>
                        update("preferredLang")(e.target.value)
                      }
                    />
                  </div>
                </section>

                <div className="pt-2">
                  <Button type="submit" size="lg" className="w-full sm:w-auto">
                    {STRINGS.submit}
                    {translations.submit ? ` / ${translations.submit}` : ""}
                  </Button>
                </div>
              </form>
            </>
          ) : (
            <ThankYou
              englishOnly={englishOnly}
              onReset={reset}
              languageCode={form.parentLanguage}
            />
          )}
        </div>
      </main>

      <SiteFooter />
    </div>
  );
}

const THANK_YOU_STRINGS = {
  thankYou: "Thank you",
  recorded: "Your responses have been recorded for this demo.",
  nextStep: "Next step",
  englishOnlyMsg:
    "Based on the responses entered, no language other than English was reported. Follow your school or district process for final review.",
  otherLangMsg:
    "Based on the responses entered, a language other than English was reported. This student may need the next step in the English learner identification process. This form does not determine EL/EB status. Official identification requires school review and, when applicable, a state-approved English language proficiency assessment.",
  startAnother: "Start another demo response",
  backHome: "Back to home",
} as const;

type ThankYouKey = keyof typeof THANK_YOU_STRINGS;

function ThankYou({
  englishOnly,
  onReset,
  languageCode,
}: {
  englishOnly: boolean;
  onReset: () => void;
  languageCode: string;
}) {
  const [t, setT] = useState<Partial<Record<ThankYouKey, string>>>({});

  useEffect(() => {
    if (!languageCode || languageCode === "en") {
      setT({});
      return;
    }
    let cancelled = false;
    const keys = Object.keys(THANK_YOU_STRINGS) as ThankYouKey[];
    const sources = keys.map((k) => THANK_YOU_STRINGS[k]);
    translateStrings(sources, languageCode)
      .then((out) => {
        if (cancelled) return;
        const next: Partial<Record<ThankYouKey, string>> = {};
        keys.forEach((k, i) => {
          if (out[i] && out[i] !== THANK_YOU_STRINGS[k]) next[k] = out[i];
        });
        setT(next);
      })
      .catch(() => {
        if (!cancelled) setT({});
      });
    return () => {
      cancelled = true;
    };
  }, [languageCode]);

  const Bilingual = ({ k, as: As = "p", className = "" }: {
    k: ThankYouKey;
    as?: "p" | "h1" | "h2" | "span";
    className?: string;
  }) => {
    const translated = t[k];
    return (
      <As className={className}>
        {THANK_YOU_STRINGS[k]}
        {translated && (
          <span className="block italic opacity-90 mt-1">{translated}</span>
        )}
      </As>
    );
  };

  return (
    <div className="space-y-6">
      <div className="surface-card p-8 text-center">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary">
          <CheckCircle2 className="h-6 w-6" />
        </div>
        <Bilingual
          k="thankYou"
          as="h1"
          className="mt-4 text-2xl font-semibold text-foreground"
        />
        <Bilingual
          k="recorded"
          as="p"
          className="mt-2 text-muted-foreground"
        />
      </div>

      {englishOnly ? (
        <div className="rounded-2xl border border-border bg-secondary/60 p-6">
          <Bilingual
            k="nextStep"
            as="h2"
            className="font-semibold text-foreground"
          />
          <Bilingual
            k="englishOnlyMsg"
            as="p"
            className="mt-2 text-sm text-muted-foreground"
          />
        </div>
      ) : (
        <div className="rounded-2xl border border-primary/30 bg-primary/5 p-6">
          <div className="flex items-start gap-3">
            <AlertCircle className="h-5 w-5 mt-0.5 text-primary" />
            <div>
              <Bilingual
                k="nextStep"
                as="h2"
                className="font-semibold text-foreground"
              />
              <Bilingual
                k="otherLangMsg"
                as="p"
                className="mt-2 text-sm text-muted-foreground"
              />
            </div>
          </div>
        </div>
      )}

      <div className="flex flex-wrap gap-3">
        <Button onClick={onReset}>
          {THANK_YOU_STRINGS.startAnother}
          {t.startAnother ? ` / ${t.startAnother}` : ""}
        </Button>
        <Button asChild variant="outline">
          <Link to="/">
            {THANK_YOU_STRINGS.backHome}
            {t.backHome ? ` / ${t.backHome}` : ""}
          </Link>
        </Button>
      </div>
    </div>
  );
}

function LanguagePickerField({
  idPrefix,
  labelKey,
  langValue,
  otherValue,
  onLangChange,
  onOtherChange,
  translations,
  T,
}: {
  idPrefix: string;
  labelKey: StringKey;
  langValue: string;
  otherValue: string;
  onLangChange: (v: string) => void;
  onOtherChange: (v: string) => void;
  translations: Translations;
  T: (props: { k: StringKey }) => ReactNode;
}) {
  const showOther = langValue === OTHER_VALUE;
  return (
    <div className="space-y-3">
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-lang`}>
          {STRINGS[labelKey]}
          <T k={labelKey} />
        </Label>
        <Select
          value={langValue}
          onValueChange={onLangChange}
          required={!otherValue.trim()}
        >
          <SelectTrigger id={`${idPrefix}-lang`}>
            <SelectValue placeholder={STRINGS.pickLanguage} />
          </SelectTrigger>
          <SelectContent className="max-h-72">
            {GOOGLE_TRANSLATE_LANGUAGES.map((lang) => (
              <SelectItem key={lang.code} value={lang.name}>
                {lang.name}
              </SelectItem>
            ))}
            <SelectItem value={OTHER_VALUE}>Other / not listed</SelectItem>
          </SelectContent>
        </Select>
      </div>
      <div className="space-y-2">
        <Label
          htmlFor={`${idPrefix}-other`}
          className="text-sm font-normal text-muted-foreground"
        >
          {STRINGS.otherLanguage}
          {translations.otherLanguage && (
            <span className="block italic">{translations.otherLanguage}</span>
          )}
        </Label>
        <Input
          id={`${idPrefix}-other`}
          value={otherValue}
          required={showOther}
          placeholder=""
          onChange={(e) => onOtherChange(e.target.value)}
        />
      </div>
    </div>
  );
}
