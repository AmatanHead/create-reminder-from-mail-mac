# Create reminder from mail for Mac OS X

Create a reminder from a selected email message.

### Screenshots

![](https://github.com/AmatanHead/create-reminder-from-mail-mac/blob/master/screenshots/create_task.png)
![](https://github.com/AmatanHead/create-reminder-from-mail-mac/blob/master/screenshots/set_time.png)
![](https://github.com/AmatanHead/create-reminder-from-mail-mac/blob/master/screenshots/already_exists.png)
![](https://github.com/AmatanHead/create-reminder-from-mail-mac/blob/master/screenshots/task_list.png)

### Installation

For installation follow Michaels page while using the script here. Basically you 

- create in Automator a service with no input and only for Mail.app
- add a step that executes AppleScript (and replace the given code by this one)
- save it in ~/Library/Service with some useful name like "Create Reminder from Email"
- and give it a Keyboard shortcut under System Preferences > Keyboard > Shortcuts > Services 

Find a step by step description on [mackungfu.org](http://www.mackungfu.org/create-email-reminders-within-email-app).
