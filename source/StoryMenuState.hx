package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	static function weekData():Array<Dynamic>
	{
		return [
			['bopeebo']
		];
	}
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true];

	var weekCharacters:Array<Dynamic> = [
		['', 'bf', 'gf']
	];

	var weekNames:Array<String> = [
		""
	];


	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var curdiff:Int = 2;

    var oneclick:Bool = true;


	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	function unlockWeeks():Array<Bool>
		{
			var weeks:Array<Bool> = [];
			#if debug
			for(i in 0...weekNames.length)
				weeks.push(true);
			return weeks;
			#end
			
			weeks.push(true);
	
			for(i in 0...FlxG.save.data.weekUnlocked)
				{
					weeks.push(true);
				}
			return weeks;
		}


	override function create()
	{	
		weekUnlocked = unlockWeeks();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;


        FlxG.sound.playMusic(Paths.music('TV Static 10 Minutes'));
        
        var bg:FlxSprite;
		
		bg = new FlxSprite(0, 0);
		bg.frames = Paths.getSparrowAtlas('story/StoryMenuGlitch', 'drowned');
		bg.animation.addByPrefix('glitch', "glitchy", 24);
		bg.scrollFactor.set(0.8, 0.9);
		bg.scale.set(6, 6);
		bg.animation.play('glitch');
		add(bg);

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

	for (i in 0...weekData().length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			if(FlxG.save.data.antialiasing)
				{
					weekThing.antialiasing = true;
				}
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				trace('locking week ' + i);
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				if(FlxG.save.data.antialiasing)
					{
						lock.antialiasing = true;
					}
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		//grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		//grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		//grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		sprDifficulty = new FlxSprite(550, 600);
        sprDifficulty.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('normal');
        add(sprDifficulty);

        leftArrow = new FlxSprite(sprDifficulty.x - 130, sprDifficulty.y);
        leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        leftArrow.setGraphicSize(Std.int(leftArrow.width * 0.8));
        leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
        add(leftArrow);

        rightArrow = new FlxSprite(sprDifficulty.x + 230, sprDifficulty.y);
        rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
        rightArrow.setGraphicSize(Std.int(rightArrow.width * 0.8));
        rightArrow.animation.addByPrefix('idle', "arrow right");
		rightArrow.animation.addByPrefix('press', "arrow push right");
		rightArrow.animation.play('idle');
        add(rightArrow);

        sprDifficulty.offset.x = 70;
        sprDifficulty.y = leftArrow.y + 10;

        super.create();
    }

    function changediff(diff:Int = 1)
		{
			curdiff += diff;
	
			if (curdiff == 0) curdiff = 3;
			if (curdiff == 4) curdiff = 1;
			
			FlxG.sound.play(Paths.sound('scrollMenu'));
	
			switch (curdiff)
			{
				case 1:
					sprDifficulty.animation.play('easy');
					sprDifficulty.offset.x = 20;
				case 2:
					sprDifficulty.animation.play('normal');
					sprDifficulty.offset.x = 50;
				case 3:
					sprDifficulty.animation.play('hard');
					sprDifficulty.offset.x = 20;
			}
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;    
			FlxTween.tween(sprDifficulty, {y: leftArrow.y + 10, alpha: 1}, 0.07);
		}
	
		override public function update(elapsed:Float)
		{
			if (controls.LEFT) leftArrow.animation.play('press');
			else leftArrow.animation.play('idle'); 
	
			if (controls.LEFT_P) changediff(-1);
	
			if (controls.RIGHT) rightArrow.animation.play('press');
			else rightArrow.animation.play('idle'); 
	
			if (controls.RIGHT_P) changediff(1);
	
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new MainMenuState());
			}
	
			if (controls.ACCEPT)
			{
				if (oneclick)
				{
	
					oneclick = false;
					var curDifficulty = '';
	
					FlxG.sound.play(Paths.sound('confirmMenu'));
					PlayState.storyPlaylist = ['song-of-drowning', 'fate'];
					PlayState.isStoryMode = true;
					switch(curdiff)
					{
						case 1:
							curDifficulty = '-hard';
						case 1:
							curDifficulty = '-hard';
						case 3:
							curDifficulty = '-hard';
					}
	
					curdiff -= 1;
					PlayState.storyDifficulty = curdiff;
	
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + curDifficulty, PlayState.storyPlaylist[0].toLowerCase());
					PlayState.storyWeek = 1;
					PlayState.campaignScore = 0;
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState(), true); //save this code for the cutsceneless build of the game
					//	var video:MP4Handler = new MP4Handler();
					//	video.playMP4(Paths.video('tooslowcutscene1'), new PlayState()); 
					});
					
				}
	
			super.update(elapsed);
		}
	}
}
	