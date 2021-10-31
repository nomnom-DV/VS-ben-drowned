package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var fireAnim:FlxSprite = new FlxSprite(0, 0);

	var stageSuffix:String = "";
	
	public function new(x:Float, y:Float)
	{
		var whitebg:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		whitebg.scrollFactor.set();
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'stage':
				stageSuffix = '-default';
				daBf = 'bf';
			case 'forest':
				stageSuffix = '-default';
				daBf = 'bf-dark';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;
		
		if (daStage == 'stage')
		{
			add(whitebg);
		}
		
		bf = new Boyfriend(x, y, daBf);
		add(bf);
		camFollow = new FlxObject(bf.getMidpoint().x - 200 ,bf.getMidpoint().y - 100, 1, 1);
		add(camFollow);
		FlxG.sound.play(Paths.sound('Ben_Game_Over_Death_Sfx', 'preload'));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		new FlxTimer().start(1.3, function(tmr:FlxTimer)
			{
				bf.playAnim('firstDeath');
				fireAnim.frames = Paths.getSparrowAtlas('fire', 'drowned');
				fireAnim.animation.addByPrefix('fire','fire',24, true);
				fireAnim.screenCenter();			
				fireAnim.scale.set(9,9);
				fireAnim.alpha = 0;
				fireAnim.y -= 300;
				add(fireAnim);
				FlxTween.tween(fireAnim,{alpha: 0.7});
				fireAnim.animation.play('fire');
			});
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('Ben_Game_Over_Music', 'preload'));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			FlxTween.tween(fireAnim,{alpha: 0});
			new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					remove(fireAnim);
				});
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}