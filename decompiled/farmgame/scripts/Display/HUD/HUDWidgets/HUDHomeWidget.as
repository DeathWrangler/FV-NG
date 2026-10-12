package Display.HUD.HUDWidgets
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.StatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.FishingDerbyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class HUDHomeWidget extends HUDWidget
   {
      
      private static const ASSET_PATH:String = "assets/hud/FV_TackleBoxHomeHUD.swf";
      
      public static const TRAVEL_HOME:String = "travel_home_event";
      
      public function HUDHomeWidget(parentElement:Sprite)
      {
         super(ASSET_PATH,parentElement);
      }
      
      private static function goToHomeFarm(event:Event) : void
      {
         var currentTime:Number = NaN;
         var timeElapsed:String = null;
         Global.world.dispatchEvent(new Event(TRAVEL_HOME));
         var prevTime:Number = FishingDerbyManager.instance.getTimer();
         if(prevTime)
         {
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            timeElapsed = String((currentTime - prevTime) / 60);
            StatsManager.count(FeatureOptionsManager.FISHING_DERBY,"fv_fishing_session",timeElapsed,String(Global.player.uid));
         }
         Global.worldManager.swapFarm(WorldsConstants.WORLD_ID_HOME,false);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         m_loader.y = 20;
         Global.hud.conditionallyRefreshHUD(true);
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty("home_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_element.home_bt,"Home",goToHomeFarm));
         }
      }
      
      public function setX(location:Number) : void
      {
         m_loader.x = location;
      }
   }
}

