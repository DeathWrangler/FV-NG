package GameMode
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   
   public class GMFeedTroughItemPlace extends GMCreditsBuildingItemPlace
   {
      
      public function GMFeedTroughItemPlace(itemName:String, isGift:Boolean, itemCount:int = 1)
      {
         super(itemName,isGift,true,true,itemCount);
      }
      
      override protected function displayNoBuildingMessage() : void
      {
         var message:String = null;
         var buildings:Array = Global.world.getObjectsByName(m_creditsBuildingName);
         if(buildings.length > 0)
         {
            message = ZLocUtils.t("Dialogs","FeedTroughBuilding_MaxCapacity");
         }
         else
         {
            message = ZLocUtils.t("Dialogs","FeedTroughBuilding_NoBuilding");
         }
         UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
      }
   }
}

