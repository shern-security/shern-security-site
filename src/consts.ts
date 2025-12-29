export interface CardTheme {
  textColor: string;
  backgroundClass: string;
  accentColor: string;
  borderColor: string;
  subtleColor: string;
  decorativeLineColor: string;
  numberColor: string;
  backgroundColor: string;
  backgroundImage?: string;
  gradient?: string;
  titleColor: string;
  titleFontSize: string;
  titleFontWeight: string;
  titleFontFamily?: string;
  descriptionColor: string;
  descriptionFontSize: string;
  descriptionFontFamily?: string;
  sectionTitleColor: string;
  sectionTitleFontSize: string;
  sectionTitleFontWeight: string;
  sectionTitleFontFamily?: string;
  keyPointColor: string;
  keyPointFontSize: string;
  keyPointFontFamily?: string;
  numberBackgroundColor: string;
  numberTextColor: string;
  numberFontWeight: string;
  numberFontFamily?: string;
  decorativeLineWidth: string;
  decorativeLineHeight: string;
  fontFamily?: string;
  linkColor: string;
}

export interface SlideTheme {
  background: string;
  type: "solid" | "gradient";
  titleFont: string;
  titleWeight: number | "normal" | "bold";
  titleTransform: "uppercase" | "none" | "capitalize" | "lowercase";
  textFont: string;
  titleColor: string;
  textColor: string;
  overlayColor: string;
}

export const SITE_TITLE = "Shern Security";
export const SITE_DESCRIPTION = "Professional Cybersecurity Services & Innovative Solutions";

export const PROD_URL = "https://shernsecurity.com";

export const isProdEnv = () => {
  if (import.meta.env?.PROD || import.meta.env?.MODE === "production") {
    return true;
  }

  if (typeof window !== "undefined") {
    return window.location.origin === PROD_URL;
  }

  return false;
};

export const isProd = isProdEnv();

export const ASSETS_IMAGES_PREFIX = "/src/assets/images";

export const MERMAID_LIVE_BASE_URL = "https://mermaid.live";

export interface MenuItem {
  id: string;
  label: string;
  href: string;
  showWhenLoggedOut?: boolean;
  showWhenLoggedIn?: boolean;
  title?: string;
  description?: string;
}

export const MENU_ITEMS: MenuItem[] = [
  {
    id: "blogs",
    label: "Blog",
    href: "/blogs",
    title: "Blog",
    description:
      "Cybersecurity insights, technical guides, and lessons from the field.",
  },
  {
    id: "resume",
    label: "Resume",
    href: "/resume",
    title: "Resume",
    description: "Professional experience and qualifications.",
  },
  {
    id: "access-granted",
    label: "Access Granted",
    href: "/access-granted",
    title: "Access Granted",
    description: "Teaching digital citizenship through positive reinforcement.",
  },
  {
    id: "cards",
    label: "Cards",
    href: "/cards",
    title: "Cards",
    description: "Quick notes and security summaries.",
  },
];

export const getNavigationItems = (): MenuItem[] => {
  return MENU_ITEMS;
};

export const DOODLE_EMOJIS = [
  "✨",
  "🚀",
  "💡",
  "🎉",
  "🔥",
  "🌟",
  "🤖",
  "🎃",
  "🔊",
  "📡",
];
