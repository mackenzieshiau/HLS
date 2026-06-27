import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import { toast } from "sonner";
import { Check, X } from "lucide-react";

type PasswordCheck = { label: string; ok: boolean };

function evaluatePassword(pw: string): {
  checks: PasswordCheck[];
  score: number;
  label: string;
  color: string;
} {
  const checks: PasswordCheck[] = [
    { label: "At least 8 characters", ok: pw.length >= 8 },
    { label: "Uppercase letter", ok: /[A-Z]/.test(pw) },
    { label: "Lowercase letter", ok: /[a-z]/.test(pw) },
    { label: "Number", ok: /\d/.test(pw) },
    { label: "Symbol (!@#$…)", ok: /[^A-Za-z0-9]/.test(pw) },
  ];
  const score = checks.filter((c) => c.ok).length;
  const label =
    score <= 1 ? "Very weak" :
    score === 2 ? "Weak" :
    score === 3 ? "Fair" :
    score === 4 ? "Strong" : "Very strong";
  const color =
    score <= 1 ? "bg-destructive" :
    score === 2 ? "bg-orange-500" :
    score === 3 ? "bg-yellow-500" :
    score === 4 ? "bg-lime-500" : "bg-green-500";
  return { checks, score, label, color };
}

export type ProfilePrefs = {
  display_name: string | null;
  theme: "light" | "dark";
  forms_view: "list" | "cards";
};

type Props = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  userId: string;
  profile: ProfilePrefs;
  onSaved: (next: ProfilePrefs) => void;
};

export function ProfileDialog({ open, onOpenChange, userId, profile, onSaved }: Props) {
  const [displayName, setDisplayName] = useState(profile.display_name ?? "");
  const [theme, setTheme] = useState<"light" | "dark">(profile.theme);
  const [formsView, setFormsView] = useState<"list" | "cards">(profile.forms_view);
  const [newPassword, setNewPassword] = useState("");
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (open) {
      setDisplayName(profile.display_name ?? "");
      setTheme(profile.theme);
      setFormsView(profile.forms_view);
      setNewPassword("");
    }
  }, [open, profile]);

  const handleSave = async () => {
    setSaving(true);
    const { error } = await supabase
      .from("profiles")
      .update({
        display_name: displayName.trim() || null,
        theme,
        forms_view: formsView,
      })
      .eq("id", userId);

    if (error) {
      setSaving(false);
      toast.error("Failed to save profile");
      return;
    }

    if (newPassword) {
      const { score } = evaluatePassword(newPassword);
      if (newPassword.length < 8 || score < 3) {
        setSaving(false);
        toast.error("Password is too weak — meet at least 3 of the requirements and use 8+ characters");
        return;
      }
      const { error: pwError } = await supabase.auth.updateUser({
        password: newPassword,
      });
      if (pwError) {
        setSaving(false);
        toast.error(pwError.message);
        return;
      }
    }

    setSaving(false);
    toast.success("Profile updated");
    onSaved({
      display_name: displayName.trim() || null,
      theme,
      forms_view: formsView,
    });
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Profile settings</DialogTitle>
          <DialogDescription>
            Update your name, password, and display preferences.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="display-name">Name</Label>
            <Input
              id="display-name"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder="Your name"
            />
          </div>

          <Separator />

          <div className="space-y-2">
            <Label htmlFor="new-password">New password</Label>
            <Input
              id="new-password"
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="Leave blank to keep current"
              minLength={8}
              autoComplete="new-password"
              aria-describedby="password-help"
            />
            {newPassword && (() => {
              const { checks, score, label, color } = evaluatePassword(newPassword);
              return (
                <div id="password-help" className="space-y-2 pt-1">
                  <div className="flex items-center gap-2">
                    <div className="flex-1 h-1.5 rounded-full bg-muted overflow-hidden">
                      <div
                        className={`h-full transition-all ${color}`}
                        style={{ width: `${(score / 5) * 100}%` }}
                      />
                    </div>
                    <span className="text-xs text-muted-foreground tabular-nums w-20 text-right">
                      {label}
                    </span>
                  </div>
                  <ul className="text-xs space-y-1">
                    {checks.map((c) => (
                      <li
                        key={c.label}
                        className={`flex items-center gap-1.5 ${
                          c.ok ? "text-foreground" : "text-muted-foreground"
                        }`}
                      >
                        {c.ok ? (
                          <Check className="h-3.5 w-3.5 text-green-600" />
                        ) : (
                          <X className="h-3.5 w-3.5 text-muted-foreground/60" />
                        )}
                        {c.label}
                      </li>
                    ))}
                  </ul>
                </div>
              );
            })()}
          </div>

          <Separator />

          <div className="space-y-2">
            <Label>Theme</Label>
            <Select value={theme} onValueChange={(v) => setTheme(v as "light" | "dark")}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="light">Light</SelectItem>
                <SelectItem value="dark">Dark</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>Forms display</Label>
            <Select
              value={formsView}
              onValueChange={(v) => setFormsView(v as "list" | "cards")}
            >
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="list">List (default)</SelectItem>
                <SelectItem value="cards">Cards</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} disabled={saving}>
            Cancel
          </Button>
          <Button onClick={handleSave} disabled={saving}>
            {saving ? "Saving…" : "Save changes"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export function applyTheme(theme: "light" | "dark") {
  if (typeof document === "undefined") return;
  document.documentElement.classList.toggle("dark", theme === "dark");
}
