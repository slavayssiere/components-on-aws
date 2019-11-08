module.exports = {
  base: '/components-on-aws',
  dest: 'dist',
  title: 'AWS Components',
  description: 'Some AWS Components orchestration',
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/how-to' },
      { text: 'AWS', link: 'https://eu-west-1.console.aws.amazon.com/' },
      {
        text: 'Languages',
        items: [
          { text: 'French', link: '/language/french' }
        ]
      },
      
    ],
    sidebar: [
      '/',
      ['/how-to', 'Guide'],
      ['/list', 'Composants'],
      ['/exemples', 'Examples']
    ],
    sidebarDepth: 2
  },
  scripts: {
    "docs:build": "vuepress build docs"
  }
}
