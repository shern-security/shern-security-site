import { getPermalink, getBlogPermalink, getAsset } from './utils/permalinks';

export const headerData = {
  links: [
    {
      text: 'Articles',
      href: getBlogPermalink(),
    },
    {
      text: 'Resume',
      href: getPermalink('/resume'),
    },
    {
      text: 'Products',
      href: getPermalink('/products'),
    },
    {
      text: 'About',
      href: getPermalink('/about'),
    },
  ],
  actions: [{ text: 'Contact', href: getPermalink('/contact') }],
};

export const footerData = {
  links: [
    {
      title: 'Navigation',
      links: [
        { text: 'Articles', href: getBlogPermalink() },
        { text: 'Resume', href: getPermalink('/resume') },
        { text: 'Products', href: getPermalink('/products') },
        { text: 'About', href: getPermalink('/about') },
      ],
    },
    {
      title: 'Company',
      links: [
        { text: 'About', href: getPermalink('/about') },
        { text: 'Contact', href: getPermalink('/contact') },
      ],
    },
  ],
  secondaryLinks: [
    { text: 'Terms', href: getPermalink('/terms') },
    { text: 'Privacy Policy', href: getPermalink('/privacy') },
  ],
  socialLinks: [
    { ariaLabel: 'X', icon: 'tabler:brand-x', href: 'https://twitter.com/jonshern' },
    { ariaLabel: 'LinkedIn', icon: 'tabler:brand-linkedin', href: 'https://linkedin.com/in/jonshern' },
    { ariaLabel: 'RSS', icon: 'tabler:rss', href: getAsset('/rss.xml') },
    { ariaLabel: 'Github', icon: 'tabler:brand-github', href: 'https://github.com/shern-security' },
  ],
  footNote: `
    © ${new Date().getFullYear()} Shern Security. All rights reserved.
  `,
};
