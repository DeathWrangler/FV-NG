package GameMode
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class GMHolidayPresentPlace extends GMAutomaticStoragePlace
   {
      
      private var m_numGifts:int = 0;
      
      public function GMHolidayPresentPlace(itemName:String, isGift:Boolean)
      {
         super(itemName,"HolidayTreeStorage",isGift);
      }
      
      override protected function onFinishModifyBuilding(modifiedBuilding:Boolean, hasABuilding:Boolean, isFirstEntry:Boolean) : void
      {
         var callback:Function = null;
         var popupMessage:String = "";
         var popupKey:String = "";
         var popupType:int = GenericPopup.TYPE_ACCEPTCANCEL;
         if(modifiedBuilding == false)
         {
            if(hasABuilding == true)
            {
               popupMessage = ZLocUtils.t("Dialogs","HolidayTree_nospace");
               popupType = GenericPopup.TYPE_OK;
               callback = null;
            }
            else
            {
               popupKey = "HolidayTree_donthave";
               popupType = GenericPopup.TYPE_ACCEPTCANCEL;
               popupMessage = ZLocUtils.t("Dialogs",popupKey);
               callback = this.noTreeCallback;
            }
         }
         else if(isFirstEntry == true)
         {
            this.m_numGifts = m_building.capacity / (m_building.numImageStates - 1);
            popupKey = "HolidayTree_firstpresent";
            popupMessage = ZLocUtils.t("Dialogs",popupKey,{"quantity":this.m_numGifts});
            callback = null;
         }
         if(popupMessage != "")
         {
            FarmStatsManager.count("holidaytree","popup",popupKey);
            UI.displayPopup(new GenericPopup(popupMessage,popupType,callback));
         }
         else
         {
            reOpenGiftIfNecessary();
         }
         if(modifiedBuilding)
         {
            FarmStatsManager.count("holidaytree","addgift");
         }
      }
      
      private function noTreeCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMarketDialog("unknown","tree");
         }
      }
   }
}

