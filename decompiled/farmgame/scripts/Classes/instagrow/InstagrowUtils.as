package Classes.instagrow
{
   import Classes.Airplane;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.InstagrowHelper;
   import Widgets.Windows.InstagrowWindow;
   
   public class InstagrowUtils
   {
      
      public static const INSTA_GROW_COUNTER:String = "instant_grow";
      
      public static const INSTA_GROW_COUNTER_REPRICING:String = "instant_grow_pricing";
      
      public static const INSTA_GROW_VIEW:String = "view";
      
      public static const SOURCE_HUD_ICON:String = "HUD_icon";
      
      public static const SOURCE_CONTEXT_MENU:String = "context_menu";
      
      public static const INSTA_GROW_HUD_ICON_NAME:String = "instagrowOptimization";
      
      private static const INSTA_GROW_LEVEL_LOCK:int = 15;
      
      private static const INSTA_GROW_ICON_SHOWN:String = "instagrowHudShown";
      
      private static const INSTA_GROW_ICON_CLICKED:String = "instagrowHudClicked";
      
      private static const INSTA_GROW_ICON_CLICK_DAY_TTL:int = 7;
      
      private static const INSTA_GROW_ICON_SHOW_LAYOFF_DAYS:int = 30;
      
      public function InstagrowUtils()
      {
         super();
      }
      
      public static function conditionallyShowInstagrowIcon() : void
      {
         var lastClicked:Number = NaN;
         if(shouldShowInstagrowIcon())
         {
            Global.hud.iconQueue.addIcon(INSTA_GROW_HUD_ICON_NAME);
            FarmStatsManager.sample(100,INSTA_GROW_COUNTER,SOURCE_HUD_ICON,"impressions");
            Global.player.setFeatureLastShown(INSTA_GROW_ICON_SHOWN,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
            lastClicked = Global.player.getFeatureLastShown(INSTA_GROW_ICON_CLICKED);
            if(lastClicked == 0)
            {
               Global.player.setFeatureLastShown(INSTA_GROW_ICON_CLICKED,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
            }
         }
         else
         {
            Global.hud.iconQueue.removeIconByName(INSTA_GROW_HUD_ICON_NAME);
         }
      }
      
      public static function shouldShowInstagrowIcon() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.level > INSTA_GROW_LEVEL_LOCK && !shouldThrottle())
         {
            if(new InstagrowHelper().hasResourcesToActOn())
            {
               result = true;
            }
         }
         return result;
      }
      
      private static function shouldThrottle() : Boolean
      {
         var result:Boolean = false;
         var lastClickedTime:Number = Global.player.getFeatureLastShown(INSTA_GROW_ICON_CLICKED);
         var lastShownTime:Number = Global.player.getFeatureLastShown(INSTA_GROW_ICON_SHOWN);
         if(lastClickedTime != 0 && GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastClickedTime > INSTA_GROW_ICON_CLICK_DAY_TTL * FarmGameUtil.NUM_SECS_IN_DAY)
         {
            if(lastShownTime != 0 && GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - lastShownTime < INSTA_GROW_ICON_SHOW_LAYOFF_DAYS * FarmGameUtil.NUM_SECS_IN_DAY)
            {
               result = true;
            }
         }
         return result;
      }
      
      public static function handleHudIconClick() : void
      {
         FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,InstagrowUtils.SOURCE_HUD_ICON,"clicks");
         InstagrowUtils.tryShowInstagrowWindow(InstagrowUtils.SOURCE_HUD_ICON);
         Global.player.setFeatureLastShown(INSTA_GROW_ICON_CLICKED,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
      }
      
      public static function tryShowInstagrowWindow(source:String, airplane:Airplane = null, instagrowHelper:InstagrowHelper = null) : void
      {
         if(instagrowHelper == null)
         {
            instagrowHelper = new InstagrowHelper();
         }
         if(instagrowHelper != null)
         {
            if(!(instagrowHelper.isAutoAH || instagrowHelper.isAutoBH || instagrowHelper.isAutoTH))
            {
               UI.displayPopup(new InstagrowWindow(airplane,instagrowHelper,source),true,"InstagrowWindow",true);
            }
         }
      }
   }
}

