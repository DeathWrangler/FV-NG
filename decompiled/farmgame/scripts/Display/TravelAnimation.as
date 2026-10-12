package Display
{
   import Engine.Events.TransactionFaultEvent;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureConfigManager;
   import Managers.WorldStatManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class TravelAnimation
   {
      
      private static var s_assetUrl:String;
      
      private static const TRAVEL_ANIMATION_GAMESETTINGS_KEY:String = "travelAnimationAsset";
      
      private static const DEFAULT_ASSET_URL:String = "assets/dialogs/FV_interstitalShort_R.swf";
      
      private static const FLASHVAR_TRAVEL_ANIMATION_ASSET:String = "FEATURE_TRAVEL_ANIMATION_ASSET";
      
      private static const FORCED_RECT:Rectangle = new Rectangle(0,0,760,600);
      
      private var m_traveling:Boolean;
      
      private var m_content:MovieClip;
      
      private var m_loader:Loader;
      
      private var m_animationStoppedCallback:Function = null;
      
      private var m_fromWorld:String;
      
      private var m_toWorld:String;
      
      public function TravelAnimation(animationStopCallback:Function = null, fromWorld:String = null, toWorld:String = null)
      {
         super();
         this.m_animationStoppedCallback = animationStopCallback;
         this.m_loader = LoadingManager.load(this.getAssetUrl(fromWorld,toWorld),this.onAnimationLoaded);
         this.m_traveling = true;
         this.m_fromWorld = fromWorld;
         this.m_toWorld = toWorld;
         TransactionManager.getInstance().addEventListener(TransactionFaultEvent.FAULT,this.onTransactionFault);
      }
      
      private function getAssetUrl(fromWorld:String = null, toWorld:String = null) : String
      {
         var result:String = null;
         var travelAnimationFeatureName:String = null;
         var travelAnimationFeature:FeatureConfigManager = null;
         var relativeURL:String = null;
         if(Boolean(fromWorld) && Boolean(toWorld))
         {
            travelAnimationFeatureName = "travelAnimation_to_" + toWorld + "_from_" + fromWorld;
            travelAnimationFeature = FeatureConfigManager.getFeatureConfiguration(travelAnimationFeatureName);
            if(travelAnimationFeature)
            {
               relativeURL = travelAnimationFeature.getStringConstant(TRAVEL_ANIMATION_GAMESETTINGS_KEY);
               if(relativeURL)
               {
                  result = Global.getAssetURL(relativeURL);
               }
            }
         }
         if(!result)
         {
            if(s_assetUrl == null)
            {
               if(Global.experimentManager.getExperimentVariant("fv_travel_animation_asset") == 1)
               {
                  s_assetUrl = Global.getAssetURL(GlobalEngine.getFlashVar(FLASHVAR_TRAVEL_ANIMATION_ASSET) as String);
               }
               if(null == s_assetUrl)
               {
                  s_assetUrl = Global.getAssetURL(Global.farmGameSettingsManager.getString(TRAVEL_ANIMATION_GAMESETTINGS_KEY,DEFAULT_ASSET_URL));
               }
            }
            result = s_assetUrl;
         }
         return result;
      }
      
      public function stopTravelAnimation() : void
      {
         if(this.m_traveling)
         {
            this.m_traveling = false;
            if(this.m_content)
            {
               this.m_content.stop();
               this.m_content.parent.removeChild(this.m_content);
               this.m_content = null;
            }
            else if(this.m_loader)
            {
               LoadingManager.cancelLoad(this.m_loader);
               this.m_loader = null;
            }
            TransactionManager.getInstance().removeEventListener(TransactionFaultEvent.FAULT,this.onTransactionFault);
            if(this.m_animationStoppedCallback != null)
            {
               this.m_animationStoppedCallback();
            }
         }
      }
      
      private function onAnimationLoaded(event:Event) : void
      {
         this.m_content = event.target.content as MovieClip;
         if(Boolean(this.m_content) && this.m_traveling)
         {
            this.m_content.x = (GlobalEngine.stage.stageWidth - FORCED_RECT.width) / 2;
            this.m_content.y = (GlobalEngine.stage.stageHeight - FORCED_RECT.height) / 2;
            Global.stage.addChild(this.m_content);
            this.m_content.play();
            WorldStatManager.trackTravelInterstitialDialog(this.m_fromWorld,this.m_toWorld);
         }
      }
      
      private function onTransactionFault(event:TransactionFaultEvent) : void
      {
         this.stopTravelAnimation();
      }
   }
}

