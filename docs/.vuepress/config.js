module.exports = {
  base: 'https://metanext.gitlab.io/devops-cloudday',
  dest: 'public',
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
      ['/list', 'Ownership'],
      ['/tmp/base.md', 'Composant Base'],
      ['/tmp/bastion.md', 'Composant Bastion'],
      ['/tmp/eks.md', 'Composant EKS'],
      ['/tmp/network.md', 'Composant Network'],
      ['/tmp/link.md', 'Composant Link'],
      ['/tmp/rds.md', 'Composant RDS'],
      ['/tmp/web.md', 'Composant Web'],
      ['/tmp/observability.md', 'Composant Observability'],
      ['/apps', 'Composants applicatifs'],
      ['/exemples', 'Examples']
    ],
    sidebarDepth: 2
  }
}
