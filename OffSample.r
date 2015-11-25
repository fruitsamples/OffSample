/*------------------------------------------------------------------------------##	Apple Macintosh Developer Technical Support##	Offscreen Buffer Sample Application##	OffSample##	OffSample.r		-	Rez Source##	Copyright � 1989 Apple Computer, Inc.#	All rights reserved.##	Versions:	#				1.00				04/89#				1.01				06/92##	Components:#				OffSample.p			April 1, 1989#				OffSample.r			April 1, 1989#				OffSample.h			April 1, 1989#				OffSample.rsrc		April 1, 1989#				POffSample.make		April 1, 1989##	Requirements:#				Offscreen.p			April 1, 1989#				Offscreen.inc1.p	April 1, 1989#				UFailure.p			November 1, 1988#				UFailure.inc1.p		November 1, 1988#				UFailure.a			November 1, 1988##	OffSample demonstrates the usage of the Offscreen#	unit. It shows how to use offscreen pixmaps and#	bitmaps to produce flicker-free updating with a#	minimum of re-structuring of code. OffSample attempts#	to reduce the amount of 'knowledge' that it has of#	the offscreen structure so as to minimize its#	dependence on that unit.##	OffSample emphasizes using the Offscreen unit; it#	is not intended to be viewed as a complete application#	from which to base some larger effort. Instead, its#	method of using offscreen bitmaps and pixmaps should#	be studied and adapted to other applications that#	desire features such as flicker-free updating.#------------------------------------------------------------------------------*/#include "Types.r"#include "OffSample.h"include "OffSample.rsrc";/* we use an MBAR resource to conveniently load all the menus */resource 'MBAR' (rMenuBar, preload) {	{ mApple, mFile, mEdit, mShape, mSpecial };	/* five menus */};resource 'MENU' (mApple, preload) {	mApple, textMenuProc,	AllItems & ~MenuItem2,	/* Disable dashed line, enable About and DAs */	enabled, apple,	{		"About OffSample�",			noicon, nokey, nomark, plain;		"-",			noicon, nokey, nomark, plain	}};resource 'MENU' (mFile, preload) {	mFile, textMenuProc,	MenuItem1 | MenuItem12,				/* enable New and Quit only, program enables others */	enabled, "File",	{		"New",			noicon, "N", nomark, plain;		"Open",			noicon, "O", nomark, plain;		"-",			noicon, nokey, nomark, plain;		"Close",			noicon, "W", nomark, plain;		"Save",			noicon, "S", nomark, plain;		"Save As�",			noicon, nokey, nomark, plain;		"Revert",			noicon, nokey, nomark, plain;		"-",			noicon, nokey, nomark, plain;		"Page Setup�",			noicon, nokey, nomark, plain;		"Print�",			noicon, nokey, nomark, plain;		"-",			noicon, nokey, nomark, plain;		"Quit",			noicon, "Q", nomark, plain	}};resource 'MENU' (mEdit, preload) {	mEdit, textMenuProc,	NoItems,				/* disable everything, program does the enabling */	enabled, "Edit",	 {		"Undo",			noicon, "Z", nomark, plain;		"-",			noicon, nokey, nomark, plain;		"Cut",			noicon, "X", nomark, plain;		"Copy",			noicon, "C", nomark, plain;		"Paste",			noicon, "V", nomark, plain;		"Clear",			noicon, nokey, nomark, plain	}};resource 'MENU' (mShape, preload) {	mShape, textMenuProc,	AllItems,				/* Enable all */	enabled, "Shapes",	{		"Oval",			noicon, nokey, check, plain;		"Region",			noicon, nokey, nomark, plain;		"RoundRect",			noicon, nokey, nomark, plain;		"Polygon",			noicon, nokey, nomark, plain;		"Rect",			noicon, nokey, nomark, plain;		"Moof!�",			noicon, nokey, nomark, plain;		"Gigantor",			noicon, nokey, nomark, plain	}};resource 'MENU' (mSpecial, preload) {	mSpecial, textMenuProc,	AllItems & ~MenuItem3,	/* Disable dashed line */	enabled, "Special",	{		"Attempt Background Buffer",			noicon, nokey, check, plain;		"Attempt Foreground Buffer",			noicon, nokey, check, plain;		"-",			noicon, nokey, nomark, plain;		"Pick Object Color�",			noicon, nokey, nomark, plain	}};/* this ALRT and DITL are used as an About screen */resource 'ALRT' (rAboutAlert, purgeable) {	{40, 20, 160, 290},	rAboutAlert,	{ /* array: 4 elements */		/* [1] */		OK, visible, silent,		/* [2] */		OK, visible, silent,		/* [3] */		OK, visible, silent,		/* [4] */		OK, visible, silent	}};resource 'DITL' (rAboutAlert, purgeable) {	{ /* array DITLarray: 5 elements */		/* [1] */		{88, 180, 108, 260},		Button {			enabled,			"OK"		},		/* [2] */		{8, 8, 24, 214},		StaticText {			disabled,			"Offscreen Sample"		},		/* [3] */		{32, 8, 48, 237},		StaticText {			disabled,			"Copyright � 1989 Apple Computer"		},		/* [4] */		{56, 8, 72, 136},		StaticText {			disabled,			"Brought to you by:"		},		/* [5] */		{80, 24, 112, 167},		StaticText {			disabled,			"Macintosh Developer �Technical Support"		}	}};/* this ALRT and DITL are used as an error screen */resource 'ALRT' (rUserAlert, purgeable) {	{40, 20, 180, 260},	rUserAlert,	{ /* array: 4 elements */		/* [1] */		OK, visible, silent,		/* [2] */		OK, visible, silent,		/* [3] */		OK, visible, silent,		/* [4] */		OK, visible, silent	}};resource 'DITL' (rUserAlert, purgeable) {	{ /* array DITLarray: 4 elements */		/* [1] */		{110, 150, 130, 230},		Button {			enabled,			"OK"		},		/* [2] */		{10, 60, 60, 230},		StaticText {			disabled,			"OffSample error. ^0."		},		/* [3] */		{70, 60, 90, 230},		StaticText {			disabled,			"^1"		},		/* [4] */		{8, 8, 40, 40},		Icon {			disabled,			2		}	}};resource 'STR#' (sErrStrings, purgeable) {	{	"An error occurred. The error number is: ";	"You must run on 512Ke or later";	"Application Memory Size is too small";	"Not enough memory to run OffSample";	}};resource 'STR ' (kNoBackBuff, purgeable) {	" / BackDealloc"};resource 'STR ' (kNoEditBuff, purgeable) {	" / EditDeAlloc"};resource 'STR ' (kTitle, purgeable) {	"Offscreen"};resource 'STR ' (kColorPrompt, purgeable) {	"Select shape color."};resource 'STR ' (kNoWantBack, purgeable) {	" / BackDenied"};resource 'STR ' (kNoWantEdit, purgeable) {	" / EditDenied"};resource 'WIND' (rWindow, preload, purgeable) {	{60, 40, 290, 360},	noGrowDocProc, visible, goAway, 0x0, " "};resource 'pltt' (rWindow) {	{		0x0, 0x0, 0x0, pmTolerant, 0x0000,				/* Black */		0xFFFF, 0xFFFF, 0xFFFF, pmTolerant, 0x0000,		/* White */		0xFFFF, 0x0, 0x0, pmTolerant, 0x0000,			/* Oval's starting color	*/		0x0, 0x0, 0xFFFF, pmTolerant, 0x0000,			/* Rgn's	"		"		*/		0x9999, 0x6666, 0x0, pmTolerant, 0x0000,		/* RRect's	"		"		*/		0x6666, 0x0, 0x9999, pmTolerant, 0x0000,		/* Poly's	"		"		*/		0xCCCC, 0xCCCC, 0xCCCC, pmTolerant, 0x0000,		/* Rect's	"		"		*/	}};/* here is the quintessential MultiFinder friendliness device, the SIZE resource */resource 'SIZE' (-1) {	dontSaveScreen,	acceptSuspendResumeEvents,	enableOptionSwitch,	canBackground,				/* we can background; we don't currently, but our */								/* sleep value guarantees we don't hog the Mac while */								/* we are in the background */	multiFinderAware,			/* this says we do our own activate/deactivate; don't */								/* fake us out */	backgroundAndForeground,	/* this is definitely not a background-only */								/* application! */	dontGetFrontClicks,			/* change this is if you want "do first click" */								/* behavior like the Finder */	ignoreChildDiedEvents,	is32BitCompatible,	reserved,	reserved,	reserved,	reserved,	reserved,	reserved,	reserved,	kPrefSize * 1024,	kMinSize * 1024	};