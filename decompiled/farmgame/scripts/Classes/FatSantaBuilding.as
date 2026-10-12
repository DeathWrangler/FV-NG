package Classes
{
   import Classes.DisplayLoading.DLManager;
   import Classes.util.FarmGameUtil;
   import Engine.Classes.URLResourceLoader;
   import Engine.Managers.LoadingManager;
   import Managers.PerformanceExperimentManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FatSantaBuilding extends FeatureBuilding
   {
      
      protected static const TRANSFORM_OVERLAY_URL:String = "assets/overlays/snow_test.swf";
      
      private var m_snowTimer:Timer = null;
      
      private var m_movieContainer:MovieClip = null;
      
      private var m_numberOfFlakes:Number = 1500;
      
      private var m_loader:Loader;
      
      private var m_featureName:String;
      
      public function FatSantaBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function canShowSellMenuItem() : Boolean
      {
         return this.isSellable();
      }
      
      override protected function showStorageContextMenu() : Boolean
      {
         return false;
      }
      
      override public function isSellable() : Boolean
      {
         var result:Boolean = false;
         var startDate:String = "12/07/2015";
         var endDate:String = "12/31/2015";
         if(Boolean(startDate) && Boolean(endDate) && !FarmGameUtil.checkDateGate(startDate,endDate))
         {
            result = super.isSellable();
         }
         return result;
      }
      
      override public function updateAnimation(delta:int) : void
      {
      }
      
      override public function showItemStorageLimitFullDialog(item:MapResource) : void
      {
      }
      
      public function startSnowing() : void
      {
         var assetURL:String = Global.getAssetURL(TRANSFORM_OVERLAY_URL);
         var options:Object = new Object();
         options.completeCallback = this.createSnow;
         options.resourceLoaderClass = URLResourceLoader;
         this.m_loader = new Loader();
         this.m_loader = LoadingManager.load(assetURL,this.createSnow,1,this.onFaultCallBack);
      }
      
      protected function createSnow(event:Event, data:* = null) : void
      {
         var movie:MovieClip;
         var snowClassNameString:String;
         var Snow:Class = null;
         var mcSnow:MovieClip = null;
         var speed:Number = NaN;
         var movieWidth:Number = NaN;
         var movieHeight:Number = NaN;
         var i:int = 0;
         var randomScale:Number = NaN;
         var radian:Number = NaN;
         this.m_movieContainer = new MovieClip();
         movie = event.currentTarget.content;
         snowClassNameString = "snow_mc";
         if(movie)
         {
            Snow = event.target.applicationDomain.getDefinition(snowClassNameString) as Class;
            this.m_movieContainer.visible = true;
            if(!PerformanceExperimentManager.isInAnimationMemoryExperiment || DLManager.shouldMakeAnimations())
            {
               mcSnow = new Snow() as MovieClip;
               mcSnow.visible = true;
               speed = 2;
               movieWidth = 550;
               movieHeight = 400;
               for(i = 0; i < this.m_numberOfFlakes; i++)
               {
                  randomScale = this.random(0,50) + 50;
                  mcSnow.scaleX = randomScale;
                  mcSnow.scaleY = randomScale;
                  mcSnow.alpha = this.random(0,50) + 50;
                  mcSnow.x = this.random(0,movieWidth);
                  mcSnow.y = this.random(0,movieHeight);
                  mcSnow.rotation = Math.PI + Math.random() * Math.PI;
                  radian = 0;
                  var _temp_3:* = this;
                  var _temp_2:* = Event.ENTER_FRAME;
                  with({})
                  {
                     
                     _temp_3.addEventListener(_temp_2,function onEnterFrame(e:Event):void
                     {
                        var wind:Number = -1;
                        this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
                        radian += mcSnow.rotation / 180 * Math.PI;
                        mcSnow.x -= Math.cos(radian) + wind;
                        mcSnow.y += speed;
                        if(mcSnow.y >= movieHeight)
                        {
                           mcSnow.y = -2;
                        }
                        if(mcSnow.x >= movieWidth)
                        {
                           mcSnow.x = 1;
                        }
                        if(mcSnow.x <= 0)
                        {
                           mcSnow.x = movieWidth - 1;
                        }
                     });
                  }
               }
               this.addSnowOverlay();
            }
         }
         
         private function addSnowOverlay() : void
         {
            GlobalEngine.viewport.uiBase.addChild(this.m_movieContainer);
            this.m_snowTimer = new Timer(6533,1);
            this.m_snowTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.stopSnowing);
            this.m_snowTimer.start();
         }
         
         private function stopSnowing(event:TimerEvent) : void
         {
            this.m_snowTimer.stop();
            this.m_snowTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.stopSnowing);
            this.m_snowTimer = null;
         }
         
         private function onFaultCallBack(e:Event) : void
         {
         }
         
         override public function getCurrentSuffix() : int
         {
            var level:int = 0;
            var result:int = 0;
            if(numImageStates > 1)
            {
               if(m_storageLevel)
               {
                  level = storageLevel - 1;
               }
            }
            return level;
         }
         
         override public function getCurrentImageName() : String
         {
            var currentSuffixNum:int = this.getCurrentSuffix();
            return "built_" + currentSuffixNum;
         }
         
         private function random(min:Number, max:Number) : Number
         {
            return Math.floor(Math.random() * (max - min + 1)) + min;
         }
      }
   }
   
   