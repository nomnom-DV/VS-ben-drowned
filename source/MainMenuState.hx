package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'options', 'freeplay', 'credits'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	var options:Array<FlxSprite>;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG', 'preload'));
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		options = [];

		for (i in 0...optionShit.length)
			{
				var menuItem:FlxSprite = new FlxSprite();
				var num:Int = i + 1;
		{
				menuItem = new FlxSprite().loadGraphic(Paths.image('menu/lol' + num, 'preload'));
		}
		menuItem.setGraphicSize(Std.int(FlxG.width / FlxG.camera.zoom), Std.int(FlxG.height / FlxG.camera.zoom));
		add(menuItem);
		options.push(menuItem);
		menuItem.scrollFactor.set();
		menuItem.antialiasing = true;
		menuItem.updateHitbox();
		menuItem.screenCenter();
		
	}

		firstStart = false;

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
			{
				if (controls.UP_P)
				{
					changeItem(-1);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
				}
	
				if (controls.DOWN_P)
				{
					changeItem(1);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
				}

				if (controls.RIGHT_P)
					{
						changeItem(2);
							FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
					}
		
				if (controls.LEFT_P)
				{
					changeItem(-2);
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
				}
	
				if (controls.ACCEPT)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
	
					for (i in 0...options.length)
					{
						if (curSelected != i)
						{
							FlxTween.tween(options[i], {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									options[i].kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(options[i], 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					}
				}
			}
	
			super.update(elapsed);
		}
	
		function goToState()
		{
			var daChoice:String = optionShit[curSelected];
	
			//FlxFlicker.flicker(options[curSelected], 1.1, 0.15, false);
	
			switch (daChoice)
			{
				case 'story mode':
					PlayState.storyPlaylist = ['song-of-drowning', 'fate'];
					PlayState.isStoryMode = true;
					PlayState.storyDifficulty = 2;
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());
					PlayState.storyWeek = 0;
					PlayState.campaignScore = 0;
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState(), true);
					});
				case 'freeplay':
					FlxG.switchState(new FreeplayState());
		
					trace("Freeplay Menu Selected");
		
				case 'options':
					FlxG.switchState(new OptionsMenu());
				case 'credits':
					FlxG.switchState(new CreditsState());
			}
		}
		
			function changeItem(huh:Int = 0)
			{
				curSelected += huh;
		
				if (curSelected >= options.length)
					curSelected = 0;
				if (curSelected < 0)
					curSelected = options.length - 1;
		
		
				for (i in 0...options.length)
				{
					options[i].color = FlxColor.WHITE;
					FlxTween.tween(options[i],{alpha: 0.4});
					if (i == curSelected)
					{
						options[i].color = FlxColor.RED;
						FlxTween.tween(options[i],{alpha: 1});
					}
				}
			}
		}