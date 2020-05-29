## Git PR utility
Extending Github's [hub](https://hub.github.com/) to create pull requests with its title extracted from branch name and commit.

_Note: You may want to use [Code Copy](https://chrome.google.com/webstore/detail/codecopy/fkbfebkcoelajmhanocgppanfoojcdmg?hl=en) for copying below commands -_

### Prerequisites:
Setup [hub](https://hub.github.com/)
```bash
brew install hub
git config --global hub.protocol https

# optional - 
git config --global credential.helper store
```

Save github creds to hub(one time)
```
cd your-project/
hub browse -u 
```
> github.com username: udayrajMT
> github.com password for udayrajMT (never stored): 
> two-factor authentication code: 123456

### Setup
Save above gist as `~/bin/git-pr.sh`. (Make sure it has correct permissions: `mkdir -p ~/bin && sudo chown -R $USER:$GROUP ~/bin`)
```bash
curl https://gist.githubusercontent.com/udayrajMT/dba47cea248f54bae0ee8d27d9ac74bd/raw/git-pr.sh -o ~/bin/git-pr.sh
```
Make it executable
```bash
sudo chmod +x ~/bin/git-pr.sh
```

Add git alias: 
```bash
git config --global alias.pr '!bash ~/bin/git-pr.sh'
```
And done!
### Example usage:
```
git pr track/prod
git pr udayrajMT:track/prod 
git pr udayrajMT:track/prod "Custom title"
```


### Tips
Modify the script as you like for your convenience - 
1. To change title format, update `getPRTitle` function, 
2. To skip input for custom title, you may comment out `read -e -p` lines 

For skipping 2 factor auth, you can generate your [personal access token](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account) 
```
Username: your_username
Password: your_token
```