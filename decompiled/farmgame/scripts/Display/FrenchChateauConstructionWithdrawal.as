package Display
{
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import flash.events.MouseEvent;
   
   public class FrenchChateauConstructionWithdrawal extends ConstructionBuildingWithdrawal
   {
      
      public function FrenchChateauConstructionWithdrawal(storage:StorageBuilding)
      {
         super(storage);
         m_dialogType = "frenchchateau";
      }
      
      override protected function onGetThisCallback(event:MouseEvent) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(getItemNameFromEvent(event));
         var bundleData:Object = {"images":[{
            "href":"{SN_APP_URL}gifts.php?giftRecipient=" + Global.player.snUser.uid,
            "src":item.icon
         }]};
         GlobalEngine.socialNetwork.publishFeedStory("FrenchChateauNeedMaterials",bundleData,[],false,onAskForMaterials);
      }
   }
}

