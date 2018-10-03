#################################################################################
# Title: Create reminder from selected Mail
#################################################################################

# Use at your own risk and responsibility
# Backup your data before use

# Last update: 2018-10-03
# Version: 0.6.0
# Tested on OS X 10.13.5 High Sierra

# Description
# When installed as a Service, this AppleScript script can be used to automatically create a reminder (in pre-defined Reminder lists)
# from a selected email and flag the email.
# If you run the script against an email that matches an existing reminder it can mark the reminder as completed and clear the flag in Mail

# Adapted from https://github.com/moritzregnier/create-reminder-from-mail-mac

on run {input, parameters}
	set DefaultReminderList to "tasks"
	set FlagIndex to 5
	set defaultReminder to "Tomorrow"
	set defaultReminderTime to "12"
	
	tell application "Mail"
		set theSelection to selection as list
		# do nothing if no email is selected in Mail
		try
			set theMessage to item 1 of theSelection
		on error
			return
		end try
		
		set theSubject to theMessage's subject
		set theOrigMessageId to theMessage's message id
		set theUrl to {"message:%3C" & my replaceText(theOrigMessageId, "%", "%25") & "%3E"}
		
		tell application "Reminders"
			set theNeedlesName to name of reminders whose body is theUrl and completed is false
			if theNeedlesName is not {} then
				tell application "Mail"
					set theButton to button returned of (display dialog "Edit '" & theNeedlesName & "'" with icon note buttons {"New date", "Cancel", "Mark complete"} default button "Mark complete" cancel button "Cancel")
				end tell
				
				if theButton is "Mark complete" then
					tell application "Mail"
						# unflag email/message
						set flag index of theMessage to -1
					end tell
					# find correct reminder based on subject and mark as complete
					set theNeedle to last reminder whose body is theUrl and completed is false
					set completed of theNeedle to true
					return
				else if theButton is "New date" then
					# set the new reminder date
					
					tell application "Mail"
						# present user with a list of follow-up times (in minutes)
						(choose from list {"15 Minutes", "1 Hour", "5 Hours", "Tomorrow", "End of Week", "Next Monday", "1 Week", "1 Month", "Specify"} default items defaultReminder with prompt "New time for '" & theNeedlesName & "':")
					end tell
					set reminderDate to result as text
					
					# Exit if user clicks Cancel
					if reminderDate is "false" then return
					
					# choose the reminder date
					set remindMeDate to my chooseRemindMeDate(reminderDate, defaultReminderTime)
					
					# find correct reminder based on subject and update it
					set theNeedle to last reminder whose body is theUrl and completed is false
					set remind me date of theNeedle to remindMeDate
					return
				else if theButton is "Cancel" then
					return
				end if
			end if
		end tell
		
		set res to display dialog "Remind me about:" with icon note default answer theSubject
		
		set theSubjectChoice to button returned of res
		
		if theSubjectChoice is "Cancel" then
			return
		end if
		
		set theSubject to text returned of res
		
		(choose from list {"15 Minutes", "1 Hour", "5 Hours", "Tomorrow", "End of Week", "Next Monday", "1 Week", "1 Month", "Specify"} default items defaultReminder with prompt "Time for '" & theSubject & "':")
		
		set reminderDate to result as rich text
		
		# Exit if user clicks Cancel
		if reminderDate is "false" then return
		
		# choose the reminder date
		set remindMeDate to my chooseRemindMeDate(reminderDate, defaultReminderTime)
		
		set flag index of theMessage to FlagIndex
		
		set theOrigMessageId to theMessage's message id
		
		set theUrl to {"message:%3C" & my replaceText(theOrigMessageId, "%", "%25") & "%3E"}
		
		set RemindersList to DefaultReminderList
	end tell
	
	tell application "Reminders"
		tell list RemindersList
			# create new reminder with proper due date, subject name and the URL linking to the email in Mail
			make new reminder with properties {name:theSubject, remind me date:remindMeDate, body:theUrl}
		end tell
	end tell
	
end run

# string replace function
# used to replace % with %25
on replaceText(subject, find, replace)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject
	
	set text item delimiters of AppleScript to replace
	set subject to "" & subject
	set text item delimiters of AppleScript to prevTIDs
	
	return subject
end replaceText


# date calculation with the selection from the dialogue
# use to set the initial and the re-scheduled date
on chooseRemindMeDate(selectedDate, defaultReminderTime)
	if selectedDate = "15 Minutes" then
		set remindMeDate to (current date) + 15 * minutes
		return remindMeDate
	else if selectedDate = "1 Hour" then
		set remindMeDate to (current date) + 1 * hours
		return remindMeDate
	else if selectedDate = "5 Hours" then
		set remindMeDate to (current date) + 5 * hours
		return remindMeDate
	else if selectedDate = "Tomorrow" then
		set remindMeDate to (current date) + 1 * days
	else if selectedDate = "End of Week" then
		# end of week means Thursday in terms of reminders
		# get the current day of the week
		set curWeekDay to weekday of (current date) as string
		if curWeekDay = "Monday" then
			set remindMeDate to (current date) + 3 * days
		else if curWeekDay = "Tuesday" then
			set remindMeDate to (current date) + 2 * days
		else if curWeekDay = "Wednesday" then
			set remindMeDate to (current date) + 1 * days
			# if it's Thursday, I'll set the reminder for Friday
		else if curWeekDay = "Thursday" then
			set remindMeDate to (current date) + 1 * days
			# if it's Friday I'll set the reminder for Thursday next week
		else if curWeekDay = "Friday" then
			set remindMeDate to (current date) + 6 * days
		else if curWeekDay = "Saturday" then
			set remindMeDate to (current date) + 5 * days
		else if curWeekDay = "Sunday" then
			set remindMeDate to (current date) + 4 * days
		end if
	else if selectedDate = "Next Monday" then
		set curWeekDay to weekday of (current date) as string
		if curWeekDay = "Monday" then
			set remindMeDate to (current date) + 7 * days
		else if curWeekDay = "Tuesday" then
			set remindMeDate to (current date) + 6 * days
		else if curWeekDay = "Wednesday" then
			set remindMeDate to (current date) + 5 * days
		else if curWeekDay = "Thursday" then
			set remindMeDate to (current date) + 4 * days
		else if curWeekDay = "Friday" then
			set remindMeDate to (current date) + 3 * days
		else if curWeekDay = "Saturday" then
			set remindMeDate to (current date) + 2 * days
		else if curWeekDay = "Sunday" then
			set remindMeDate to (current date) + 1 * days
		end if
	else if selectedDate = "1 Week" then
		set remindMeDate to (current date) + 7 * days
	else if selectedDate = "1 Month" then
		set remindMeDate to (current date) + 28 * days
	else if selectedDate = "Specify" then
		# adapt the date format suggested with what is configured in the user's 'Language/Region'-Preferences
		set theDateSuggestion to (short date string of (current date))
		tell application "Mail"
			set theDateInput to text returned of (display dialog "Reminder date: (e.g. '" & theDateSuggestion & "'):" default answer theDateSuggestion buttons {"OK"} default button "OK")
		end tell
		try
			set remindMeDate to date theDateInput
		on error
			set remindMeDate to (current date) + 1 * days
			(display dialog "There was an error with the date input provided: '" & theDateInput & "'. The reminder was set to tomorrow.")
		end try
	end if
	
	set time of remindMeDate to 60 * 60 * defaultReminderTime
	
	return remindMeDate
end chooseRemindMeDate
