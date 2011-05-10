-- memorygame.applescript
-- memorygame

--  Created by patrick collins on 5/12/07.
--  Copyright 2007 Collinator Studios All rights reserved.

script recordSearch
	property l : missing value
	
	on seekTitle(recordList, theTitle)
		set my l to recordList
		set finds to {}
		
		considering case
			repeat with i from 1 to (count recordList)
				if (name of item i of my l is theTitle) then
					set finds to item i of my l
					exit repeat
				end if
			end repeat
			
		end considering
		return finds
	end seekTitle
end script

property is_correct : false
property image_path : missing value
property the_selection : missing value
property image_list : missing value
property image_load_list : missing value
property view_number : missing value
property error_messages : missing value
property the_state : missing value
property correct_list : missing value
property error_count : missing value
property correct_count : missing value
property reveal_count : missing value
property reveal_state : missing value
property current_sound : missing value
property snd_correct1 : missing value
property snd_correct2 : missing value
property snd_correct3 : missing value
property snd_correct4 : missing value
property snd_startgame : missing value
property snd_reveal : missing value
property snd_wrong : missing value
property snd_tick : missing value
property unknown_image : missing value
property order_list : {}
property interrupt : false
property game_begin : missing value
property reveal_mode : missing value
property reveal_num : missing value
property reveal_speed : missing value
property reveal_seconds : missing value
property real_speed : missing value
property show_comments : missing value
property show_comments_reveal : missing value
property comment_list : missing value
property edit_image_info : missing value
property all_images : missing value
property page_number : 1
property page_turn : false
property page_start : 1
property idle_count : 3
property correct_idle_count : 1
property current_selection : missing value
property alert_items : {"How good is Your Memory?", "Test Your Memory Skills!", "Is Your Memory Good?", "How Well Can You Remember Things?"}

on will finish launching theObject
	--my generateImageRecords()
	set visible of window "paypal" to false
	tell window "window"
		tell progress indicator "statusbar" to start
	end tell
	set view_number to 20
	
	repeat with current_number from 1 to view_number
		copy current_number to the end of order_list
	end repeat
	
	set image_path to POSIX path of (path to me as string) & "Contents/Resources/image/"
	set the_images to do shell script "cd " & image_path & ";ls *"
	set the_images to paragraphs of result
	set all_images to the_images
	
	if (count items in the_images) < (view_number / 2) then
		display dialog "Not enough images to play!!! Please add more!" buttons {"Ok"} default button 1
		quit
	end if
	set game_begin to false
	set edit_image_info to false
	set visible of window "preferences" to false
	make new default entry at end of default entries of user defaults with properties {name:"score"}
	make new default entry at end of default entries of user defaults with properties {name:"reveal_mode"}
	make new default entry at end of default entries of user defaults with properties {name:"reveal_seconds"}
	make new default entry at end of default entries of user defaults with properties {name:"reveal_speed"}
	make new default entry at end of default entries of user defaults with properties {name:"reveal_num"}
	make new default entry at end of default entries of user defaults with properties {name:"show_comments"}
	make new default entry at end of default entries of user defaults with properties {name:"show_comments_reveal"}
	make new default entry at end of default entries of user defaults with properties {name:"donation"}
	set score to contents of default entry "score" of user defaults
	set reveal_mode to contents of default entry "reveal_mode" of user defaults
	set reveal_speed to contents of default entry "reveal_speed" of user defaults
	set reveal_seconds to contents of default entry "reveal_seconds" of user defaults
	set reveal_num to contents of default entry "reveal_num" of user defaults
	set show_comments to contents of default entry "show_comments" of user defaults
	set show_comments_reveal to contents of default entry "show_comments_reveal" of user defaults
	set donation to contents of default entry "donation" of user defaults
	
	try
		score
		donation
	on error
		set contents of default entry "score" of user defaults to "blank"
		call method "synchronize" of object user defaults
		set score to contents of default entry "score" of user defaults
	end try
	
	try
		donation
	on error
		set contents of default entry "donation" of user defaults to ""
		call method "synchronize" of object user defaults
		set donation to contents of default entry "donation" of user defaults
	end try
	
	try
		reveal_mode
		reveal_speed
		reveal_seconds
		reveal_num
		show_comments
	on error
		set contents of default entry "reveal_mode" of user defaults to "all"
		set contents of default entry "reveal_speed" of user defaults to "50"
		set contents of default entry "reveal_seconds" of user defaults to "5"
		set contents of default entry "reveal_num" of user defaults to "3"
		set contents of default entry "show_comments" of user defaults to true
		set contents of default entry "show_comments_reveal" of user defaults to false
		call method "synchronize" of object user defaults
		set reveal_mode to contents of default entry "reveal_mode" of user defaults
		set reveal_speed to contents of default entry "reveal_speed" of user defaults
		set reveal_seconds to contents of default entry "reveal_seconds" of user defaults
		set reveal_num to contents of default entry "reveal_num" of user defaults
		set show_comments to contents of default entry "show_comments" of user defaults
		set show_comments_reveal to contents of default entry "show_comments_reveal" of user defaults
	end try
	
	set contents of text field "revealSeconds" of window "preferences" to reveal_seconds
	set contents of text field "revealNum" of window "preferences" to reveal_num
	
	set real_speed to my getrealspeed(reveal_speed as integer)
	set snd_correct1 to load sound "correct1"
	set snd_correct2 to load sound "correct2"
	set snd_correct3 to load sound "correct3"
	set snd_correct4 to load sound "correct4"
	set snd_startgame to load sound "startgame"
	set snd_reveal to load sound "error"
	set snd_wrong to load sound "error2"
	set snd_tick to load sound "Pop"
	set unknown_image to load image (POSIX path of (path to me as string) & "Contents/Resources/unknown.png")
	
	if donation ­ "true" then
		set visible of window "paypal" to true
		beep
	end if
end will finish launching

on awake from nib theObject
	tell window "window"
		set the contents of text field "statusField" to item 1 of alert_items
	end tell
	my startGame()
	set order_list to my Rand2(order_list)
	call method "setHidden:" of (text field "scoreField" of window "window") without with parameter
	call method "setHidden:" of (text field "correctField" of window "window") without with parameter
	call method "setHidden:" of (text field "revealField" of window "window") without with parameter
	call method "setHidden:" of (text field "errorField" of window "window") without with parameter
	call method "setHidden:" of (text field "statusField" of window "window") without with parameter
	
	tell window "window"
		tell progress indicator "statusbar" to stop
	end tell
	repeat with current_number in order_list
		call method "setHidden:" of (image view ("img" & current_number) of window "window") without with parameter
		call method "setImageScaling:" of (image view ("img" & current_number) of window "window") with parameter 0
	end repeat
	call method "setHidden:" of (button "reveal" of window "window") without with parameter
end awake from nib

on action speedSlider
	set reveal_speed to content of slider "speedSlider" of window "preferences"
	set contents of default entry "reveal_speed" of user defaults to reveal_speed
	call method "synchronize" of object user defaults
	set real_speed to my getrealspeed(reveal_speed as integer)
end action

on changed
	my changeRevealProperties()
end changed

on end editing theObject
	set should_update to false
	
	if not numberVerify(reveal_num) then
		set reveal_num to 3
		set contents of text field "revealNum" of window "preferences" to reveal_num
		set should_update to true
	end if
	
	if not numberVerify(reveal_seconds) then
		set reveal_seconds to 5
		set contents of text field "revealSeconds" of window "preferences" to reveal_seconds
		set should_update to true
	end if
	
	if should_update then
		my changeRevealProperties()
	end if
	
end end editing

on changeRevealProperties()
	set reveal_num to contents of text field "revealNum" of window "preferences"
	set reveal_seconds to contents of text field "revealSeconds" of window "preferences"
	
	set contents of default entry "reveal_num" of user defaults to reveal_num
	set contents of default entry "reveal_seconds" of user defaults to reveal_seconds
	
	call method "synchronize" of object user defaults
end changeRevealProperties

on numberVerify(str)
	try
		str as integer
		return true
	on error
		return false
	end try
end numberVerify


on choose menu item theObject
	if name of theObject is "editImageInfo" then
		call method "setHidden:" of (button "done" of window "window") without with parameter
		call method "setHidden:" of (button "prevPage" of window "window") without with parameter
		call method "setHidden:" of (button "nextPage" of window "window") without with parameter
		my getPageNum()
		set edit_image_info to true
		my displayImages(page_start)
	end if
	
	if name of theObject is "donate" then
		tell application "System Events" to open location "https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=patrick@collinatorstudios.com&item_name=addressbook2pine&no_shipping=1&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"
	end if
	
	if name of theObject is "resetScore" then
		set snd_tink to load sound "Tink"
		play snd_tink
		set contents of default entry "score" of user defaults to "blank"
		call method "synchronize" of object user defaults
		my updateText()
	end if
	
	
	if name of theObject is "newGame" and not reveal_state then
		set interrupt to true
		my startGame()
	end if
	
	if name of theObject is "preferences" then
		my setdefaults()
		set the level of window "preferences" to 1 -- will float above all 
		set visible of window "preferences" to true
	end if
end choose menu item

on clicked theObject
	if name of theObject is "donated" then
		if (state of button "donated" of window "paypal" as boolean) then
			set contents of default entry "donation" of user defaults to "true"
		else
			set contents of default entry "donation" of user defaults to ""
		end if
		call method "synchronize" of object user defaults
	end if
	
	if name of theObject is "showComments" then
		if show_comments then
			set show_comments to false
			my imageInfo("")
		else if not show_comments then
			set show_comments to true
			if the_selection ­ missing value then my imageInfo(item (the_selection) of comment_list)
		end if
		set contents of default entry "show_comments" of user defaults to show_comments
		call method "synchronize" of object user defaults
		my setdefaults()
	end if
	
	if name of theObject is "showCommentsReveal" then
		if show_comments_reveal then
			set show_comments_reveal to false
			if reveal_state then my imageInfo("")
		else if not show_comments_reveal then
			set show_comments_reveal to true
		end if
		set contents of default entry "show_comments_reveal" of user defaults to show_comments_reveal
		call method "synchronize" of object user defaults
		my setdefaults()
	end if
	
	if name of theObject is "revealAll" then
		set reveal_mode to "all"
		set contents of default entry "reveal_mode" of user defaults to reveal_mode
		call method "synchronize" of object user defaults
		my setdefaults()
	end if
	
	if name of theObject is "revealOne" then
		set reveal_mode to "one"
		set contents of default entry "reveal_mode" of user defaults to reveal_mode
		call method "synchronize" of object user defaults
		my setdefaults()
	end if
	
	if name of theObject is "newgameButton" then
		play snd_startgame
		my startGame()
	end if
	
	if name of theObject is "quitButton" then quit
	
	if name of theObject is "reveal" and game_begin then
		tell window "window"
			set enabled of button "reveal" to false
		end tell
		set no_reveal to false
		set reveal_state to true
		if reveal_count > 0 then
			set reveal_count to reveal_count - 1
			my updateText()
			play snd_reveal
			my AlertText("Revealing all images...")
			if reveal_mode = "one" then
				set current_number to 0
				set order_list to my Rand2(order_list)
				my imageInfo("")
				repeat with current_image in image_load_list
					if interrupt then
						set interrupt to false
						exit repeat
					end if
					
					set current_number to current_number + 1
					
					if correct_list does not contain item current_number of image_list and the_selection ­ current_number and current_selection ­ current_number then
						if show_comments_reveal then my imageInfo(item (current_number) of comment_list)
						set image of image view ("img" & current_number) of window "window" to current_image
						delay real_speed
						set image of image view ("img" & current_number) of window "window" to unknown_image
					end if
				end repeat
				
			else if reveal_mode = "all" then
				set current_number to 0
				set order_list to my Rand2(order_list)
				repeat with current_number in order_list
					set image of image view ("img" & current_number) of window "window" to item current_number of image_load_list
				end repeat
				set this_count to reveal_seconds
				repeat this_count times
					if interrupt then
						set interrupt to false
						exit repeat
					end if
					my AlertText("Revealing all images..." & this_count)
					set this_count to this_count - 1
					play snd_tick
					delay 1
				end repeat
				my endReveal()
			end if
		else
			set no_reveal to true
			my AlertText("No Reveals Left!!!")
			play snd_wrong
			delay 1
			tell window "window"
				set the contents of text field "statusField" to some item of alert_items
			end tell
		end if
		if not no_reveal then
			if show_comments and the_selection = missing value or not show_comments and show_comments_reveal then
				my imageInfo("")
			else if show_comments and the_selection ­ missing value then
				my imageInfo(item (the_selection) of comment_list)
			end if
		end if
		set reveal_state to false
		tell window "window"
			set enabled of button "reveal" to true
		end tell
	end if
	
	if edit_image_info then
		if name of theObject is "done" then
			call method "setHidden:" of (button "done" of window "window") with with parameter
			call method "setHidden:" of (button "prevPage" of window "window") with with parameter
			call method "setHidden:" of (button "nextPage" of window "window") with with parameter
			my AlertText("Edit Image Tags Mode...")
			set edit_image_info to false
			my endReveal()
		end if
		if name of theObject is "nextPage" and not page_turn then
			if page_start + 20 < (count all_images) then
				set page_number to page_number + 1
				my getPageNum()
				set page_start to page_start + 20
				my displayImages(page_start)
			else
				play snd_wrong
			end if
		end if
		if name of theObject is "prevPage" and not page_turn then
			if page_start - 20 > 0 then
				set page_start to page_start - 20
				set page_number to page_number - 1
				my getPageNum()
				my displayImages(page_start)
			else
				play snd_wrong
				my getPageNum()
			end if
		end if
		
		set current_number to 0
		repeat with current_number from 1 to view_number
			if name of theObject is "button" & current_number then
				set this_file to (item (current_number + page_start - 1) of all_images)
				set comment_path to (path to me as string) & "Contents:Resources:"
				set comment_file to (comment_path & "imagecomments.txt") as file specification
				set read_comments to (read comment_file as list)
				repeat with this_comment in read_comments
					if this_file = name of this_comment then
						set file_comment to comment of this_comment
						exit repeat
					end if
				end repeat
				set the_comment to text returned of (display dialog this_file default answer file_comment)
				set open_comment to (open for access comment_file with write permission)
				set comment of this_comment to the_comment
				try
					write read_comments to open_comment as list
					close access open_comment
				on error
					close access open_comment
				end try
			end if
		end repeat
	end if
	
	if not the_state and not edit_image_info and not reveal_state then
		repeat with current_number from 1 to view_number
			if name of theObject is "button" & current_number and the_selection ­ current_number and correct_list does not contain item current_number of image_list then
				set the_state to true
				set myImageView to "img" & current_number
				set myLoadedImage to item current_number of image_load_list
				set myImage to item current_number of image_list
				set myComment to item current_number of comment_list
				if show_comments then
					tell window "window"
						set text color of text field "imageInfo" to {0, 0, 0}
					end tell
					my imageInfo(myComment)
				end if
				set image of image view myImageView of window "window" to myLoadedImage
				if the_selection = missing value then
					set the_selection to current_number
				else
					set current_selection to current_number
					if item (the_selection) of image_list = myImage then
						set correct_count to correct_count + 1
						set is_correct to true
						my updateText()
						if show_comments then
							tell window "window"
								set text color of text field "imageInfo" to {0, 32640, 65535}
							end tell
						end if
						repeat
							set correct_sound to some item of {Â
								snd_correct1, Â
								snd_correct2, Â
								snd_correct3, Â
								snd_correct4}
							if not playing of correct_sound then exit repeat
						end repeat
						play correct_sound
						
						set current_sound to correct_sound
						call method "setImageFrameStyle:" of (image view myImageView of window "window") with parameter 3
						call method "setImageFrameStyle:" of (image view ("img" & the_selection) of window "window") with parameter 3
						copy myImage to the end of correct_list
						if correct_count = 10 then
							set reveal_state to true
							set score to contents of default entry "score" of user defaults
							if score = "blank" or error_count < score then
								set contents of default entry "score" of user defaults to error_count
								call method "synchronize" of object user defaults
								my updatescore()
							end if
							my AlertText("Congratulations!  You matched all of the pairs!")
							tell window "window"
								set enabled of button "reveal" to false
							end tell
							call method "setHidden:" of (button "newgameButton" of window "window") without with parameter
							call method "setHidden:" of (button "quitButton" of window "window") without with parameter
						end if
					else
						set error_count to error_count + 1
						my updateText()
						if show_comments then
							tell window "window"
								set text color of text field "imageInfo" to {49151, 0, 0}
							end tell
						end if
						play snd_wrong
						delay 1
						set image of image view myImageView of window "window" to unknown_image
						set image of image view ("img" & the_selection) of window "window" to unknown_image
						if show_comments then my imageInfo("")
					end if
					set the_selection to missing value
					set current_selection to missing value
				end if
			end if
		end repeat
		set the_state to false
	end if
end clicked

on AlertText(myDisplay)
	tell window "window"
		set the contents of text field "statusField" to myDisplay
	end tell
end AlertText

on getPageNum()
	my AlertText("Edit Image Tags Mode...Page " & page_number & " of " & (((count all_images) / 20) as integer))
end getPageNum

on imageInfo(myDisplay)
	tell window "window"
		set the contents of text field "imageInfo" to myDisplay
	end tell
end imageInfo

on updatescore()
	set score to contents of default entry "score" of user defaults
	tell window "window"
		
		if score ­ "blank" then set the contents of text field "scoreField" to "High Score: " & score & " Incorrect Attempts"
	end tell
end updatescore

on startGame()
	my imageInfo("")
	tell window "window"
		set enabled of button "reveal" to false
	end tell
	call method "setHidden:" of (button "newgameButton" of window "window") with with parameter
	call method "setHidden:" of (button "quitButton" of window "window") with with parameter
	set game_begin to false
	set the_state to false
	set reveal_state to false
	set error_count to 0
	set correct_count to 0
	set reveal_count to reveal_num
	set current_number to 0
	set correct_list to {}
	my updateText()
	set current_number to 0
	
	set the_images to my Rand2(all_images)
	set the_images to items 1 through (view_number / 2) of the_images
	set the_images to the_images & the_images
	set the_images to my Rand2(the_images)
	set current_number to 0
	set image_load_list to {}
	set comment_list to {}
	set image_list to {}
	
	set comment_path to (path to me as string) & "Contents:Resources:"
	set file_spec to (comment_path & "imagecomments.txt") as file specification
	set read_comments to (read file_spec as list)
	set the_comments to items of read_comments
	
	play snd_startgame
	
	repeat with current_number from 1 to view_number
		tell recordSearch to seekTitle(the_comments, (item current_number of the_images))
		set theResult to result
		copy comment of theResult to the end of comment_list
		copy (load image image_path & name of theResult) to the end of image_load_list
		copy name of theResult to the end of image_list
		set image of image view ("img" & current_number) of window "window" to unknown_image
		delay 1.0E-3
		call method "setImageFrameStyle:" of (image view ("img" & current_number) of window "window") with parameter 2
	end repeat
	
	my updatescore()
	set game_begin to true
	set interrupt to false
	tell window "window"
		set enabled of button "reveal" to true
	end tell
end startGame

on updateText()
	set score to contents of default entry "score" of user defaults
	tell window "window"
		set the contents of text field "correctField" to "Correct Matches: " & correct_count
		set the contents of text field "errorField" to "Incorrect Attempts: " & error_count
		set the contents of text field "revealField" to "Reveals Left: " & reveal_count
		if score = "blank" then set the contents of text field "scoreField" to ""
		set text color of text field "imageInfo" to {0, 0, 0}
	end tell
end updateText

on displayImages(page_start)
	set current_number to 0
	set page_turn to true
	repeat with current_image from page_start to page_start + 19
		delay 1.0E-3
		set current_number to current_number + 1
		if page_start + current_number ² (count all_images) + 1 then
			
			set image of image view ("img" & current_number) of window "window" to (load image image_path & (item current_image of all_images))
		else
			delete image of image view ("img" & current_number) of window "window"
		end if
	end repeat
	set page_turn to false
end displayImages

on endReveal()
	tell window "window"
		set the contents of text field "statusField" to some item of alert_items
	end tell
	repeat with current_number in order_list
		if correct_list does not contain item current_number of image_list and the_selection ­ current_number as integer then
			set image of image view ("img" & current_number) of window "window" to unknown_image
		else
			set image of image view ("img" & current_number) of window "window" to item current_number of image_load_list
		end if
	end repeat
end endReveal

to Rand2(OL)
	-- Method for randomizing a long list that may contain duplicate entries.
	script l -- force all lists into memory for easy access
		property o : OL
		property idx : {} -- list of unique integers
		property r : o's items -- A duplicate of the original list. (No need to do a "deep" copy with 'copy'.)
	end script
	
	set c to count OL -- so as not to calculate it in every repeat
	-- make index list of unique integers.
	repeat with j from 1 to c
		set end of l's idx to j
	end repeat
	-- exchange each item in the duplicate list with another whose index is chosen at random.
	repeat with i from 1 to c
		set x to some item of l's idx
		tell item i of l's r
			set item i of l's r to item x of l's r
			set item x of l's r to it
		end tell
	end repeat
	
	return l's r
end Rand2

on setdefaults()
	if show_comments = true then
		set (state of button "showComments" of window "preferences") to true
	else if show_comments = false then
		set (state of button "showComments" of window "preferences") to false
	end if
	if show_comments_reveal = true then
		set (state of button "showCommentsReveal" of window "preferences") to true
	else if show_comments_reveal = false then
		set (state of button "showCommentsReveal" of window "preferences") to false
	end if
	if reveal_mode = "all" then
		set current row of matrix "revealRadio" of window "preferences" to 1
		set enabled of slider "speedSlider" of window "preferences" to false
		set enabled of button "showCommentsReveal" of window "preferences" to false
		set enabled of text field "revealSeconds" of window "preferences" to true
	else if reveal_mode = "one" then
		set current row of matrix "revealRadio" of window "preferences" to 2
		set enabled of slider "speedSlider" of window "preferences" to true
		set enabled of button "showCommentsReveal" of window "preferences" to true
		set enabled of text field "revealSeconds" of window "preferences" to false
	end if
	call method "setAllowsTickMarkValuesOnly:" of (slider "speedSlider" of window "preferences") with parameter 1
	set content of slider "speedSlider" of window "preferences" to reveal_speed
	set real_speed to my getrealspeed(reveal_speed as integer)
	set contents of text field "revealNum" of window "preferences" to reveal_num
end setdefaults

on getrealspeed(reveal_speed)
	if reveal_speed = 0 then return 2.5
	if reveal_speed = 10 then return 2
	if reveal_speed = 20 then return 1.5
	if reveal_speed = 30 then return 1
	if reveal_speed = 40 then return 0.8
	if reveal_speed = 50 then return 0.5
	if reveal_speed = 60 then return 0.3
	if reveal_speed = 70 then return 0.1
end getrealspeed

on idle
	if is_correct and correct_idle_count = 0 then
		my imageInfo("")
		set is_correct to false
		set correct_idle_count to 1
	else if is_correct and correct_idle_count ­ 0 then
		set correct_idle_count to correct_idle_count - 1
	end if
	if idle_count = 0 then
		set idle_count to 3
		if game_begin and not reveal_state and not edit_image_info then
			
			tell window "window"
				set the contents of text field "statusField" to some item of alert_items
			end tell
			if not the_state then
				set x to random number from 0 to 10
				if x = 5 then
					set order_list to my Rand2(order_list)
					repeat with current_number in order_list
						
						if correct_list does not contain item current_number of image_list and the_selection ­ current_number as integer then
							call method "setImageFrameStyle:" of (image view ("img" & current_number) of window "window") with parameter 4
							delay 1.0E-3
						end if
						
					end repeat
					delay 1
					repeat with current_number in order_list
						
						if correct_list does not contain item current_number of image_list and the_selection ­ current_number as integer then
							call method "setImageFrameStyle:" of (image view ("img" & current_number) of window "window") with parameter 2
							delay 1.0E-3
						end if
						
					end repeat
					
				end if
			end if
		end if
	else
		set idle_count to idle_count - 1
	end if
	return 2
	
end idle

on keyboard down theObject event theEvent
	(*Add your script here.*)
end keyboard down

on keyboard up theObject event theEvent
	(*Add your script here.*)
end keyboard up

on will close theObject
	if name of theObject = "window" then
		quit
	end if
end will close


on generateImageRecords()
	set images_path to POSIX path of (path to me as string) & "Contents/Resources/image/"
	set the_images to do shell script "ls " & images_path & "*"
	set the_images to paragraphs of result
	set the_recs to {}
	repeat with this_file in the_images
		set the_recs to the_recs & {{name:this_file, comment:"test_comment!!!"}}
	end repeat
	set comment_path to (path to me as string) & "Contents:Resources:"
	set file_spec to (comment_path & "imagecomments.txt") as file specification
	set ref_num to (open for access file_spec with write permission)
	try
		write the_recs to ref_num as list
		close access ref_num
	on error
		close access ref_num
	end try
end generateImageRecords
