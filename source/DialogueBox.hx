package;

//import js.html.FileSystemDirectoryReader;
import sys.FileSystem;
import CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var swagName:FlxText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var behindBox:FlxSprite;

	//oh god this is gonna get confusing isn't it... ugggggghhhh
	var portraitNames:Array<String>;
	var detectPixelShit:Array<Bool>;
	var displayNames:Array<String>;

	var faces:Array<FlxSprite>;
	var expressions:Array<Array<FlxSprite>>;

	var exp_index:Array<Int>;

	var portraitLayer:FlxSpriteGroup;
	var firstFadeAdd:Bool;
	var firstPicAdd:Bool;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'redheart':
				//LUNCHBOX FOR NOW, NEW BGM LATER CUZ IM LAZY
				//NEW BGM YAY
				FlxG.sound.playMusic(Paths.music('botanTime'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'baton':
				//LUNCHBOX FOR NOW, NEW BGM LATER CUZ IM LAZY
				//NEW BGM YAY
				FlxG.sound.playMusic(Paths.music('botanTime'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			
			case 'redheart':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('holostage/UI/box_appear');
				box.animation.addByPrefix('normalOpen', 'textbox appear', 24, false);
				box.animation.addByIndices('normal', 'textbox appear', [4], "", 24);
			
			case 'baton':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('holostage/UI/box_appear', 'week6');
				box.animation.addByPrefix('normalOpen', 'textbox appear', 24, false);
				box.animation.addByIndices('normal', 'textbox appear', [4], "", 24);
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		//VANILLA WEEK 6 SHIT
		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
		portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		//HAATO SHIT

		behindBox = new FlxSprite(0, 0).loadGraphic(Paths.image('holostage/UI/behindRect', 'week6'));
		behindBox.setGraphicSize(Std.int(behindBox.width * 6));
		behindBox.updateHitbox();
		behindBox.screenCenter();
		behindBox.x -= (46 * PlayState.daPixelZoom);
		behindBox.y += (8 * PlayState.daPixelZoom);
		behindBox.alpha = 0.6;
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();

		grabPortraits();

		add(box);

		box.screenCenter(X);
		if (!PlayState.curStage.startsWith('school')){
			box.y = -(26 * PlayState.daPixelZoom);
			box.x = (13 * PlayState.daPixelZoom);
			add(behindBox);
		}

		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		var curName:String = "";

		swagName = new FlxText(behindBox.x + (2 * PlayState.daPixelZoom), behindBox.y + (2 * PlayState.daPixelZoom), Std.int(FlxG.width * 0.6), curName, 32);
		swagName.font = 'Pixel Arial 11 Bold';
		swagName.color = FlxColor.BLACK;
		swagName.updateHitbox();
		swagName.x = (behindBox.x + (behindBox.width / 2)) - (swagName.width / 6);
		
		if (!PlayState.curStage.startsWith('school')){
			add(swagName);
		}

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';

		if (PlayState.curStage.startsWith('school')){
			add(dropText);
			dropText.color = 0xFFD89494;
			swagDialogue.color = 0xFF3F2021;
		} else {
			swagDialogue.color = FlxColor.WHITE;
		}

		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() != 'roses')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
						behindBox.alpha -= 1 / 5 * 0.6;

						//Fade all the faces too
						var face_i:Int = 0;
						while (face_i < faces.length)
						{
							faces[face_i].alpha -= 1 / 5;
							
							//and the expressions too
							var face_exp:Int = 0;
							while (face_exp < expressions[face_i].length)
							{
								expressions[face_i][face_exp].alpha -= 1 / 5;
								face_exp++;
							}

							face_i++;
						}

					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		
		updateChar(curCharacter, exp_index[charIndex(curCharacter)]);
		/*
		switch (curCharacter)
		{
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			default: 
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
		}
		*/
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		
		exp_index[charIndex(curCharacter)] = Std.parseInt(dialogueList[0].substr(splitName[1].length + 2).trim());

		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + 3).trim();
	}

	//New dialogue shit

	function updateChar(char:String, currentExp:Int):Void
	{
		//Reuse old code for normal week 6, then add new code for the rest of the stages
		if (PlayState.curStage.startsWith('school')){
			switch (char)
			{
				case 'bf':
					portraitLeft.visible = false;
					if (!portraitRight.visible)
					{
						portraitRight.visible = true;
						portraitRight.animation.play('enter');
					}
				default: 
					portraitRight.visible = false;
					if (!portraitLeft.visible)
					{
						portraitLeft.visible = true;
						portraitLeft.animation.play('enter');
					}
			}
		} else { //Now the rest of the stages (only holostage stages lol)
			//Check names
			var ind:Int = charIndex(char);

			//Change name and position
			swagName.text = displayNames[charIndex(curCharacter)];
			swagName.updateHitbox();
			swagName.x = (behindBox.x + (behindBox.width / 2)) - (swagName.width / 6);

			//Make every face and expression invisible except for current ones
			var face_i:Int = 0;
			while (face_i < faces.length)
			{
				if (char == portraitNames[face_i])
					faces[face_i].visible = true;
				else
					faces[face_i].visible = false;

				var face_exp:Int = 0;
				while (face_exp < expressions[face_i].length)
				{
					if (currentExp == face_exp && char == portraitNames[face_i])
						expressions[face_i][face_exp].visible = true;
					else
						expressions[face_i][face_exp].visible = false;

					face_exp++;
				}

				face_i++;
			}
		}
	}

	function grabPortraits():Void
	{
		var poop:String = FileSystem.absolutePath('assets/shared/images/portraits/');

		portraitNames = FileSystem.readDirectory(poop);
		var amount:Int = portraitNames.length;

		//oh god this is gonna get confusing isn't it... ugggggghhhh
		//var portraitNames:Array<String>;
		//var portraitPaths:Array<String>;
		//var detectPixelShit:Array<Bool>;
		//var displayNames:Array<String>;

		//Make every path and shiz

		//Initialize everything first
		displayNames = new Array<String>();
		detectPixelShit = new Array<Bool>();

		faces = new Array<FlxSprite>();
		expressions = new Array<Array<FlxSprite>>();
		exp_index = new Array<Int>();

		var i:Int = 0;
		while (i < amount)
		{
			var info:Array<String> = CoolUtil.coolTextFile(Paths.txt('portraitData/' + portraitNames[i]));

			//Fetch name
			var splitShit:Array<String> = info[0].split(":");
			displayNames[i] = splitShit[2];
			
			//Fetch pixel shit
			splitShit = info[1].split(":");
			if (splitShit[2] == 'Y')
				detectPixelShit[i] = true;
			else
				detectPixelShit[i] = false;

			faces[i] = new FlxSprite(0, 0).loadGraphic(Paths.image('portraits/' + portraitNames[i] + '/portrait'));
			
			if (detectPixelShit[i]){
				faces[i].setGraphicSize(Std.int(faces[i].width * PlayState.daPixelZoom * 0.9));
			}

			faces[i].updateHitbox();

			if (portraitNames[i].startsWith('bf'))
				faces[i].x = (box.width - behindBox.x) - (behindBox.width / 2) - (faces[i].width / 2);
			else
				faces[i].x = behindBox.x + (behindBox.width / 2) - (faces[i].width / 2);

			faces[i].y = box.y + (faces[i].height / 2) + (8 * PlayState.daPixelZoom);

			add(faces[i]);
			faces[i].visible = false;

			expressions[i] = new Array<FlxSprite>();

			var expPaths:Array<String> = FileSystem.readDirectory(FileSystem.absolutePath('assets/shared/images/portraits/' + portraitNames[i] + '/expressions'));
			
			var j:Int = 0;
			while (j < expPaths.length)
			{
				expressions[i][j] = new FlxSprite(0, 0).loadGraphic(Paths.image('portraits/' + portraitNames[i] + '/expressions/' + j));
				
				if (detectPixelShit[i])
					expressions[i][j].setGraphicSize(Std.int(expressions[i][j].width * PlayState.daPixelZoom * 0.9));

				expressions[i][j].updateHitbox();

				expressions[i][j].x = faces[i].x;
				expressions[i][j].y = faces[i].y;

				add(expressions[i][j]);
				expressions[i][j].visible = false;

				j++;
			}

			i++;
		}
	}

	function easeOut(time:Float, startPoint:Float, change:Float, duration:Float):Float
	{
		time /= duration;
		return -change * time * (time - 2) + startPoint;
	}

	function charIndex(char:String):Int
	{
		var i:Int = 0;
		while (i < portraitNames.length)
		{
			if (char == portraitNames[i])
			{
				break;
			}
			i++;
		}

		return i;
	}
}
