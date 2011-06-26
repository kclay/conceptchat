

settings {
	displayRegisterList:true;
	font: {
		defaultFontSize:10;
	}	
}


plugins {
	load:[
		
	
	]
}

plugins:[
	autoMessagePlugin
	
]

autoMessagePlugin {
	
}
StyleManagerPlugin {
	inject: {
		setStyle:[
			"maleColor"|"0x7BA4C4",
			"femaleColor" |"0xFE0180",
			"guestColor" | "0xFF9999",
			"messageColor"| "0xFFFFFF"
		]
	}
	
}
JavascriptPlugin{
	props: {
		handlerName:chatRoom_eventHandler;	
	}

}
VideoChatPlugin {
	props: {
		videoBlockDimensions:80x60;
		maxVideoCount:6;
	}
}

