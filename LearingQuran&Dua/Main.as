package {

	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import caurina.transitions.Tweener;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.TransformGestureEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getDefinitionByName;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.ui.Mouse;
	import flash.net.SharedObject;
	import flash.sensors.Accelerometer;
	import flash.events.AccelerometerEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.net.Responder;



	public class Main extends MovieClip {
	
		// Delcare varible for server connection

		private var gw_url: String = 'http://localhost/Amfphp/';
		private var gw: NetConnection;
		private var responderInsert: Responder;
		private var responderDisplay: Responder;
		
		// Declare variable 
		private var menu_mc: MovieClip;
		private var quran_mc:MovieClip;
		private var game_mc: MovieClip;
		private var gameover_mc: MovieClip;
		private var playQuranSound: Sound;
		private var sndChannel: SoundChannel;
		private var bgSndChannel: SoundChannel;
		private var bgSound: Sound;
		private var tempSound:Boolean;
		private var correctSound: Sound;
		private var errorSound: Sound;
		private var bag: MovieClip;
		private var selected_bag: int;
		private var theBag: MovieClip;
		private var timer: Timer;
		private var creationDelay: int = 3000;
		private var suras: Array = [];
		private var accelerometer: Accelerometer;
		private var xSpeed: Number = 0;
		private var ySpeed: Number = 0;
		private var sura_speed: Number;
		private var soundNum: Number;
		private var score: int;
		private var lives: int;
		private var whichLevel: int;
		private var highestScore: int;
		private var sObj: SharedObject;

		public function Main() {

			stage.scaleMode = StageScaleMode.EXACT_FIT; // for fitting with device screen size
			Multitouch.inputMode = MultitouchInputMode.GESTURE; // for gesture event 
            
			// creating server connection 
			gw = new NetConnection();
			gw.connect(gw_url);
			gw.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			
			// Store highscore in a file in the device parmanent storage 
			sObj = SharedObject.getLocal("Dua");
			if (sObj.data['highestScore'] != undefined) {
				highestScore = sObj.data['highestScore'];
			} else {
				sObj.data['highestScore'] = 0;
				sObj.flush(0);
			}

			// create and add menu option 
			
			menu_mc = new Menu_mc();
			this.addChild(menu_mc);
			menu_mc.Ins_mc.visible = false;
			menu_mc.Audio_mc.visible = false;
			menu_mc.level_mc.visible = false;
			menu_mc.BagSelector.visible = false;
			menu_mc.BgSound_mc.visible = false;
			menu_mc.BgSound_mc.offBtn.visible = false;
			menu_mc.Dua_mc.visible = false;
			
			// create and add suras in the quran 
			quran_mc = new Quran_mc();
			this.addChild(quran_mc);
			quran_mc.visible = false;
			
			// create and add GameOver option 

			gameover_mc = new GameOver_mc();
			this.addChild(gameover_mc);
			gameover_mc.visible = false;

			// create timer 
			timer = new Timer(creationDelay);
			timer.addEventListener(TimerEvent.TIMER, createNewSura);


			// Mouse events 
			menu_mc.BgSound_mc.onBtn.addEventListener(MouseEvent.CLICK, onClickBgSound);
			menu_mc.BgSound_mc.offBtn.addEventListener(MouseEvent.CLICK, offPlayBgSound);
			menu_mc.HowPlay.addEventListener(MouseEvent.CLICK, showInstruction);
			menu_mc.sndBtn.addEventListener(MouseEvent.CLICK, showBgSoundOption);
			menu_mc.Ins_mc.OkBtn.addEventListener(MouseEvent.CLICK, hideInstruction);
			menu_mc.Audio_mc.PlayAudio.addEventListener(MouseEvent.CLICK, selectedAudio);
			menu_mc.Audio_mc.backBtn.addEventListener(MouseEvent.CLICK, hideAudioOption);
			menu_mc.BagSelector.BackBtn.addEventListener(MouseEvent.CLICK, hideSelectOption);
			menu_mc.PlayBtn.addEventListener(MouseEvent.CLICK, levelOption);
			menu_mc.BagSelector.Bag_1_mc.addEventListener(MouseEvent.CLICK, BagSelected);
			menu_mc.BagSelector.Bag_2_mc.addEventListener(MouseEvent.CLICK, BagSelected);
			menu_mc.BagSelector.Bag_3_mc.addEventListener(MouseEvent.CLICK, BagSelected);
			menu_mc.level_mc.backBtn.addEventListener(MouseEvent.CLICK, hideLevelOption);
			menu_mc.level_mc.level1.addEventListener(MouseEvent.CLICK, levelSelected);
			menu_mc.level_mc.level2.addEventListener(MouseEvent.CLICK, levelSelected);
			menu_mc.level_mc.level3.addEventListener(MouseEvent.CLICK, levelSelected);
			menu_mc.DuaBtn.addEventListener(MouseEvent.CLICK, showDuaOPtion);
			menu_mc.QuranBtn.addEventListener(MouseEvent.CLICK,showQuran);
			quran_mc.BackBtn.addEventListener(MouseEvent.CLICK,hideQuran);
			quran_mc.FatihahBtn.addEventListener(MouseEvent.CLICK,displaySuraFatihah);
			quran_mc.NusBtn.addEventListener(MouseEvent.CLICK,displaySuraNus);
			quran_mc.FalaqBtn.addEventListener(MouseEvent.CLICK,displaySuraFalaq);
			quran_mc.IkhlasBtn.addEventListener(MouseEvent.CLICK,displaySuraIkhlas);
			quran_mc.MasadBtn.addEventListener(MouseEvent.CLICK,displaySuraMasad);
			quran_mc.Fatihah_mc.BackOption.addEventListener(MouseEvent.CLICK,goSuraOption);
			quran_mc.Nus_mc.BackOption.addEventListener(MouseEvent.CLICK,goSuraOption);
			quran_mc.Falaq_mc.BackOption.addEventListener(MouseEvent.CLICK,goSuraOption);
			quran_mc.Ikhlas_mc.BackOption.addEventListener(MouseEvent.CLICK,goSuraOption);
			quran_mc.Masad_mc.BackOption.addEventListener(MouseEvent.CLICK,goSuraOption);
			menu_mc.Dua_mc.okBtn.addEventListener(MouseEvent.CLICK, hideDuaOPtion);
			gameover_mc.RePlayBtn.addEventListener(MouseEvent.CLICK, replayTheGame);
			gameover_mc.MenuBtn.addEventListener(MouseEvent.CLICK, openMenuOption);
		}

		// function for various level 
		private function levelSelected(e: MouseEvent): void {

			var levelName: String = e.currentTarget.name;
			whichLevel = parseInt(levelName.charAt(5));
			trace(whichLevel);

			if (whichLevel == 1) {
				sura_speed = 3;
				timer = new Timer(creationDelay);
				timer.addEventListener(TimerEvent.TIMER, createNewSura);
			} else if (whichLevel == 2) {
				sura_speed = 3 * 2;
				timer = new Timer(creationDelay / 2);
				timer.addEventListener(TimerEvent.TIMER, createNewSura);
			} else if (whichLevel == 3) {
				sura_speed = 3 * 3;
				timer = new Timer(creationDelay / 3);
				timer.addEventListener(TimerEvent.TIMER, createNewSura);
			}
			menu_mc.level_mc.visible = false;
			menu_mc.BagSelector.visible = true;
		}
		
		// check server hitting in right location or not 
		private function onNetStatus(e: NetStatusEvent): void {
			trace(e);

		}
		
		// add score into database 
		private function insertScore(): void {
			var addScore: Array;
			responderInsert = new Responder(onDataLoad_Sucess, onDataLoad_fail);
			addScore = [score];
			gw.call('GameService.generateHighscore', responderInsert, addScore);


		}
		
		// display score from database 
		private function displayScore(): void {
			responderDisplay = new Responder(onDataDisplay_Sucess, onDataLoad_fail);
			gw.call('GameService.showHighscore', responderDisplay);
		}
		
		// responder handling function 
		private function onDataLoad_Sucess(e: Object): void {
			if (e == false) {
				trace("handling...Error!");
			} else {
				trace("Score: " + e);
			}
		}

		// responder handling function 
		private function onDataDisplay_Sucess(e: Object): void {
			if (e == false) {
				trace("diplaying...Error!");
			} else {
				
				gameover_mc.HighScoreTxt.text = e[0]["maximum"];
			}
		}
		
		// responder handling function 
		private function onDataLoad_fail(e: Object): void {
			trace("Error!");
		}
		
		
		private function playSound(): void {

			menu_mc.BagSelector.visible = false;
			menu_mc.Audio_mc.visible = true;

		}
		
		// replay the game function 

		private function replayTheGame(e: MouseEvent): void {
			gameover_mc.visible = false;
			
			menu_mc.visible = true;
		
			playSound();

			var nameSuras: int = suras.length;
			for (var i: int = 0; i < nameSuras; i++) {
				var sura: MovieClip = suras[0] as MovieClip;
				game_mc.removeChild(sura);
				suras.splice(0, 1);
			}


		}
		
		
		// option to select level to users
		private function levelOption(e: MouseEvent) {

			menu_mc.level_mc.visible = true;

		}
		
		// play audio to play a random audio 
		private function selectedAudio(e: MouseEvent) {

			menu_mc.visible = false;

			game_mc = new Game_mc();
			this.addChild(game_mc);
			if (bgSndChannel) {
				bgSndChannel.stop();
			}



			soundNum = 1 + Math.floor(Math.random() * 27);
			trace(soundNum);
			var sndclass: Class = getDefinitionByName("snd" + soundNum) as Class;
			playQuranSound = new sndclass();
			sndChannel = playQuranSound.play();
			// Sound class can't dispatch Sound. That's why used soundChannel class 
			sndChannel.addEventListener(Event.SOUND_COMPLETE, startGame);

		}
		
		
		// Game starting function 
		private function startGame(e: Event): void {
			game_mc.swipeTxt.visible = false;
			lives = 3;
			score = 0;
			suras = [];
			timer.start();

			bag = new Bag();
			this.addChild(bag);
			bag.scaleX = bag.scaleY = 0.7;
			bag.x = stage.stageWidth / 2;
			bag.y = stage.stageHeight - 80;

			stage.addEventListener(Event.ENTER_FRAME, efh);
			bag.b1.visible = bag.b2.visible = bag.b3.visible = false;
			bag['b' + selected_bag].visible = true;
			theBag = bag['b' + selected_bag];
			
			
			
			// adding Accelerometer event 
			if (Accelerometer.isSupported) {
				accelerometer = new Accelerometer();
				accelerometer.addEventListener(AccelerometerEvent.UPDATE, accUpdateHandler);
				stage.addEventListener(Event.ENTER_FRAME, acc_efh);
			}

		}
		
		
		// function for  Accelerometer event holding device rotation in each frame 
		private function acc_efh(e: Event): void {
			e.stopPropagation();
			var bagx: Number = theBag.x + xSpeed;

			//trace(stage.stageWidth);
			if (bagx < -390) {
				trace(bagx);
				theBag.x = -390;
				xSpeed = 0;
			} else if (bagx > stage.stageWidth - 480) {
				trace(bagx);
				theBag.x = stage.stageWidth - 480;
				xSpeed = 0;
			} else {
				theBag.x += xSpeed;
			}

		}



		private final function accUpdateHandler(e: AccelerometerEvent): void {
			xSpeed -= e.accelerationX * 5;
		}
		
		// Gesture event which is optional in the game 
		/* private function onSwipe(e:TransformGestureEvent):void{
			trace(e);
		   
		   
			   if(e.offsetX == 1){
				//left to right
		
					theBag.x+=100;
				
				if(theBag.x>75){
					theBag.x = 180;
					}
				
			}else if(e.offsetX == -1){
				//right to left
				
				  theBag.x-=100;
				if(theBag.x <-395){
					 theBag.x = -395;
					}
			
				 
			}else if(e.offsetY == 1){
				//top to bottom
			}else if(e.offsetY == -1){
				//bottom to top
			}
		  
		   
			
		}
		*/
		
		
		// crate new suras randomly based on creation time 

		private function createNewSura(e: TimerEvent): void {
			trace("find the method");
			var sura: MovieClip;

			/*for(var i:int=0;i<suras.length;i++){
			   
			   sura = new SuraName();
			   sura.SuraNameTxt.text = suras[i] as String;
			   game_mc.addChild(sura);
			   sura.speedY = sura_speed;
			   
			   sura.x = 42+Math.random()*396;
			   sura.y =-100;
			   
			   store_suras.push(sura);
			   trace("bd");
			   }*/


			if (Math.random() < 0.2) {
				sura = new Fatihah();
				game_mc.addChild(sura);
				sura.name = "fatihah";

			} else if (Math.random() >= 0.2 && Math.random() < 0.4) {
				sura = new Nus();
				game_mc.addChild(sura);
				sura.name = "nus";

			} else if (Math.random() >= 0.4 && Math.random() < 0.6) {
				sura = new Falaq();
				game_mc.addChild(sura);
				sura.name = "falaq";

			} else if (Math.random() >= 0.6 && Math.random() < 0.8) {
				sura = new Ikhlas();
				game_mc.addChild(sura);
				sura.name = "ikhlas";
			} else {
				sura = new Masad();
				game_mc.addChild(sura);
				sura.name = "masad";
			}

			sura.speedY = sura_speed;
			sura.x = 42 + Math.random() * 396;
			sura.y = -100;
			suras.push(sura);

			trace(suras);

		}
		// function to work with keybaord 
		private function keyRightHandler(e: KeyboardEvent): void {
			if (e.keyCode == Keyboard.LEFT) {
				theBag.x = theBag.x - 100;
				if (theBag.x < -400) {
					theBag.x = -400;
				}
			}

			if (e.keyCode == Keyboard.RIGHT) {
				theBag.x = theBag.x + 100;
				trace(theBag.x);
				if (theBag.x > 180) {
					theBag.x = 180;
				}
			}
		}
		
		
		// function to handle event in each frame and show score and highscore 
		private function efh(e: Event): void {
			suras.y = suras.y + sura_speed;
			game_mc.GameBg.y -= sura_speed;
			if (game_mc.GameBg.y < -1136) {
				game_mc.GameBg.y = 0;
			}

			//stage.addEventListener(TransformGestureEvent.GESTURE_SWIPE,onSwipe);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyRightHandler);

			if (score < 0 || lives == 0) {
				score = score * whichLevel;
				if (highestScore < score) {
					sObj.data['highestScore'] = score;
					sObj.flush(0);
				}

				stage.removeEventListener(Event.ENTER_FRAME, acc_efh);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyRightHandler);
				stage.removeEventListener(Event.ENTER_FRAME, efh);
				bag.b1.visible = bag.b2.visible = bag.b3.visible = false;
				game_mc.visible = false;
				gameover_mc.visible = true;

				if (score < 0) {
					score = 0;
				}
				
				insertScore();
				gameover_mc.FinalScoretxt.text = score.toString();
				displayScore();
				gameover_mc.HighScoreTxt.text = sObj.data['highestScore'];
				if(tempSound){
					playBgSound();
				
					}
				timer.stop();
				return;

			}


			for (var i: int = 0; i < suras.length; i++) {
				var sura: MovieClip = suras[i] as MovieClip;
				trace("Sura name: " + sura.name);
				sura.y += sura_speed;
				trace("whichlevel: " + whichLevel);
				//score = score*whichLevel;
				game_mc.ScoreTxt.text = 'Score: ' + score;
				game_mc.livesTxt.text = 'Lives: ' + lives;

				if (soundNum >= 1 && soundNum <= 7) {

					if ((sura.hitTestObject(theBag)) && (sura.name == "fatihah")) {
						score += 500;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						onCorrectSound();

					}

					if ((sura.hitTestObject(theBag)) && !(sura.name == "fatihah")) {
						score -= 200;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();
					}
					if ((sura.y > 1136) && (sura.name == "fatihah")) {
						score -= 300;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();

					}

				}

				if (soundNum >= 8 && soundNum <= 13) {

					if ((sura.hitTestObject(theBag)) && (sura.name == "nus")) {
						score += 500;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						onCorrectSound();

					}

					if ((sura.hitTestObject(theBag)) && !(sura.name == "nus")) {
						score -= 200;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();
					}
					if ((sura.y > 1136) && (sura.name == "nus")) {
						score -= 300;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();

					}

				}

				if (soundNum >= 14 && soundNum <= 18) {

					if ((sura.hitTestObject(theBag)) && (sura.name == "falaq")) {
						score += 500;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						onCorrectSound();
					}

					if ((sura.hitTestObject(theBag)) && !(sura.name == "falaq")) {
						score -= 200;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();
					}
					if ((sura.y > 1136) && (sura.name == "falaq")) {
						score -= 300
						sura.parent.removeChild(sura);
						suras.splice(i, 1);

						i--;
						lives--;
						onErrorSound();

					}

				}
				if (soundNum >= 19 && soundNum <= 22) {

					if ((sura.hitTestObject(theBag)) && (sura.name == "ikhlas")) {
						score += 500;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						onCorrectSound();
					}

					if ((sura.hitTestObject(theBag)) && !(sura.name == "ikhlas")) {
						score -= 200;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();

					}
					if ((sura.y > 1136) && (sura.name == "ikhlas")) {
						score -= 300;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();

					}

				}

				if (soundNum >= 23 && soundNum <= 27) {

					if ((sura.hitTestObject(theBag)) && (sura.name == "masad")) {
						score += 500;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						onCorrectSound();
					}

					if ((sura.hitTestObject(theBag)) && !(sura.name == "masad")) {
						score -= 200;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();

					}
					if ((sura.y > 1136) && (sura.name == "masad")) {
						score -= 300;
						sura.parent.removeChild(sura);
						suras.splice(i, 1);
						i--;
						lives--;
						onErrorSound();


					}

				}



			}

		}



		// function for show and hide instruction menu 

		private function showInstruction(e: MouseEvent): void {

			menu_mc.Ins_mc.visible = true;
		}


		private function hideSelectOption(e: MouseEvent): void {
			menu_mc.BagSelector.visible = false;

		}
		private function hideInstruction(e: MouseEvent): void {
			menu_mc.Ins_mc.visible = false;

		}



		// function for tween bag when selected 
		private function BagSelected(e: MouseEvent): void {
			var BagName: String = e.currentTarget.name;
			var whichBag: int = parseInt(BagName.charAt(4));
			selected_bag = whichBag;
			var selectedBag: MovieClip = e.currentTarget as MovieClip;
			var currentRotation: int = selectedBag.rotation;
			Tweener.addTween(selectedBag, {
				rotation: currentRotation + 20,
				time: 0.5
			});
			Tweener.addTween(selectedBag, {
				rotation: currentRotation,
				time: 0.5,
				delay: 0.6,
				onComplete: playSound
			});
		}
		
		
		// functions for visible and invisible different options/symbols 
		private function openMenuOption(e: MouseEvent) {

			gameover_mc.visible = false;
			menu_mc.visible = true;
			menu_mc.Ins_mc.visible = false;
			menu_mc.Audio_mc.visible = false;
			menu_mc.level_mc.visible = false;
			menu_mc.BagSelector.visible = false;
		}
		private function hideAudioOption(e: MouseEvent) {

			menu_mc.Audio_mc.visible = false;

		}
		private function hideLevelOption(e: MouseEvent) {

			menu_mc.level_mc.visible = false;

		}

		private function showBgSoundOption(e: MouseEvent) {

			menu_mc.BgSound_mc.visible = true;

		}

		private function hideDuaOPtion(e: MouseEvent) {

			menu_mc.Dua_mc.visible = false;

		}

		private function showDuaOPtion(e: MouseEvent) {

			menu_mc.Dua_mc.visible = true;

		}

		private function showQuran(e: MouseEvent) {
			menu_mc.visible = false;
			quran_mc.Fatihah_mc.visible = false;
			quran_mc.Falaq_mc.visible = false;
			quran_mc.Nus_mc.visible = false;
			quran_mc.Ikhlas_mc.visible = false;
			quran_mc.Masad_mc.visible = false;
			quran_mc.visible = true;
			

		}
	      private function hideQuran(e: MouseEvent) {

			quran_mc.visible = false;
		    menu_mc.visible = true;

		}
		 private function displaySuraFatihah(e: MouseEvent) {

			quran_mc.Fatihah_mc.visible = true;
		}
		
		 private function displaySuraFalaq(e: MouseEvent) {

			quran_mc.Falaq_mc.visible = true;
		}
		 private function displaySuraNus(e: MouseEvent) {

			quran_mc.Nus_mc.visible = true;
		}
		 private function displaySuraIkhlas(e: MouseEvent) {

			quran_mc.Ikhlas_mc.visible = true;
		}
		private function displaySuraMasad(e: MouseEvent) {

			quran_mc.Masad_mc.visible = true;
		}
		private function goSuraOption(e: MouseEvent) {

			quran_mc.Fatihah_mc.visible = false;
			quran_mc.Nus_mc.visible = false;
			quran_mc.Falaq_mc.visible = false;
			quran_mc.Ikhlas_mc.visible = false;
			quran_mc.Masad_mc.visible = false;
		    quran_mc.visible = true;
			menu_mc.visible = false;


		}
		
		// funtion for playing sound when player can collect right suras 
		private function onCorrectSound(): void {
			correctSound = new Alhamdolila();
			correctSound.play();

		}
		
		// funtion for playing sound when player can collect wrong suras 
		private function onErrorSound(): void {
			errorSound = new ErrorSnd();
			errorSound.play();

		}
		
		// function for background sound to play 
		private function playBgSound(): void {
			bgSound = new rahamanSound();
			bgSndChannel = new SoundChannel();
			var bgSndTransform = new SoundTransform();
			bgSndChannel = bgSound.play();
			bgSndTransform.volume = 0.5;
			bgSndChannel.soundTransform = bgSndTransform;
			bgSndChannel.addEventListener(Event.SOUND_COMPLETE, rePlayBgSound)
		}
		private function rePlayBgSound(e: Event): void {
			SoundChannel(e.target).removeEventListener(e.type, rePlayBgSound);
			playBgSound();
		}
		private function onClickBgSound(e: MouseEvent) {
			tempSound = true;
			playBgSound();
			menu_mc.BgSound_mc.visible = false;
			menu_mc.BgSound_mc.onBtn.visible = false;
			menu_mc.BgSound_mc.offBtn.visible = true;
			
		}

	
		private function offPlayBgSound(e: MouseEvent) {
			tempSound = true;
			bgSndChannel.stop();
			menu_mc.BgSound_mc.onBtn.visible = true;
			menu_mc.BgSound_mc.offBtn.visible = false;
			menu_mc.BgSound_mc.visible = false;
			
		}
	}
}