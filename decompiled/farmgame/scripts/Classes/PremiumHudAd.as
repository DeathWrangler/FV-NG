package Classes
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.QueuedIcon;
   import Managers.FarmStatsManager;
   import flash.events.Event;
   
   public class PremiumHudAd
   {
      
      private static const ICON_NAMES:Array = new Array("PremiumHudIcon1","PremiumHudIcon2","PremiumHudIcon3");
      
      public static const W2E_SLOT_ID_PREMIUM_HUD_ICON:String = "WEB_FARM_INC_BH_PREMIUM";
      
      public static const STAT_VIEW:String = "view";
      
      public static const STAT_CLICK:String = "click";
      
      public static const ENABLED_VARIANT:int = 2;
      
      private static var m_lastIconIdx:int = -1;
      
      public function PremiumHudAd()
      {
         super();
      }
      
      private static function isFeatureEnabled() : Boolean
      {
         var variant:int = 0;
         var result:Boolean = false;
         if(Global.watchToEarn.isEnabled)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PREMIUM_HUD_AD);
            if(variant >= ENABLED_VARIANT)
            {
               result = true;
            }
         }
         return result;
      }
      
      private static function canUserSeeAd() : Boolean
      {
         return false;
      }
      
      public static function controlHUDIcon() : void
      {
         var iconName:String = null;
         var assetUrl:String = null;
         var iconTooltip:String = null;
         var hudIconData:Object = null;
         var icon:QueuedIcon = null;
         hideIcon();
         if(isFeatureEnabled() && canUserSeeAd())
         {
            m_lastIconIdx = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PREMIUM_HUD_AD) - ENABLED_VARIANT;
            iconName = ICON_NAMES[m_lastIconIdx];
            assetUrl = null;
            iconTooltip = null;
            if(!iconTooltip)
            {
               iconTooltip = ZLocUtils.t("Dialogs","PremiumHudAd_icon_tooltip_text");
            }
            hudIconData = {"iconTooltip":iconTooltip};
            icon = Global.hud.iconQueue.addIcon(iconName,DynamicIconQueue.ADD_BY_PRIORITY,assetUrl,hudIconData);
         }
      }
      
      public static function hudIconClicked() : void
      {
         FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,W2E_SLOT_ID_PREMIUM_HUD_ICON,STAT_CLICK);
         if(canUserSeeAd())
         {
            addW2EnActivityListeners();
            Global.watchToEarn.startActivity(W2E_SLOT_ID_PREMIUM_HUD_ICON);
         }
         else
         {
            hideIcon();
         }
      }
      
      public static function hideIcon() : void
      {
         if(m_lastIconIdx >= 0)
         {
            Global.hud.iconQueue.removeIconByName(ICON_NAMES[m_lastIconIdx]);
            m_lastIconIdx = -1;
         }
      }
      
      public static function initializeWatchToEarn() : void
      {
      }
      
      private static function onWatchToEarnServiceInitialized(event:Event) : void
      {
         controlHUDIcon();
      }
      
      private static function onWatchToEarnSlotChanged(event:Event) : void
      {
         controlHUDIcon();
      }
      
      private static function addW2EnActivityListeners() : void
      {
      }
      
      private static function removeW2EActivityListeners() : void
      {
      }
      
      public static function onW2ESlotActivityComplete(event:Event) : void
      {
         removeW2EActivityListeners();
         if(!isFeatureEnabled())
         {
            hideIcon();
         }
      }
      
      public static function onW2EResume(event:Event) : void
      {
         removeW2EActivityListeners();
         if(!isFeatureEnabled())
         {
            hideIcon();
         }
      }
   }
}

