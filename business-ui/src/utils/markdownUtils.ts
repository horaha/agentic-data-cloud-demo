export const markdownToHtml = (markdown: string): string => {
  if (!markdown) return '';

  // If it already looks like HTML, return as is
  const isHtml = /<\/?[a-z][\s\S]*>/i.test(markdown);
  if (isHtml) return markdown;

  let html = markdown;

  // Escape HTML entities to prevent XSS (but preserve any tags we generate later)
  html = html
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

  // Bold (**text**)
  html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');

  // Inline Code (`code`)
  html = html.replace(/`(.*?)`/g, '<code>$1</code>');

  // Headers (h1, h2, h3) with strong tags as used by Dataplex Console
  html = html.replace(/^#\s+(.*?)$/gm, '<h1><strong>$1</strong></h1>');
  html = html.replace(/^##\s+(.*?)$/gm, '<h2><strong>$1</strong></h2>');
  html = html.replace(/^###\s+(.*?)$/gm, '<h3><strong>$1</strong></h3>');

  // Unordered list items (- item)
  html = html.replace(/^\s*[-*]\s+(.*?)$/gm, '<li>$1</li>');

  // Wrap consecutive <li> elements in <ul>
  html = html.replace(/((?:<li>.*?<\/li>\s*)+)/gs, (match) => {
    return `<ul>\n${match.trim()}\n</ul>`;
  });

  // Paragraphs: split by double newlines, wrap non-HTML block lines in <p>
  const blocks = html.split(/\n\n+/);
  const parsedBlocks = blocks.map(block => {
    const trimmed = block.trim();
    if (!trimmed) return '';
    // If block starts with a block tag (h1, h2, h3, ul), return as is
    if (/^<(h1|h2|h3|ul|pre)/.test(trimmed)) {
      return trimmed;
    }
    // Otherwise wrap in <p> and replace single newlines with <br />
    return `<p>${trimmed.replace(/\n/g, '<br />')}</p>`;
  });

  return parsedBlocks.filter(Boolean).join('\n');
};

export const htmlToMarkdown = (html: string): string => {
  if (!html) return '';

  let md = html;

  // Headings with strong inside
  md = md.replace(/<h1><strong>(.*?)<\/strong><\/h1>/g, '# $1');
  md = md.replace(/<h1>(.*?)<\/h1>/g, '# $1');
  md = md.replace(/<h2><strong>(.*?)<\/strong><\/h2>/g, '## $1');
  md = md.replace(/<h2>(.*?)<\/h2>/g, '## $1');
  md = md.replace(/<h3><strong>(.*?)<\/strong><\/h3>/g, '### $1');
  md = md.replace(/<h3>(.*?)<\/h3>/g, '### $1');

  // Bold
  md = md.replace(/<strong>(.*?)<\/strong>/g, '**$1**');

  // Inline Code
  md = md.replace(/<code>(.*?)<\/code>/g, '`$1`');

  // List Items
  md = md.replace(/<li>(.*?)<\/li>/g, '- $1');

  // Strip <ul> and </ul>
  md = md.replace(/<\/?ul>/g, '');

  // Paragraphs
  md = md.replace(/<p>(.*?)<\/p>/g, '$1\n\n');

  // Line breaks
  md = md.replace(/<br\s*\/?>/g, '\n');

  // Unescape HTML entities
  md = md.replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&amp;/g, '&');

  return md.trim();
};
