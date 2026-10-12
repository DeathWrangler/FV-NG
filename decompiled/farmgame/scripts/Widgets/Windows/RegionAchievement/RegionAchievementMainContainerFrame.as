package Widgets.Windows.RegionAchievement
{
   import Classes.RegionAchievement.Region;
   import Managers.RegionAchievementManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class RegionAchievementMainContainerFrame extends FarmSlotContainerFrame
   {
      
      private static const LOCK_SCREEN_MC_PREFIX:String = "screen_";
      
      private static const LOCK_SCREEN_MC_SUFFIX:String = "_mc";
      
      protected static const SLOT_PREFIX:String = "region";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected var m_parentWindow:RegionAchievementWindow;
      
      protected var m_featureName:String;
      
      public function RegionAchievementMainContainerFrame(element:DisplayObject, parentWindow:RegionAchievementWindow, featureName:String)
      {
         this.m_parentWindow = parentWindow;
         this.m_featureName = featureName;
         super(element);
         this.initLockScreens();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RegionAchievementMainSlot(slotElement,this.m_parentWindow,this.m_featureName);
      }
      
      override protected function setupData() : void
      {
         m_slotData = RegionAchievementManager.getInstance(this.m_featureName).regions;
      }
      
      override public function refresh() : void
      {
         m_slotData = RegionAchievementManager.getInstance(this.m_featureName).regions;
         super.refresh();
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      private function initLockScreens() : void
      {
         var region:Region = null;
         var lockScreen:RegionLockScreen = null;
         var regions:Array = RegionAchievementManager.getInstance(this.m_featureName).regions;
         var i:int = 0;
         while(true)
         {
            region = regions[i] as Region;
            if(!(m_element.hasOwnProperty(LOCK_SCREEN_MC_PREFIX + i.toString() + LOCK_SCREEN_MC_SUFFIX) && Boolean(region)))
            {
               break;
            }
            lockScreen = new RegionLockScreen(m_element[LOCK_SCREEN_MC_PREFIX + i.toString() + LOCK_SCREEN_MC_SUFFIX],this.lockSreenParams(region));
            lockScreen.visible = true;
            if(region.unlocked)
            {
               lockScreen.visible = false;
            }
            i++;
         }
      }
      
      private function lockSreenParams(region:Region) : Object
      {
         var result:Object = {};
         result.title = region.name;
         result.body = region.getRegionUnlockTimerText();
         return result;
      }
   }
}

