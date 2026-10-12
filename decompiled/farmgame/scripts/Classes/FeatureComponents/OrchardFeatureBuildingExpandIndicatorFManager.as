package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Managers.FarmStatsManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class OrchardFeatureBuildingExpandIndicatorFManager extends AnimalBreedingExpandIndicatorFManager implements IStateIndicatorComponent
   {
      
      private static var s_globalClickDispatcher:EventDispatcher = new EventDispatcher();
      
      private static const INDICATOR_X_OFFSET:Number = 65;
      
      private static const INDICATOR_Y_OFFSET:Number = 110;
      
      private static const ALTERNATIVE_OFFSET_STATE:String = "expand";
      
      private var m_deprecator:DeprecatorSettings;
      
      public function OrchardFeatureBuildingExpandIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
         s_globalClickDispatcher.addEventListener(Event.CHANGE,this.onGlobalIndicatorClick);
      }
      
      protected function onGlobalIndicatorClick(event:Event) : void
      {
         var seenFlag:String = this.getBuildingSeenFlag();
         if(!seenFlag || Global.player.getSeenFlag(seenFlag))
         {
            s_globalClickDispatcher.removeEventListener(Event.CHANGE,this.onGlobalIndicatorClick);
            hide();
         }
      }
      
      public function showDeprecation(deprecator:DeprecatorSettings) : void
      {
         if(hasState(DEPRECATION_STATE))
         {
            this.m_deprecator = deprecator;
            super.show(DEPRECATION_STATE);
         }
      }
      
      override public function onClick() : void
      {
         var imageUrl:String = null;
         var prompt:GenericXMLDialog = null;
         var giftBoxItems:XMLList = null;
         var giftBoxItem:XML = null;
         if(m_currentState == StateIndicatorFManager.DEPRECATION_STATE)
         {
            imageUrl = null;
            if(this.m_deprecator)
            {
               giftBoxItems = this.m_deprecator.getGiftboxItems();
               if(Boolean(giftBoxItems) && giftBoxItems.length() > 0)
               {
                  giftBoxItem = giftBoxItems[0];
                  imageUrl = Global.farmGameSettingsManager.getImageByName(giftBoxItem.@name,"icon",false);
               }
            }
            prompt = new GenericXMLDialog(null,null,null,imageUrl,100,100,ZLocUtils.t("Dialogs","SuperOrchardDeprecation_PopupMessage"),null,false,ZLocUtils.t("FarmGame","Okay"),this.onDeprecationPopupClosed);
            UI.displayPopup(prompt,true,"deprecationPopup",true);
            FarmStatsManager.count("deprecation_arrow",m_owner.bldgName,"click");
         }
         else
         {
            super.onClick();
         }
         s_globalClickDispatcher.dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function onDeprecationPopupClosed(event:Event) : void
      {
         super.onClick();
      }
      
      override protected function getBuildingSeenFlag(state:String = null) : String
      {
         var result:String = null;
         if(state == null)
         {
            state = m_currentState;
         }
         if(owner)
         {
            if(state == StateIndicatorFManager.DEPRECATION_STATE)
            {
               result = owner.getItemName() + "_" + state + "_seenArrow";
            }
            else
            {
               result = owner.getItemName() + "_" + state + "_" + owner.getItem().getMaxUpgradeLevel() + "_seenArrow";
            }
         }
         return result;
      }
      
      override public function onDetatch() : void
      {
         s_globalClickDispatcher.removeEventListener(Event.CHANGE,this.onGlobalIndicatorClick);
      }
   }
}

