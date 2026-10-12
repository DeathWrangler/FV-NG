package Managers
{
   import Classes.FarmGameWorld;
   import Classes.FarmIsoViewport;
   import Classes.MapResource;
   import Engine.Managers.SoundManager;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.geom.Rectangle;
   
   public class DefconManager
   {
      
      private static var m_throttledLastTime:int;
      
      public static const LOG_SECTION:String = "DefconManager";
      
      public static const FOCUS_RECTANGLE_SPRITE_NAME:String = "DefconManagerFocusRectangle";
      
      public static const MAX_LEVEL:int = 9;
      
      public static const MIN_LEVEL:int = 0;
      
      private static const DEFCON_LOWEST_LEVEL:int = 0;
      
      private static const DEFCON_HIGHEST_LEVEL:int = 9;
      
      private static const DEFCON_NEW_FRAME_INFLUENCE:Number = 1 / 8;
      
      private static const DEFCON_OLD_FRAME_INFLUENCE:Number = 7 / 8;
      
      private static const DEFCON_BAD_FRAMERATE:int = 22;
      
      private static const DEFCON_GOOD_FRAMERATE:int = 30;
      
      private static const DEFCON_STARTING_SCORE:int = 26;
      
      private static const DEFCON_LOCK_TIME_SHORT:Number = 5000;
      
      private static const DEFCON_LOCK_TIME_LONG:Number = 30000;
      
      private static const DEFCON_ANIMATION_LEVEL_PLAY:int = 0;
      
      private static const DEFCON_ANIMATION_LEVEL_PAUSE:int = 1;
      
      private static const DEFCON_ANIMATION_LEVEL_STOP:int = 2;
      
      private static const DEFCON_EFFECT_LEVEL_PLAY:int = 0;
      
      private static const DEFCON_EFFECT_LEVEL_PAUSE:int = 1;
      
      private static const THROTTLED_FRAME_TIME:int = 100;
      
      private static const THROTTLED_FRAME_COUNT:int = 10;
      
      private static const UNTHROTTLED_FRAME_COUNT:int = 120;
      
      private static var m_qualityLocked:Boolean = false;
      
      private static var m_currentDefconLevel:int = 1;
      
      private static var m_defconScore:Number = DEFCON_STARTING_SCORE;
      
      private static var m_lastDefconLevel:int = 1;
      
      private static var m_unlockTime:Number = 0;
      
      private static var m_debugLock:Boolean = false;
      
      private static var m_debugFocusRectangleVisible:Boolean = false;
      
      private static var m_throttledFrameCount:int = 0;
      
      private static var m_unthrottledFrameCount:int = 0;
      
      private static var m_throttled:Boolean = false;
      
      private static var m_throttleDebug:Boolean = true;
      
      private static var m_secondsAtBadFramerate:int = 0;
      
      private static var m_secondsAtGoodFramerate:int = 0;
      
      private static const FPS_DEFCON_UP_THRESHOLD:int = 2;
      
      private static const FPS_DEFCON_DOWN_THRESHOLD:int = 4;
      
      private static var m_animationFocusRectangle:Rectangle = null;
      
      private static const RESTRICT_ANIMATION_MAX_DEFCON:Number = 7;
      
      public function DefconManager()
      {
         super();
      }
      
      public static function get defconLevel() : int
      {
         return m_currentDefconLevel;
      }
      
      public static function get debugLock() : Boolean
      {
         return m_debugLock;
      }
      
      public static function checkPerformance(fps:int) : void
      {
         var badFramerate:int = 0;
         var goodFramerate:int = 0;
         if(!m_debugLock)
         {
            if(isNaN(m_defconScore))
            {
               m_defconScore = m_defconScore * DEFCON_OLD_FRAME_INFLUENCE + fps * DEFCON_NEW_FRAME_INFLUENCE;
            }
            else
            {
               m_defconScore = fps;
            }
            if(m_unlockTime < GlobalEngine.currentTime)
            {
               badFramerate = DEFCON_BAD_FRAMERATE;
               goodFramerate = DEFCON_GOOD_FRAMERATE;
               if(goodFramerate > Global.stage.frameRate - 2)
               {
                  goodFramerate = Global.stage.frameRate - 2;
               }
               if(fps < badFramerate)
               {
                  ++m_secondsAtBadFramerate;
                  m_secondsAtGoodFramerate = 0;
               }
               else if(fps > goodFramerate)
               {
                  ++m_secondsAtGoodFramerate;
                  m_secondsAtBadFramerate = 0;
               }
               if(m_secondsAtBadFramerate >= FPS_DEFCON_UP_THRESHOLD && m_currentDefconLevel + 1 <= DEFCON_HIGHEST_LEVEL)
               {
                  GlobalEngine.log(LOG_SECTION,"Defcon UP fps=" + fps + " badFramerate=" + badFramerate + " goodFramerate=" + goodFramerate);
                  toggleDefconLevel(m_currentDefconLevel + 1);
                  m_secondsAtGoodFramerate = m_secondsAtBadFramerate = 0;
               }
               else if(m_secondsAtGoodFramerate >= FPS_DEFCON_DOWN_THRESHOLD && m_currentDefconLevel - 1 >= DEFCON_LOWEST_LEVEL)
               {
                  GlobalEngine.log(LOG_SECTION,"Defcon DOWN fps=" + fps + " badFramerate=" + badFramerate + " goodFramerate=" + goodFramerate);
                  toggleDefconLevel(m_currentDefconLevel - 1);
                  m_secondsAtGoodFramerate = m_secondsAtBadFramerate = 0;
               }
            }
         }
      }
      
      public static function debugToggleVisualFocusRect() : void
      {
         m_debugFocusRectangleVisible = !m_debugFocusRectangleVisible;
         drawFocusRectangle();
      }
      
      public static function drawFocusRectangle() : void
      {
         var rectContainer:Sprite = Global.stage.getChildByName(FOCUS_RECTANGLE_SPRITE_NAME) as Sprite;
         if(m_debugFocusRectangleVisible)
         {
            if(!rectContainer)
            {
               rectContainer = new Sprite();
               rectContainer.name = FOCUS_RECTANGLE_SPRITE_NAME;
               Global.stage.addChild(rectContainer);
            }
            rectContainer.graphics.clear();
            rectContainer.graphics.lineStyle(5,16777215,0.8);
            rectContainer.graphics.drawRect(m_animationFocusRectangle.x,m_animationFocusRectangle.y,m_animationFocusRectangle.width,m_animationFocusRectangle.height);
            Global.stage.setChildIndex(rectContainer,Global.stage.numChildren - 1);
         }
         else if(rectContainer)
         {
            Global.stage.removeChild(rectContainer);
         }
      }
      
      public static function canAnimateMapResource(resource:MapResource) : Boolean
      {
         var inner:Rectangle = null;
         var canPlay:Boolean = false;
         if(resource)
         {
            canPlay = true;
            inner = resource.getDisplayRect();
            if(Boolean(inner) && Boolean(m_animationFocusRectangle))
            {
               canPlay = m_animationFocusRectangle.containsRect(inner);
            }
         }
         return canPlay;
      }
      
      public static function lockQuality() : void
      {
         m_qualityLocked = true;
      }
      
      public static function debugIncrementLevel() : void
      {
         if(m_currentDefconLevel < DEFCON_HIGHEST_LEVEL)
         {
            m_lastDefconLevel = m_currentDefconLevel;
            toggleDefconLevel(m_currentDefconLevel + 1);
         }
      }
      
      public static function debugDecrementLevel() : void
      {
         if(m_currentDefconLevel > DEFCON_LOWEST_LEVEL)
         {
            m_lastDefconLevel = m_currentDefconLevel;
            toggleDefconLevel(m_currentDefconLevel - 1);
         }
      }
      
      public static function debugToggleLevelLock() : void
      {
         m_debugLock = !m_debugLock;
      }
      
      protected static function toggleDefconLevel(defconLevel:int, forceRefresh:Boolean = false) : void
      {
         var quality:String = null;
         var maxAnimations:int = 0;
         var playAnimations:int = 0;
         var playEffects:int = 0;
         var numShards:int = 0;
         var zoom:Number = NaN;
         var width:Number = NaN;
         if(defconLevel != m_currentDefconLevel || forceRefresh)
         {
            m_lastDefconLevel = m_currentDefconLevel;
            m_currentDefconLevel = defconLevel;
            quality = "";
            maxAnimations = -1;
            playAnimations = -1;
            playEffects = -1;
            numShards = -1;
            switch(defconLevel)
            {
               case 0:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_SHORT;
                  maxAnimations = FarmGameWorld.DEFAULT_MAX_ANIMATIONS;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PLAY;
                  quality = StageQuality.HIGH;
                  numShards = 2;
                  break;
               case 1:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_SHORT;
                  maxAnimations = 18;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PLAY;
                  quality = StageQuality.HIGH;
                  numShards = 4;
                  break;
               case 2:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_SHORT;
                  maxAnimations = 16;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PLAY;
                  Global.stage.quality = StageQuality.HIGH;
                  numShards = 8;
                  break;
               case 3:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_SHORT;
                  maxAnimations = 14;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
                  quality = StageQuality.HIGH;
                  numShards = 8;
                  break;
               case 4:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_SHORT;
                  maxAnimations = 12;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
                  quality = StageQuality.MEDIUM;
                  numShards = 8;
                  break;
               case 5:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_SHORT;
                  maxAnimations = 10;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
                  quality = StageQuality.MEDIUM;
                  numShards = 16;
                  break;
               case 6:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_SHORT;
                  maxAnimations = 10;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
                  quality = StageQuality.MEDIUM;
                  numShards = 16;
                  break;
               case 7:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_LONG;
                  maxAnimations = 2;
                  playAnimations = DEFCON_ANIMATION_LEVEL_PLAY;
                  playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
                  quality = StageQuality.MEDIUM;
                  numShards = 16;
                  break;
               case 8:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_LONG;
                  maxAnimations = 0;
                  playAnimations = DEFCON_ANIMATION_LEVEL_STOP;
                  playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
                  quality = StageQuality.HIGH;
                  numShards = 16;
                  break;
               case 9:
                  m_unlockTime = GlobalEngine.currentTime + DEFCON_LOCK_TIME_LONG;
                  maxAnimations = 0;
                  playAnimations = DEFCON_ANIMATION_LEVEL_STOP;
                  playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
                  quality = StageQuality.MEDIUM;
                  numShards = 16;
            }
            zoom = GlobalEngine.viewport.getZoom();
            if(zoom <= FarmIsoViewport.ZOOM_OUT_LIMIT_RESTRICTED)
            {
               playAnimations = DEFCON_ANIMATION_LEVEL_STOP;
               playEffects = DEFCON_EFFECT_LEVEL_PAUSE;
            }
            if(numShards >= 0)
            {
               Global.world.setNumShards(numShards);
            }
            if(!m_qualityLocked && !Global.player.options.graphicsLowQuality && quality != "")
            {
               Global.stage.quality = quality;
            }
            Global.world.maxAnimations = maxAnimations;
            if(playAnimations >= 0 && !Global.world.isAnimationStateLocked)
            {
               switch(playAnimations)
               {
                  case DEFCON_ANIMATION_LEVEL_PLAY:
                     if(Global.animationState != Global.ANIMATION_STATE_PLAY)
                     {
                        Global.world.playAll();
                     }
                     break;
                  case DEFCON_ANIMATION_LEVEL_PAUSE:
                     if(Global.animationState != Global.ANIMATION_STATE_PAUSE)
                     {
                        Global.world.pauseAll();
                     }
                     break;
                  case DEFCON_ANIMATION_LEVEL_STOP:
                     if(Global.animationState != Global.ANIMATION_STATE_STOP)
                     {
                        Global.world.stopAll();
                     }
               }
            }
            if(playEffects >= 0)
            {
               switch(playEffects)
               {
                  case DEFCON_EFFECT_LEVEL_PLAY:
                     if(!Global.playOverlayEffects)
                     {
                        Global.world.playEffects();
                     }
                     break;
                  case DEFCON_EFFECT_LEVEL_PAUSE:
                     if(Global.playOverlayEffects)
                     {
                        Global.world.pauseEffects();
                     }
               }
            }
            width = Global.stage.stageWidth - 150;
            width -= (width - 700) * Math.min(defconLevel / RESTRICT_ANIMATION_MAX_DEFCON,1);
            if(!m_animationFocusRectangle)
            {
               m_animationFocusRectangle = new Rectangle(0,70,Global.stage.stageWidth,Global.stage.stageHeight - 230);
               m_animationFocusRectangle.y = 70;
            }
            m_animationFocusRectangle.x = (Global.stage.stageWidth - width) / 2;
            m_animationFocusRectangle.width = width;
            if(m_debugFocusRectangleVisible)
            {
               drawFocusRectangle();
            }
         }
      }
      
      public static function refresh() : void
      {
         toggleDefconLevel(m_currentDefconLevel,true);
      }
      
      public static function get isThrottled() : Boolean
      {
         return m_throttled;
      }
      
      public static function checkThrottling(currentTime:int) : void
      {
         var frameTime:int = currentTime - m_throttledLastTime;
         m_throttledLastTime = currentTime;
         if(!Global.appActive && frameTime > THROTTLED_FRAME_TIME)
         {
            m_unthrottledFrameCount = 0;
            ++m_throttledFrameCount;
         }
         else
         {
            m_throttledFrameCount = 0;
            ++m_unthrottledFrameCount;
         }
         if(!m_throttled)
         {
            if(m_throttledFrameCount > THROTTLED_FRAME_COUNT)
            {
               if(m_throttleDebug)
               {
                  GlobalEngine.log(LOG_SECTION,"App throttled");
                  SoundManager.playSound("tractorPlow");
               }
               m_throttled = true;
            }
         }
         else if(Global.appActive || m_unthrottledFrameCount > UNTHROTTLED_FRAME_COUNT)
         {
            if(m_throttleDebug)
            {
               GlobalEngine.log(LOG_SECTION,"App no longer throttled");
               SoundManager.playSound("setgraphic");
            }
            m_throttled = false;
         }
      }
   }
}

