// Languages supported by Google Translate with ISO codes.
export type Language = { name: string; code: string };

export const GOOGLE_TRANSLATE_LANGUAGES: Language[] = [
  { name: "Afrikaans", code: "af" },
  { name: "Albanian", code: "sq" },
  { name: "Amharic", code: "am" },
  { name: "Arabic", code: "ar" },
  { name: "Armenian", code: "hy" },
  { name: "Assamese", code: "as" },
  { name: "Aymara", code: "ay" },
  { name: "Azerbaijani", code: "az" },
  { name: "Bambara", code: "bm" },
  { name: "Basque", code: "eu" },
  { name: "Belarusian", code: "be" },
  { name: "Bengali", code: "bn" },
  { name: "Bhojpuri", code: "bho" },
  { name: "Bosnian", code: "bs" },
  { name: "Bulgarian", code: "bg" },
  { name: "Catalan", code: "ca" },
  { name: "Cebuano", code: "ceb" },
  { name: "Chichewa", code: "ny" },
  { name: "Chinese (Simplified)", code: "zh-CN" },
  { name: "Chinese (Traditional)", code: "zh-TW" },
  { name: "Corsican", code: "co" },
  { name: "Croatian", code: "hr" },
  { name: "Czech", code: "cs" },
  { name: "Danish", code: "da" },
  { name: "Dhivehi", code: "dv" },
  { name: "Dogri", code: "doi" },
  { name: "Dutch", code: "nl" },
  { name: "English", code: "en" },
  { name: "Esperanto", code: "eo" },
  { name: "Estonian", code: "et" },
  { name: "Ewe", code: "ee" },
  { name: "Filipino", code: "tl" },
  { name: "Finnish", code: "fi" },
  { name: "French", code: "fr" },
  { name: "Frisian", code: "fy" },
  { name: "Galician", code: "gl" },
  { name: "Georgian", code: "ka" },
  { name: "German", code: "de" },
  { name: "Greek", code: "el" },
  { name: "Guarani", code: "gn" },
  { name: "Gujarati", code: "gu" },
  { name: "Haitian Creole", code: "ht" },
  { name: "Hausa", code: "ha" },
  { name: "Hawaiian", code: "haw" },
  { name: "Hebrew", code: "he" },
  { name: "Hindi", code: "hi" },
  { name: "Hmong", code: "hmn" },
  { name: "Hungarian", code: "hu" },
  { name: "Icelandic", code: "is" },
  { name: "Igbo", code: "ig" },
  { name: "Ilocano", code: "ilo" },
  { name: "Indonesian", code: "id" },
  { name: "Irish", code: "ga" },
  { name: "Italian", code: "it" },
  { name: "Japanese", code: "ja" },
  { name: "Javanese", code: "jw" },
  { name: "Kannada", code: "kn" },
  { name: "Kazakh", code: "kk" },
  { name: "Khmer", code: "km" },
  { name: "Kinyarwanda", code: "rw" },
  { name: "Konkani", code: "gom" },
  { name: "Korean", code: "ko" },
  { name: "Krio", code: "kri" },
  { name: "Kurdish (Kurmanji)", code: "ku" },
  { name: "Kurdish (Sorani)", code: "ckb" },
  { name: "Kyrgyz", code: "ky" },
  { name: "Lao", code: "lo" },
  { name: "Latin", code: "la" },
  { name: "Latvian", code: "lv" },
  { name: "Lingala", code: "ln" },
  { name: "Lithuanian", code: "lt" },
  { name: "Luganda", code: "lg" },
  { name: "Luxembourgish", code: "lb" },
  { name: "Macedonian", code: "mk" },
  { name: "Maithili", code: "mai" },
  { name: "Malagasy", code: "mg" },
  { name: "Malay", code: "ms" },
  { name: "Malayalam", code: "ml" },
  { name: "Maltese", code: "mt" },
  { name: "Maori", code: "mi" },
  { name: "Marathi", code: "mr" },
  { name: "Meiteilon (Manipuri)", code: "mni-Mtei" },
  { name: "Mizo", code: "lus" },
  { name: "Mongolian", code: "mn" },
  { name: "Myanmar (Burmese)", code: "my" },
  { name: "Nepali", code: "ne" },
  { name: "Norwegian", code: "no" },
  { name: "Odia (Oriya)", code: "or" },
  { name: "Pashto", code: "ps" },
  { name: "Persian", code: "fa" },
  { name: "Polish", code: "pl" },
  { name: "Portuguese", code: "pt" },
  { name: "Punjabi", code: "pa" },
  { name: "Quechua", code: "qu" },
  { name: "Romanian", code: "ro" },
  { name: "Russian", code: "ru" },
  { name: "Samoan", code: "sm" },
  { name: "Sanskrit", code: "sa" },
  { name: "Scots Gaelic", code: "gd" },
  { name: "Sepedi", code: "nso" },
  { name: "Serbian", code: "sr" },
  { name: "Sesotho", code: "st" },
  { name: "Shona", code: "sn" },
  { name: "Sindhi", code: "sd" },
  { name: "Sinhala", code: "si" },
  { name: "Slovak", code: "sk" },
  { name: "Slovenian", code: "sl" },
  { name: "Somali", code: "so" },
  { name: "Spanish", code: "es" },
  { name: "Sundanese", code: "su" },
  { name: "Swahili", code: "sw" },
  { name: "Swedish", code: "sv" },
  { name: "Tajik", code: "tg" },
  { name: "Tamil", code: "ta" },
  { name: "Tatar", code: "tt" },
  { name: "Telugu", code: "te" },
  { name: "Thai", code: "th" },
  { name: "Tigrinya", code: "ti" },
  { name: "Tsonga", code: "ts" },
  { name: "Turkish", code: "tr" },
  { name: "Turkmen", code: "tk" },
  { name: "Twi", code: "ak" },
  { name: "Ukrainian", code: "uk" },
  { name: "Urdu", code: "ur" },
  { name: "Uyghur", code: "ug" },
  { name: "Uzbek", code: "uz" },
  { name: "Vietnamese", code: "vi" },
  { name: "Welsh", code: "cy" },
  { name: "Xhosa", code: "xh" },
  { name: "Yiddish", code: "yi" },
  { name: "Yoruba", code: "yo" },
  { name: "Zulu", code: "zu" },
];

const SEP = "\n|||\n";

/**
 * Translate an array of English strings into a target language using
 * Google's free public translate endpoint (no API key required).
 * Batches all strings into a single request.
 */
export async function translateStrings(
  strings: string[],
  targetCode: string,
): Promise<string[]> {
  if (!targetCode || targetCode === "en") return strings;
  const joined = strings.join(SEP);
  const url =
    "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&dt=t&q=" +
    encodeURIComponent(joined) +
    "&tl=" +
    encodeURIComponent(targetCode);

  const res = await fetch(url);
  if (!res.ok) throw new Error("Translation request failed");
  const data = (await res.json()) as unknown;
  // Response shape: [[[ "translated chunk", "original chunk", ... ], ...], ...]
  const chunks: string[] = [];
  if (Array.isArray(data) && Array.isArray((data as unknown[])[0])) {
    for (const row of (data as unknown[][])[0]) {
      if (Array.isArray(row) && typeof row[0] === "string") {
        chunks.push(row[0] as string);
      }
    }
  }
  const combined = chunks.join("");
  const parts = combined.split(SEP.trim());
  // Fallback if separator didn't survive the round-trip
  if (parts.length !== strings.length) return strings;
  return parts.map((p) => p.trim());
}
