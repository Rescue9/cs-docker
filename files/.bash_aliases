# SSH Agent
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> ~/.ssh/ssh-agent
   fi
   eval `cat ~/.ssh/ssh-agent`
fi

# My bin
export MYBIN=$HOME/bin
export PATH=$PATH:$MYBIN

# SDK Paths
export SDKS=$HOME/sdks
export PATH=$PATH:$SDKS/flutter/bin
export PATH=$PATH:$SDKS/jdk-21.0.10+7/bin

# Android
export ANDROID_HOME=$SDKS/android
export ANDROID_SDK_ROOT=$ANDROID_HOME

export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Google Chrome
#export CHROME_EXECUTABLE=$MYBIN/chrome-no-sandbox.sh