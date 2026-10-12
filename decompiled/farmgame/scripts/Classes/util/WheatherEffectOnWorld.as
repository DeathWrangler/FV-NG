package Classes.util
{
   import Classes.WheatherEffect;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.utils.Timer;
   
   public class WheatherEffectOnWorld
   {
      
      private static var m_instance:WheatherEffectOnWorld;
      
      public static const SNOW_EFFECT:String = "snow";
      
      public static const RAIN_EFFECT:String = "rain";
      
      public static const WIND_EFFECT:String = "wind";
      
      protected static const TRANSFORM_OVERLAY_URL:String = "assets/overlays/snow_test1.swf";
      
      private static const WORLD_NAME:String = "WORLD_NAME";
      
      private static const EFFECT_TYPE:String = "EFFECT_TYPE";
      
      private static const PARTICLE_COUNT:String = "PARTICLE_COUNT";
      
      private static const SPEED:String = "SPEED";
      
      private var m_snowTimer:Timer = null;
      
      private var m_movieContainer:MovieClip;
      
      private var m_movieWidth:Number;
      
      private var m_movieHeight:Number;
      
      private var m_worldType:String;
      
      private var m_effectType:String;
      
      private var m_particleCount:int;
      
      private var m_speed:int;
      
      public function WheatherEffectOnWorld()
      {
         super();
         this.setWheatherConsts();
      }
      
      public static function getInstance() : WheatherEffectOnWorld
      {
         if(m_instance == null)
         {
            m_instance = new WheatherEffectOnWorld();
         }
         return m_instance;
      }
      
      private function setWheatherConsts() : void
      {
         var wheatherVars:Object = com.adobe.serialization.json.JSON.decode(Global.flashHotParams["WHEATHER_EFFECTS"]) as Object;
         if(wheatherVars)
         {
            if(wheatherVars.hasOwnProperty(WORLD_NAME))
            {
               this.m_worldType = wheatherVars.WORLD_NAME;
            }
            if(wheatherVars.hasOwnProperty(EFFECT_TYPE))
            {
               this.m_effectType = wheatherVars.EFFECT_TYPE;
            }
            if(wheatherVars.hasOwnProperty(PARTICLE_COUNT))
            {
               this.m_particleCount = int(wheatherVars.PARTICLE_COUNT);
            }
            if(wheatherVars.hasOwnProperty(SPEED))
            {
               this.m_speed = int(wheatherVars.SPEED);
            }
         }
      }
      
      private function get wheatherType() : String
      {
         var result:String = "";
         if(this.m_effectType != null)
         {
            result = this.m_effectType;
         }
         return result;
      }
      
      private function get particlesCount() : int
      {
         var result:int = 0;
         if(this.m_particleCount)
         {
            result = int(this.m_particleCount);
         }
         return result;
      }
      
      private function get worldType() : String
      {
         var result:String = "";
         if(this.m_worldType != null)
         {
            result = this.m_worldType;
         }
         return result;
      }
      
      public function showEffects() : void
      {
         if(this.canShowEffects() == true)
         {
            this.removeEffects();
            this.loadEffects();
            this.showAnimation();
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onResize);
            Global.stage.addEventListener(Event.RESIZE,this.onResize);
         }
      }
      
      private function loadEffects() : void
      {
         var mcEffect:WheatherEffect = null;
         var radonScale:Number = NaN;
         this.m_movieContainer = new MovieClip();
         this.m_movieWidth = GlobalEngine.stage.stageWidth;
         this.m_movieHeight = GlobalEngine.stage.stageHeight;
         for(var i:int = 0; i < this.particlesCount; i++)
         {
            radonScale = this.random(0.5,1.5);
            mcEffect = new WheatherEffect(this.wheatherType);
            mcEffect.visible = true;
            mcEffect.scaleX = radonScale;
            mcEffect.scaleY = radonScale;
            mcEffect.alpha = Math.random();
            mcEffect.x = this.random(0,this.m_movieWidth);
            mcEffect.y = this.random(0,this.m_movieHeight);
            mcEffect.rotation = Math.PI + Math.random() * Math.PI;
            mcEffect.enabled = false;
            mcEffect.mouseEnabled = false;
            mcEffect.mouseChildren = false;
            this.m_movieContainer.addChild(mcEffect);
         }
      }
      
      public function removeEffects() : void
      {
         if(this.isEffectOn() == true)
         {
            this.removeAnimation();
            if(Boolean(this.m_movieContainer) && this.m_movieContainer.hasEventListener(Event.ENTER_FRAME))
            {
               this.m_movieContainer.removeEventListener(Event.ENTER_FRAME,this.enterFrameAnimation);
            }
            this.m_movieContainer = null;
            Global.stage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onResize);
            Global.stage.removeEventListener(Event.RESIZE,this.onResize);
         }
      }
      
      private function showAnimation() : void
      {
         if(this.isEffectOn())
         {
            GlobalEngine.stage.addChild(this.m_movieContainer);
            this.m_movieContainer.visible = true;
            this.m_movieContainer.addEventListener(Event.ENTER_FRAME,this.enterFrameAnimation);
         }
      }
      
      private function enterFrameAnimation(e:Event) : void
      {
         var wheatherEffect:WheatherEffect = null;
         for(var index:int = 0; index < this.m_movieContainer.numChildren; index++)
         {
            wheatherEffect = this.m_movieContainer.getChildAt(index) as WheatherEffect;
            wheatherEffect.wheatherEffectEnterFrame();
         }
      }
      
      private function removeAnimation() : void
      {
         var wheatherEffect:DisplayObject = null;
         while(this.m_movieContainer.numChildren > 0)
         {
            wheatherEffect = this.m_movieContainer.getChildAt(0);
            if(wheatherEffect is WheatherEffect)
            {
               (wheatherEffect as WheatherEffect).removeWheatherEffect();
            }
            this.m_movieContainer.removeChildAt(0);
         }
      }
      
      private function canShowEffects() : Boolean
      {
         var result:Boolean = false;
         if(this.worldType != "" && this.wheatherType != "")
         {
            if(Global.worldManager.currentWorldType == this.worldType)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function isEffectOn() : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_movieContainer) && this.m_movieContainer.numChildren > 0)
         {
            result = true;
         }
         return result;
      }
      
      private function random(min:Number, max:Number) : Number
      {
         return Math.floor(Math.random() * (max - min + 1)) + min;
      }
      
      private function onResize(event:Event = null) : void
      {
         this.showEffects();
      }
   }
}

