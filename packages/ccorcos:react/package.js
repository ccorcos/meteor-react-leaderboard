Package.describe({
  name: 'ccorcos:react',
  version: '0.12.2',
  git: 'https://github.com/ccorcos/meteor-react-leaderboard'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@1');
  api.addFiles(['react.js',], 'client');
});