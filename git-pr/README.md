# Git PR utility
Create pull requests from command line with its title extracted from branch name and commit.

## Prerequisites:
_Note: You may want to use [Code Copy](https://chrome.google.com/webstore/detail/codecopy/fkbfebkcoelajmhanocgppanfoojcdmg?hl=en) for copying below commands -_

1. Install [hub](https://hub.github.com/)  
```bash  
# for osx -
brew install hub
git config --global hub.protocol https

# optional - saves credentials in git
git config --global credential.helper store
```  

2. Go to any git project to trigger hub to ask credentials for the first time:
```
cd any-git-project/
hub browse -u 
```
Note: hub also supports 2 factor authentication.

## Setup
1. Save above script as `~/bin/git-pr.sh`.  
(Make sure it has correct permissions: `mkdir -p ~/bin && sudo chown -R $USER:$GROUP ~/bin`)  
```bash
curl https://raw.githubusercontent.com/Udayraj123/shell-scripts/master/git-pr/git-pr.sh -o ~/bin/git-pr.sh
```

2. Make it executable  
```bash
sudo chmod +x ~/bin/git-pr.sh
```

3. Add git alias of your choice:  
```bash
git config --global alias.pr '!bash ~/bin/git-pr.sh'
```

And done!

## Usage:
```
Usage: git pr [owner:]branch [<message>]
```

Examples -
```
cd your-project/
git pr track/prod
git pr udayraj123:track/prod 
git pr udayraj123:track/prod "Custom title"
```


## Tips
1. Modify the script as you like for your convenience -  
    1. To change title format, update `getPRTitle` function,
    2. To skip input for custom title, you may comment out the call to `confirmTitle`

2. For skipping 2 factor auth, you can generate your [personal access token](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account) 