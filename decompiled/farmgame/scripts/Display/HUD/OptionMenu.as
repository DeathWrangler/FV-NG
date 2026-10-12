package Display.HUD
{
   import Classes.MapResource;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.DefconManager;
   import Managers.FarmStatsManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TSaveOptions;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class OptionMenu extends Sprite
   {
      
      private static const X_POSITION:Number = 1;
      
      private static const Y_POSITION:Number = 26;
      
      private static const X_OFFSET_OPTION_BUTTONS:int = 6;
      
      private static const X_OFFSET_ANIMATION_BUTTON:int = 8;
      
      private static const Y_OFFSET_ANIMATION_BUTTON:int = 6;
      
      private static const Y_OFFSET_GRAPHICS_OPTION_BUTTON:int = 32;
      
      private static const Y_OFFSET_SOUNDFX_OPTION_BUTTON:int = 54;
      
      private static const Y_OFFSET_MUSIC_OPTION_BUTTON:int = 76;
      
      private static const ANIMATION_OFF_FRAMENO:int = 1;
      
      private static const ANIMATION_ON_FRAMENO:int = 2;
      
      private var m_optionMenuBackground:Bitmap;
      
      private var m_graphicsOn:Boolean = false;
      
      private var m_sfxOn:Boolean = false;
      
      private var m_musicOn:Boolean = false;
      
      private var m_animationOn:Boolean = false;
      
      private var m_optionButtonGraphics:OptionButton;
      
      private var m_optionButtonSFX:OptionButton;
      
      private var m_optionButtonMusic:OptionButton;
      
      private var m_animToggleBtn:MovieClip;
      
      public function OptionMenu()
      {
         super();
         this.m_graphicsOn = this.isHighQualityGraphics();
         this.m_sfxOn = SoundManager.isMuted() == false;
         this.m_musicOn = false;
         Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.onOptionsChanged);
      }
      
      public function set background(content:Bitmap) : void
      {
         if(content)
         {
            if(this.m_optionMenuBackground)
            {
               removeChild(this.m_optionMenuBackground);
            }
            this.m_optionMenuBackground = content;
            this.m_optionMenuBackground.x = X_POSITION;
            this.m_optionMenuBackground.y = Y_POSITION;
            addChildAt(this.m_optionMenuBackground,0);
         }
      }
      
      public function set graphicsButton(newButton:OptionButton) : void
      {
         if(newButton)
         {
            if(this.m_optionButtonGraphics)
            {
               this.m_optionButtonGraphics.removeEventListener(MouseEvent.CLICK,this.onGraphicsChanged);
               removeChild(this.m_optionButtonGraphics);
            }
            this.m_optionButtonGraphics = newButton;
            this.m_optionButtonGraphics.x = X_OFFSET_OPTION_BUTTONS;
            this.m_optionButtonGraphics.y = Y_OFFSET_GRAPHICS_OPTION_BUTTON;
            this.m_optionButtonGraphics.selected = this.m_graphicsOn;
            this.m_optionButtonGraphics.toolTip = ZLocUtils.t("FarmGame","Graphics_ToolTip");
            this.m_optionButtonGraphics.addEventListener(MouseEvent.CLICK,this.onGraphicsChanged);
            addChild(this.m_optionButtonGraphics);
         }
      }
      
      public function set sfxButton(newButton:OptionButton) : void
      {
         if(newButton)
         {
            if(this.m_optionButtonSFX)
            {
               this.m_optionButtonSFX.removeEventListener(MouseEvent.CLICK,this.onSFXChanged);
               removeChild(this.m_optionButtonSFX);
            }
            this.m_optionButtonSFX = newButton;
            this.m_optionButtonSFX.x = X_OFFSET_OPTION_BUTTONS;
            this.m_optionButtonSFX.y = Y_OFFSET_SOUNDFX_OPTION_BUTTON;
            this.m_optionButtonSFX.selected = this.m_sfxOn;
            this.m_optionButtonSFX.toolTip = ZLocUtils.t("FarmGame","SoundFX_ToolTip");
            this.m_optionButtonSFX.addEventListener(MouseEvent.CLICK,this.onSFXChanged);
            addChild(this.m_optionButtonSFX);
         }
      }
      
      public function set musicButton(newButton:OptionButton) : void
      {
         if(newButton)
         {
            if(this.m_optionButtonMusic)
            {
               this.m_optionButtonMusic.removeEventListener(MouseEvent.CLICK,this.onMusicChanged);
               removeChild(this.m_optionButtonMusic);
            }
            this.m_optionButtonMusic = newButton;
            this.m_optionButtonMusic.x = X_OFFSET_OPTION_BUTTONS;
            this.m_optionButtonMusic.y = Y_OFFSET_MUSIC_OPTION_BUTTON;
            this.m_optionButtonMusic.toolTip = ZLocUtils.t("FarmGame","Music_ToolTip");
            this.m_optionButtonMusic.selected = this.m_musicOn;
            this.m_optionButtonMusic.addEventListener(MouseEvent.CLICK,this.onMusicChanged);
            addChild(this.m_optionButtonMusic);
         }
      }
      
      public function set animationButton(btnMc:MovieClip) : void
      {
         var frameNo:int = 0;
         if(btnMc)
         {
            if(this.m_animToggleBtn)
            {
               this.m_animToggleBtn.removeEventListener(MouseEvent.CLICK,this.onAnimationChanged);
               removeChild(this.m_animToggleBtn);
            }
            this.m_animToggleBtn = btnMc;
            this.m_animToggleBtn.x = X_OFFSET_ANIMATION_BUTTON;
            this.m_animToggleBtn.y = Y_OFFSET_ANIMATION_BUTTON;
            frameNo = this.m_animationOn ? ANIMATION_ON_FRAMENO : ANIMATION_OFF_FRAMENO;
            this.m_animToggleBtn.gotoAndStop(frameNo);
            this.m_animToggleBtn.addEventListener(MouseEvent.MOUSE_UP,this.onAnimationChanged);
            addChild(this.m_animToggleBtn);
         }
      }
      
      public function disableSounds() : void
      {
         if(this.m_optionButtonSFX)
         {
            this.m_optionButtonSFX.selected = false;
            this.onSFXChanged(null);
         }
         if(this.m_optionButtonMusic)
         {
            this.m_optionButtonMusic.selected = false;
            this.onMusicChanged(null);
         }
      }
      
      private function onOptionsChanged(event:Event) : void
      {
         var options:Object = Global.player.options;
         this.m_graphicsOn = !options.graphicsLowQuality;
         this.m_sfxOn = !Global.player.isSfxDisabled();
         this.m_musicOn = !Global.player.isMusicDisabled();
         this.m_animationOn = !Global.player.isAnimationDisabled();
         this.syncOptions();
      }
      
      public function syncOptions() : void
      {
         this.onGraphicsChanged(null);
         this.onSFXChanged(null);
         this.onMusicChanged(null);
      }
      
      private function onGraphicsChanged(event:Event) : void
      {
         if(this.m_optionButtonGraphics)
         {
            this.m_graphicsOn = this.m_optionButtonGraphics.selected;
            Global.player.options.graphicsLowQuality = !this.m_graphicsOn;
         }
         if(this.m_graphicsOn)
         {
            Global.stage.quality = StageQuality.HIGH;
         }
         else
         {
            Global.stage.quality = StageQuality.LOW;
         }
         if(event != null)
         {
            FarmStatsManager.count(UI.UI_BUTTON_CLICKS_COUNTER,"graphics_quality");
            DefconManager.lockQuality();
            TransactionManager.addTransaction(new TSaveOptions(Global.player.options));
         }
      }
      
      private function onSFXChanged(event:Event) : void
      {
         if(this.m_optionButtonSFX)
         {
            this.m_sfxOn = this.m_optionButtonSFX.selected;
            Global.player.options.sfxDisabled = !this.m_optionButtonSFX.selected;
         }
         Global.world.syncSoundsToPlayerOptions();
         if(event != null)
         {
            FarmStatsManager.count(UI.UI_BUTTON_CLICKS_COUNTER,"sfx_enable");
            TransactionManager.addTransaction(new TSaveOptions(Global.player.options));
         }
         dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.SFX_CHANGED));
      }
      
      private function onMusicChanged(event:Event) : void
      {
         if(this.m_optionButtonMusic)
         {
            this.m_musicOn = this.m_optionButtonMusic.selected;
            Global.player.options.musicDisabled = !this.m_optionButtonMusic.selected;
         }
         Global.world.syncMusicToPlayerOptions();
         if(event != null)
         {
            FarmStatsManager.count(UI.UI_BUTTON_CLICKS_COUNTER,"music_enable");
            TransactionManager.addTransaction(new TSaveOptions(Global.player.options));
         }
      }
      
      private function onAnimationChanged(event:Event) : void
      {
         var frameNo:int = 0;
         if(this.m_animToggleBtn != null)
         {
            Global.player.options.animationDisabled = !Global.player.isAnimationDisabled();
            this.m_animationOn = !Global.player.isAnimationDisabled();
            frameNo = this.m_animationOn ? ANIMATION_ON_FRAMENO : ANIMATION_OFF_FRAMENO;
            this.m_animToggleBtn.gotoAndStop(frameNo);
            TransactionManager.addTransaction(new TSaveOptions(Global.player.options));
            GlobalEventManager.getInstance().dispatchEvent(new Event(MapResource.EVENT_TOGGLE_ANIMATION));
         }
      }
      
      private function isHighQualityGraphics() : Boolean
      {
         return Global.stage.quality != StageQuality.LOW;
      }
   }
}

